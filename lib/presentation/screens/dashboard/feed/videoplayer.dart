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
      final ok = await VideoDownloader.saveToGallery(result.path!);
      if (ok) {
        showAppSnackBar(context, 'Video saved to gallery');
      } else {
        showAppSnackBar(context, 'Failed to save to gallery', isError: true);
      }
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
          _YouTubeControls(
            controller: _controller,
            onShare: _shareVideo,
            onDownload: _downloadVideo,
          ),
        ],
      ),
    );
  }
}

class _YouTubeControls extends StatefulWidget {
  final YoutubePlayerController controller;
  final VoidCallback onShare;
  final VoidCallback onDownload;

  const _YouTubeControls({
    required this.controller,
    required this.onShare,
    required this.onDownload,
  });

  @override
  State<_YouTubeControls> createState() => _YouTubeControlsState();
}

class _YouTubeControlsState extends State<_YouTubeControls> {
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onUpdate);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() => setState(() {});

  String _fmt(Duration d) => d.toString().split('.').first.padLeft(8, '0');

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final pos = c.value.position;
    final dur = c.metadata.duration;
    double progress = 0;
    if (dur.inMilliseconds > 0) {
      progress = pos.inMilliseconds / dur.inMilliseconds;
    }
    return GestureDetector(
      onTap: () => setState(() => _visible = !_visible),
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: const Duration(milliseconds: 300),
        child: Stack(
          children: [
            Positioned(
              right: 16,
              bottom: 40,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: widget.onShare,
                  ),
                  const SizedBox(height: 20),
                  IconButton(
                    icon: const Icon(Icons.download, color: Colors.white),
                    onPressed: widget.onDownload,
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    iconSize: 64,
                    icon: Icon(
                      c.value.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      c.value.isPlaying ? c.pause() : c.play();
                    },
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      Text(_fmt(pos),
                          style: const TextStyle(color: Colors.white)),
                      Expanded(
                        child: Slider(
                          value: progress.clamp(0.0, 1.0),
                          onChanged: (v) {
                            final target = Duration(
                                milliseconds:
                                    (dur.inMilliseconds * v).toInt());
                            c.seekTo(target);
                          },
                        ),
                      ),
                      Text(_fmt(dur),
                          style: const TextStyle(color: Colors.white)),
                      const SizedBox(width: 8),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}




          