import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum _MergeResult { success, pluginMissing, failure }

/// Result of a download request.
class DownloadResult {
  /// Path to the saved video if the download succeeded.
  final String? path;

  /// Whether the download failed due to missing permissions.
  final bool permissionDenied;

  const DownloadResult({this.path, this.permissionDenied = false});
}

/// Utility class to download YouTube videos and keep them locally.
class VideoDownloader {
  /// Returns the directory where downloaded videos are stored locally.
  static Future<Directory> _getSavedDir() async {
    Directory base;
    if (Platform.isAndroid) {
      final ext = await getExternalStorageDirectory();
      base = ext ?? await getTemporaryDirectory();
    } else {
      base = await getApplicationDocumentsDirectory();
    }
    final dir = Directory('${base.path}/saved_videos');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Lists all locally saved videos.
  static Future<List<FileSystemEntity>> listSavedVideos() async {
    final dir = await _getSavedDir();
    final files = dir
        .listSync()
        .where((f) => f.path.toLowerCase().endsWith('.mp4'))
        .toList();
    files.sort((a, b) => FileStat.statSync(b.path)
        .modified
        .compareTo(FileStat.statSync(a.path).modified));
    return files;
  }

  /// Logs all available streams for debugging purposes. This helps
  /// diagnose cases where no muxed stream is available.
  static Future<void> debugAvailableStreams(String videoId) async {
    final yt = YoutubeExplode();
    try {
      final manifest = await yt.videos.streamsClient.getManifest(videoId);
      if (manifest.muxed.isEmpty) {
        debugPrint('No muxed streams for $videoId');
      } else {
        debugPrint('Muxed streams for $videoId:');
        for (final m in manifest.muxed) {
          debugPrint('  ${m.videoQualityLabel} ${m.bitrate} tag:${m.tag}');
        }
      }
      debugPrint('Audio only streams:');
      for (final a in manifest.audioOnly) {
        debugPrint('  ${a.bitrate} ${a.codec} tag:${a.tag}');
      }
      debugPrint('Video only streams:');
      for (final v in manifest.videoOnly) {
        debugPrint('  ${v.videoQualityLabel} ${v.bitrate} ${v.codec} tag:${v.tag}');
      }
    } catch (e) {
      debugPrint('Error listing streams for $videoId: $e');
    } finally {
      yt.close();
    }
  }

  /// Merge [videoPath] and [audioPath] into [outputPath] using ffmpeg.
  /// Returns `true` if the merge succeeded, otherwise `false`.
  static Future<_MergeResult> _mergeWithFFmpeg(
      String videoPath, String audioPath, String outputPath) async {
    try {
      final cmd = "-y -i '$videoPath' -i '$audioPath' -c copy '$outputPath'";
      final session = await FFmpegKit.execute(cmd);
      final rc = await session.getReturnCode();
      final success = rc != null && rc.isValueSuccess();
      if (success && await File(outputPath).exists()) {
        return _MergeResult.success;
      }
      debugPrint('ffmpeg exit code: $rc');
      return _MergeResult.failure;
    } on MissingPluginException catch (e) {
      debugPrint('FFmpeg plugin missing: $e');
      return _MergeResult.pluginMissing;
    } catch (e) {
      debugPrint('ffmpeg merge failed: $e');
      return _MergeResult.failure;
    }
  }

  /// success. Progress updates are reported through [onProgress].
  static Future<DownloadResult> download(
    String videoId, {
    void Function(double progress)? onProgress,
  }) async {
    try {
      debugPrint('VideoDownloader: starting download for $videoId');


      Directory saveDir = await _getSavedDir();
      bool permissionGranted = true;
      debugPrint('Checking permissions...');

      if (Platform.isAndroid) {
        // Request scoped videos permission first then storage if needed
        var status = await Permission.videos.request();
        debugPrint('Videos permission status: $status');
        if (!status.isGranted) {
          status = await Permission.storage.request();
          debugPrint('Storage permission status: $status');
        }
        if (!status.isGranted) {
          if (status.isPermanentlyDenied) {
            debugPrint('Storage permission permanently denied, opening settings');
            await openAppSettings();
          }
          debugPrint('Storage permission denied');
          permissionGranted = false;
        }
      } else if (Platform.isIOS) {
        var status = await Permission.photosAddOnly.request();
        debugPrint('photosAddOnly status: $status');
        if (!status.isGranted) {
          status = await Permission.photos.request();
          debugPrint('photos status: $status');
        }
        if (!status.isGranted) {
          if (status.isPermanentlyDenied) {
            debugPrint('Photo permission permanently denied, opening settings');
            await openAppSettings();
          }
          debugPrint('Photo permission denied');
          permissionGranted = false;
        }
      }

      if (!permissionGranted) {
        debugPrint('Required permission not granted, aborting download');
        return const DownloadResult(permissionDenied: true);
      }

      debugPrint('Using directory: ${saveDir.path}');
      final yt = YoutubeExplode();
      StreamManifest manifest;
      try {
        manifest = await yt.videos.streamsClient.getManifest(videoId);
      } catch (e) {
        debugPrint('Failed to fetch stream manifest: $e');
        yt.close();
        return const DownloadResult();
      }
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputPath = '${saveDir.path}/$videoId-$timestamp.mp4';

      if (manifest.muxed.isEmpty) {
        debugPrint('Video stream not available, falling back to merge');
        await debugAvailableStreams(videoId);

        // Download separate video and audio streams then merge them
        if (manifest.videoOnly.isEmpty || manifest.audioOnly.isEmpty) {
          debugPrint('No separate video/audio streams available');
          return const DownloadResult();
        }

        StreamInfo? videoInfo;
        StreamInfo? audioInfo;
        try {
          videoInfo = manifest.videoOnly.withHighestBitrate();
          audioInfo = manifest.audioOnly.withHighestBitrate();
        } catch (_) {
          debugPrint('No streams found with highest bitrate');
          return const DownloadResult();
        }

        final videoTemp = '${saveDir.path}/$videoId-$timestamp-v.mp4';
        final audioTemp = '${saveDir.path}/$videoId-$timestamp-a.m4a';

        Future<void> _saveStream(Stream<List<int>> stream, String path,
            int totalBytes, double startRatio) async {
          final file = File(path).openWrite();
          var count = 0;
          await for (final data in stream) {
            count += data.length;
            file.add(data);
            final progress = startRatio +
                (count / totalBytes) * 0.5; // each stream ~50%
            onProgress?.call(progress);
          }
          await file.flush();
          await file.close();
        }

        await _saveStream(
          yt.videos.streamsClient.get(videoInfo),
          videoTemp,
          videoInfo.size.totalBytes,
          0.0,
        );
        await _saveStream(
          yt.videos.streamsClient.get(audioInfo),
          audioTemp,
          audioInfo.size.totalBytes,
          0.5,
        );

        // Merge using ffmpeg
        debugPrint('Merging video and audio using ffmpeg');
        final mergeResult =
            await _mergeWithFFmpeg(videoTemp, audioTemp, outputPath);
        if (mergeResult == _MergeResult.pluginMissing) {
          debugPrint('ffmpeg plugin missing, saving video without audio');
          await File(videoTemp).rename(outputPath);
          await File(audioTemp).delete();
        } else {
          await File(videoTemp).delete();
          await File(audioTemp).delete();
          if (mergeResult != _MergeResult.success) {
            return const DownloadResult();
          }
        }
      } else {
        StreamInfo? streamInfo;
        try {
          streamInfo = manifest.muxed.withHighestBitrate();
        } catch (_) {
          debugPrint('No muxed stream available');
          return const DownloadResult();
        }
        final total = streamInfo.size.totalBytes;
        final stream = yt.videos.streamsClient.get(streamInfo);
        final file = File(outputPath);
        final output = file.openWrite();
        var count = 0;
        await for (final data in stream) {
          count += data.length;
          output.add(data);
          final progress = count / total;
          onProgress?.call(progress);
        }
        await output.flush();
        await output.close();
      }

      yt.close();

      // Finished downloading locally
      onProgress?.call(1.0);
      debugPrint('File saved locally at $outputPath');

      return DownloadResult(path: outputPath);
    } catch (e) {
      debugPrint('VideoDownloader error: $e');
      return const DownloadResult();
    } finally {
      debugPrint('VideoDownloader finished');
    }
  }

  /// Downloads a video and updates [progressNotifier] with the download
  /// progress (0.0 to 1.0). Returns the saved file path on success or `null`
  /// if the download failed or permissions were denied.
  static Future<DownloadResult> downloadWithNotifier(
    String videoId,
    ValueNotifier<double> progressNotifier,
  ) async {
    // Reset progress
    progressNotifier.value = 0.0;
    return download(
      videoId,
      onProgress: (p) => progressNotifier.value = p,
    );
  }

  /// Downloads the highest quality video-only and audio-only streams for the
  /// given [videoUrl] and saves them as separate files in the app documents
  /// directory. The returned map contains the local paths with keys `videoPath`
  /// and `audioPath`. This does **not** merge the streams. Use ffmpeg if you
  /// need a single file.
  static Future<Map<String, String>?> downloadStreams(
    String videoUrl, {
    void Function(double videoProgress)? onVideoProgress,
    void Function(double audioProgress)? onAudioProgress,
  }) async {
    final yt = YoutubeExplode();
    try {
      debugPrint('Starting separate stream download for $videoUrl');

      // Resolve the video ID and fetch stream information
      final video = await yt.videos.get(videoUrl);
      final manifest = await yt.videos.streamsClient.getManifest(video.id);

      StreamInfo? videoInfo;
      StreamInfo? audioInfo;
      try {
        videoInfo = manifest.videoOnly.withHighestBitrate();
        audioInfo = manifest.audioOnly.withHighestBitrate();
      } catch (_) {
        debugPrint('No available streams for $videoUrl');
        return null;
      }

      final dir = await getApplicationDocumentsDirectory();
      final videoPath = '${dir.path}/${video.id}.mp4';
      final audioPath = '${dir.path}/${video.id}.m4a';

      // --- Download video stream ---
      final vStream = yt.videos.streamsClient.get(videoInfo);
      final vFile = File(videoPath).openWrite();
      var vCount = 0;
      final vTotal = videoInfo.size.totalBytes;
      await for (final data in vStream) {
        vCount += data.length;
        vFile.add(data);
        final progress = vCount / vTotal;
        onVideoProgress?.call(progress);
        debugPrint('Video ${(progress * 100).toStringAsFixed(0)}%');
      }
      await vFile.flush();
      await vFile.close();

      // --- Download audio stream ---
      final aStream = yt.videos.streamsClient.get(audioInfo);
      final aFile = File(audioPath).openWrite();
      var aCount = 0;
      final aTotal = audioInfo.size.totalBytes;
      await for (final data in aStream) {
        aCount += data.length;
        aFile.add(data);
        final progress = aCount / aTotal;
        onAudioProgress?.call(progress);
        debugPrint('Audio ${(progress * 100).toStringAsFixed(0)}%');
      }
      await aFile.flush();
      await aFile.close();

      return {'videoPath': videoPath, 'audioPath': audioPath};
    } catch (e) {
      debugPrint('downloadStreams error: $e');
      return null;
    } finally {
      yt.close();
    }
  }

  /// Save a downloaded video file to the user's gallery. Returns true if the
  /// gallery save succeeded.
  static Future<bool> saveToGallery(String filePath) async {
    bool granted = true;
    if (Platform.isAndroid) {
      var status = await Permission.videos.request();
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
      if (!status.isGranted) {
        if (status.isPermanentlyDenied) await openAppSettings();
        granted = false;
      }
    } else if (Platform.isIOS) {
      var status = await Permission.photosAddOnly.request();
      if (!status.isGranted) status = await Permission.photos.request();
      if (!status.isGranted) {
        if (status.isPermanentlyDenied) await openAppSettings();
        granted = false;
      }
    }

    if (!granted) {
      debugPrint('Gallery permission denied');
      return false;
    }

    final result = await ImageGallerySaverPlus.saveFile(
      filePath,
      isReturnPathOfIOS: true,
    );
    debugPrint('Gallery save result: $result');
    return result['isSuccess'] == true;
  }
}

