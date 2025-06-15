import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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

  Future<void> _shareVideo(int index) async {
    final id = widget.items[index].videoId;
    if (id == null || id.isEmpty) {
      EasyLoading.showError('Unable to share this video');
      return;
    }

    final url = 'https://youtu.be/$id';

    try {
      await Share.share(
        url,
        subject: 'Check out this video',
      );
    } catch (e) {
      EasyLoading.showError('Sharing not available');
    }
  }

  Future<void> _downloadVideo(int index) async {
    final id = widget.items[index].videoId;
    if (id == null || id.isEmpty) {
      EasyLoading.showError('Video not available');
      return;
    }
    showAppSnackBar(context, 'Downloading video...');
    final path = await VideoDownloader.download(id);
    if (path != null) {
      showAppSnackBar(context, 'Video saved to gallery');
    }
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
