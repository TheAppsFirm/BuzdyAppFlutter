import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:buzdy/core/utils.dart';
import 'dart:io';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:buzdy/services/video_downloader.dart';
import 'model/youtubeModel.dart';

class ShortsFeedPlayer extends StatefulWidget {
  final List<Item> items;
  final int initialIndex;
  const ShortsFeedPlayer({super.key, required this.items, this.initialIndex = 0});

  @override
  State<ShortsFeedPlayer> createState() => _ShortsFeedPlayerState();
}

class _ShortsFeedPlayerState extends State<ShortsFeedPlayer> {
  late PageController _pageController;
  late List<YoutubePlayerController> _controllers;
  final ValueNotifier<double?> _progress = ValueNotifier(null);

  Future<void> _shareVideo(int index) async {
    final id = widget.items[index].videoId;
    if (id == null || id.isEmpty) {
      showAppSnackBar(context, 'Unable to share this video', isError: true);
      return;
    }

    final url = 'https://youtu.be/$id';

    try {
      await Share.share(
        url,
        subject: 'Check out this video',
      );
    } catch (e) {
      showAppSnackBar(context, 'Sharing not available', isError: true);
    }
  }

  Future<void> _downloadVideo(int index) async {
    final id = widget.items[index].videoId;
    if (id == null || id.isEmpty) {
      showAppSnackBar(context, 'Video not available', isError: true);
      return;
    }
    showAppSnackBar(context, 'Downloading video...');
    _progress.value = 0;
    final localPath = await VideoDownloader.download(
      id,
      onProgress: (p) => _progress.value = p,
    );
    if (localPath != null) {
      final ok = await VideoDownloader.saveToGallery(localPath);
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
    _pageController = PageController(initialPage: widget.initialIndex);
    _controllers = widget.items
        .map((item) => YoutubePlayerController(
              initialVideoId: item.videoId ?? '',
              flags: const YoutubePlayerFlags(
                autoPlay: true,
                mute: false,
                forceHD: true,
              ),
            ))
        .toList();
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    for (var c in _controllers) {
      c.pause();
    }
    if (index < _controllers.length) {
      _controllers[index].play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        physics: const BouncingScrollPhysics(),
        onPageChanged: _onPageChanged,
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final player = YoutubePlayer(
            controller: _controllers[index],
            showVideoProgressIndicator: true,
          );
          final title = widget.items[index].snippet?.title ?? '';
          return Stack(
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
              Positioned.fill(child: player),
              Positioned(
                bottom: 20,
                left: 20,
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              Positioned(
                bottom: 60,
                right: 20,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      color: Colors.white,
                      icon: const Icon(Icons.share),
                      onPressed: () => _shareVideo(index),
                    ),
                    const SizedBox(height: 20),
                    IconButton(
                      color: Colors.white,
                      icon: const Icon(Icons.download),
                      onPressed: () => _downloadVideo(index),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
