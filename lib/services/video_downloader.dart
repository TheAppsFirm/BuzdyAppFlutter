import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:flutter/foundation.dart';

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

  /// Downloads the video for the given [videoId] and returns the file path on
  /// success. Progress updates are reported through [onProgress].
  static Future<String?> download(
    String videoId, {
    void Function(double progress)? onProgress,
  }) async {
    try {
      debugPrint('VideoDownloader: starting download for $videoId');


      Directory saveDir = await _getSavedDir();
      bool permissionGranted = true;

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
            await openAppSettings();
          }
          debugPrint('Photo permission denied');
          permissionGranted = false;
        }
      }

      if (!permissionGranted) {
        return null;
      }

      debugPrint('Using directory: ${saveDir.path}');
      final yt = YoutubeExplode();
      StreamManifest manifest;
      try {
        manifest = await yt.videos.streamsClient.getManifest(videoId);
      } catch (e) {
        debugPrint('Failed to fetch stream manifest: $e');
        yt.close();
        return null;
      }
      if (manifest.muxed.isEmpty) {
        debugPrint('Video stream not available');
        await debugAvailableStreams(videoId);
        yt.close();
        return null;
      }
      final streamInfo = manifest.muxed.withHighestBitrate();
      final total = streamInfo.size.totalBytes;
      final stream = yt.videos.streamsClient.get(streamInfo);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${saveDir.path}/$videoId-$timestamp.mp4';
      debugPrint('Saving video to: $filePath');
      final file = File(filePath);
      final output = file.openWrite();

      var count = 0;
      await for (final data in stream) {
        count += data.length;
        output.add(data);
        final progress = count / total;
        if (onProgress != null) onProgress(progress);
        debugPrint('Download progress ${(progress * 100).toStringAsFixed(0)}%');
      }
      await output.flush();
      await output.close();
      yt.close();

      final result = await ImageGallerySaverPlus.saveFile(
        filePath,
        isReturnPathOfIOS: true,
      );
      debugPrint('Gallery save result: $result');
      if (result['isSuccess'] != true) {
        debugPrint('Failed to save to gallery');
        return null;
      }

      final savedPath = result['filePath'] ?? result['file_path'];
      debugPrint('File saved to gallery path: $savedPath');



      return savedPath is String ? savedPath : filePath;
    } catch (e) {
      debugPrint('VideoDownloader error: $e');
      return null;
    } finally {
      debugPrint('VideoDownloader finished');
    }
  }

  /// Downloads a video and updates [progressNotifier] with the download
  /// progress (0.0 to 1.0). Returns the saved file path on success or `null`
  /// if the download failed or permissions were denied.
  static Future<String?> downloadWithNotifier(
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
}

