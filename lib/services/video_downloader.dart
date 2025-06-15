import 'dart:io';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

/// Utility class to download YouTube videos to a temporary directory.
class VideoDownloader {
  /// Downloads the video for the given [videoId] and returns the file path
  /// on success. Displays an error using [EasyLoading] on failure.
  static Future<String?> download(String videoId) async {
    try {
      EasyLoading.show(status: 'Preparing...');

      final tempDir = await getTemporaryDirectory();
      Directory saveDir = tempDir;

      if (Platform.isAndroid) {
        var status = await Permission.videos.request();
        if (!status.isGranted) {
          status = await Permission.storage.request();
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
      }

      final yt = YoutubeExplode();
      final manifest = await yt.videos.streamsClient.getManifest(videoId);
      final streamInfo = manifest.muxed.withHighestBitrate();
      final total = streamInfo.size.totalBytes;
      final stream = yt.videos.streamsClient.get(streamInfo);

      final filePath = '${saveDir.path}/$videoId.mp4';
      final file = File(filePath);
      final output = file.openWrite();

      var count = 0;
      await for (final data in stream) {
        count += data.length;
        output.add(data);
        final progress = count / total;
        EasyLoading.showProgress(progress,
            status: 'Downloading ${(progress * 100).toStringAsFixed(0)}%');
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

      EasyLoading.showSuccess('Video saved to gallery');
      return filePath;
    } catch (e) {
      EasyLoading.showError('Download failed: $e');
      return null;
    } finally {
      EasyLoading.dismiss();
    }
  }
}

