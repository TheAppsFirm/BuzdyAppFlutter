import 'dart:io';

import 'package:flutter_easyloading/flutter_easyloading.dart';
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

  /// Downloads the video for the given [videoId] and returns the file path
  /// on success. Displays an error using [EasyLoading] on failure.
  static Future<String?> download(String videoId) async {
    try {
      debugPrint('VideoDownloader: starting download for $videoId');
      EasyLoading.show(status: 'Preparing...');

      Directory saveDir = await _getSavedDir();

      if (Platform.isAndroid) {
        // Request the scoped videos permission on newer Android first
        var status = await Permission.videos.request();
        debugPrint('Video permission status: $status');
        if (!status.isGranted) {
          status = await Permission.storage.request();
          debugPrint('Storage permission status: $status');
        }
        if (!status.isGranted) {
          if (status.isPermanentlyDenied) {
            EasyLoading.showError(
                'Please enable video access in settings');
            await openAppSettings();
          } else {
            EasyLoading.showError('Storage permission denied');
          }
          return null;
        }

        debugPrint('Using directory: ${saveDir.path}');
      } else if (Platform.isIOS) {
        var status = await Permission.photosAddOnly.request();
        if (!status.isGranted) {
          status = await Permission.photos.request();
        }
        if (!status.isGranted) {
          if (status.isPermanentlyDenied) {
            EasyLoading.showError(
                'Please enable photo access in Settings');
            await openAppSettings();
          } else {
            EasyLoading.showError('Photo permission denied');
          }
          return null;
        }

        debugPrint('Using directory: ${saveDir.path}');
      }

      final yt = YoutubeExplode();
      final manifest = await yt.videos.streamsClient.getManifest(videoId);
      if (manifest.muxed.isEmpty) {
        EasyLoading.showError('Video stream not available');
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
        EasyLoading.showProgress(progress,
            status: 'Downloading ${(progress * 100).toStringAsFixed(0)}%');
        debugPrint('Download progress ${(progress * 100).toStringAsFixed(0)}%');
      }
      await output.flush();
      await output.close();
      yt.close();

      final result = await ImageGallerySaverPlus.saveFile(
        filePath,
        isReturnPathOfIOS: true,
      );
      if (result['isSuccess'] != true) {
        EasyLoading.showError('Failed to save to gallery');
        return null;
      }

      final savedPath = result['filePath'] ?? result['file_path'];
      debugPrint('File saved to gallery path: $savedPath');



      EasyLoading.showSuccess('Video saved to gallery');
      return savedPath is String ? savedPath : filePath;
    } catch (e) {
      debugPrint('VideoDownloader error: $e');
      EasyLoading.showError('Download failed: $e');
      return null;
    } finally {
      debugPrint('VideoDownloader finished');
      EasyLoading.dismiss();
    }
  }
}

