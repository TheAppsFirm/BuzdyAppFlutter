import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:buzdy/services/video_downloader.dart';

class LocalVideosScreen extends StatefulWidget {
  const LocalVideosScreen({super.key});

  @override
  State<LocalVideosScreen> createState() => _LocalVideosScreenState();
}

class _LocalVideosScreenState extends State<LocalVideosScreen> {
  List<FileSystemEntity> _videos = [];

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    final vids = await VideoDownloader.listSavedVideos();
    setState(() {
      _videos = vids;
    });
  }

  void _openPlayer(File file) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _LocalVideoPlayer(file: file)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Videos')),
      body: _videos.isEmpty
          ? const Center(child: Text('No saved videos'))
          : ListView.builder(
              itemCount: _videos.length,
              itemBuilder: (context, index) {
                final file = File(_videos[index].path);
                final name = file.path.split('/').last;
                return ListTile(
                  title: Text(name),
                  trailing: const Icon(Icons.play_arrow),
                  onTap: () => _openPlayer(file),
                );
              },
            ),
    );
  }
}

class _LocalVideoPlayer extends StatefulWidget {
  final File file;
  const _LocalVideoPlayer({required this.file});

  @override
  State<_LocalVideoPlayer> createState() => _LocalVideoPlayerState();
}

class _LocalVideoPlayerState extends State<_LocalVideoPlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
