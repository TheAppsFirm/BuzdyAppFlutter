import 'dart:io';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// Utility class to download YouTube videos to a temporary directory.
class VideoDownloader {
  /// Downloads the video for the given [videoId] and returns the file path
  /// on success. Displays an error using [EasyLoading] on failure.
  static Future<String?> download(String videoId) async {
    try {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        EasyLoading.showError('Storage permission denied');
        return null;
      }

      final yt = YoutubeExplode();
      final manifest = await yt.videos.streamsClient.getManifest(videoId);
      final streamInfo = manifest.muxed.withHighestBitrate();
      final stream = yt.videos.streamsClient.get(streamInfo);

      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/$videoId.mp4';
      final file = File(filePath);
      final output = file.openWrite();
      await stream.pipe(output);
      await output.flush();
      await output.close();
      // Close the YoutubeExplode client to free resources.
      yt.close();

      EasyLoading.showSuccess('Video downloaded');
      return filePath;
    } catch (e) {
      EasyLoading.showError('Download failed: $e');
      return null;
    }
  }
}

