import 'dart:io';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

/// Utility class to download YouTube videos to a temporary directory.
class VideoDownloader {
  /// Downloads the video for the given [videoId] and returns the file path
  /// on success. Displays an error using [EasyLoading] on failure.
  static Future<String?> download(String videoId) async {
    try {
      EasyLoading.show(status: 'Preparing...');

      Directory saveDir;
      if (Platform.isAndroid) {
        final perm = await Permission.storage.request();
        if (!perm.isGranted) {
          EasyLoading.showError('Storage permission denied');
          return null;
        }
        saveDir = await getExternalStorageDirectory() ??
            await getTemporaryDirectory();
      } else if (Platform.isIOS) {
        final perm = await Permission.photosAddOnly.request();
        if (!perm.isGranted) {
          EasyLoading.showError('Photo permission denied');
          return null;
        }
        saveDir = await getApplicationDocumentsDirectory();
      } else {
        saveDir = await getTemporaryDirectory();
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

      final result = await ImageGallerySaver.saveFile(filePath);
      if (result['isSuccess'] != true) {
        EasyLoading.showError('Failed to save to gallery');
        return null;
      }

      EasyLoading.showSuccess('Saved to ${saveDir.path}');
      return filePath;
    } catch (e) {
      EasyLoading.showError('Download failed: $e');
      return null;
    } finally {
      EasyLoading.dismiss();
    }
  }
}

