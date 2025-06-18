import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:buzdy/services/video_downloader.dart';
import 'package:buzdy/core/utils.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoId;
  final String? videoTitle;

  const VideoPlayerScreen({
    super.key,
    required this.videoId,
    this.videoTitle,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  final ValueNotifier<double?> _progress = ValueNotifier(null);

  Future<void> _shareVideo() async {
    final videoUrl = 'https://www.youtube.com/watch?v=${widget.videoId}';
    final title = widget.videoTitle ?? 'Check out this video';

    try {
      await Share.share(
        '$title\n$videoUrl',
        subject: title,
      );
    } catch (_) {
      showAppSnackBar(context, 'Sharing not available', isError: true);
    }
  }

  Future<void> _downloadVideo() async {
    showAppSnackBar(context, 'Downloading video...');
    _progress.value = 0;
    final result = await VideoDownloader.download(
      widget.videoId,
      onProgress: (p) => _progress.value = p,
    );
    if (result.permissionDenied) {
      showAppSnackBar(context, 'Storage permission denied', isError: true);
    } else if (result.path != null) {
      showAppSnackBar(context, 'Video saved locally');
    } else {
      showAppSnackBar(context, 'Download failed', isError: true);
    }
    _progress.value = null;
  }

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          ValueListenableBuilder<double?>(
            valueListenable: _progress,
            builder: (context, value, child) {
              return value == null
                  ? const SizedBox.shrink()
                  : Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(value: value),
                    );
            },
          ),
          Positioned.fill(
            child: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 40,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: _shareVideo,
                ),
                const SizedBox(height: 20),
                IconButton(
                  icon: const Icon(Icons.download, color: Colors.white),
                  onPressed: _downloadVideo,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}




          