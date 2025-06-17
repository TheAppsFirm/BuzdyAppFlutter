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
  bool _selectMode = false;
  final Set<FileSystemEntity> _selected = {};

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    final vids = await VideoDownloader.listSavedVideos();
    setState(() {
      _videos = vids;
      _selected.removeWhere((f) => !_videos.contains(f));
    });
  }

  Future<void> _deleteVideo(File file) async {
    try {
      await file.delete();
      await _loadVideos();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Video deleted')));
    } catch (_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Delete failed'), backgroundColor: Colors.red));
    }
  }

  Future<void> _saveToGallery(File file) async {
    final ok = await VideoDownloader.saveToGallery(file.path);
    if (ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Saved to gallery')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to save'), backgroundColor: Colors.red));
    }
  }

  void _openPlayer(File file) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _LocalVideoPlayer(file: file)),
    );
  }

  void _toggleSelectMode() {
    setState(() {
      _selectMode = !_selectMode;
      if (!_selectMode) _selected.clear();
    });
  }

  void _toggleSelection(FileSystemEntity file) {
    setState(() {
      if (_selected.contains(file)) {
        _selected.remove(file);
      } else {
        _selected.add(file);
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selected.addAll(_videos);
    });
  }

  Future<void> _deleteSelected() async {
    for (final f in _selected.toList()) {
      await _deleteVideo(File(f.path));
    }
    _toggleSelectMode();
  }

  Future<void> _saveSelected() async {
    for (final f in _selected) {
      await _saveToGallery(File(f.path));
    }
    _toggleSelectMode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Videos'),
        leading: _selectMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _toggleSelectMode,
              )
            : null,
        actions: _selectMode
            ? [
                IconButton(
                  icon: const Icon(Icons.select_all),
                  onPressed: _selectAll,
                ),
                IconButton(
                  icon: const Icon(Icons.save_alt),
                  onPressed:
                      _selected.isEmpty ? null : () => _saveSelected(),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed:
                      _selected.isEmpty ? null : () => _deleteSelected(),
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.checklist),
                  onPressed: _toggleSelectMode,
                ),
              ],
      ),
      body: _videos.isEmpty
          ? const Center(child: Text('No saved videos'))
          : ListView.builder(
              itemCount: _videos.length,
              itemBuilder: (context, index) {
                final file = File(_videos[index].path);
                final name = file.path.split('/').last;
                final checked = _selected.contains(_videos[index]);
                return ListTile(
                  leading: _selectMode
                      ? Checkbox(
                          value: checked,
                          onChanged: (_) => _toggleSelection(_videos[index]),
                        )
                      : null,
                  title: Text(name),
                  trailing: _selectMode
                      ? null
                      : Wrap(
                          spacing: 4,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.save_alt),
                              onPressed: () => _saveToGallery(file),
                            ),
                            IconButton(
                              icon: const Icon(Icons.play_arrow),
                              onPressed: () => _openPlayer(file),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteVideo(file),
                            ),
                          ],
                        ),
                  onTap: _selectMode
                      ? () => _toggleSelection(_videos[index])
                      : () => _openPlayer(file),
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
