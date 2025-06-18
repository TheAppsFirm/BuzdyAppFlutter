import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
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
  final Map<String, Uint8List?> _thumbnails = {};

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    final vids = await VideoDownloader.listSavedVideos();
    _videos = vids;
    _selected.removeWhere((f) => !_videos.contains(f));
    _thumbnails.clear();
    for (final v in _videos) {
      final thumb = await VideoThumbnail.thumbnailData(
        video: v.path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 120,
        quality: 50,
      );
      _thumbnails[v.path] = thumb;
    }
    setState(() {});
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
    final index = _videos.indexWhere((v) => v.path == file.path);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LocalVideoFeed(files: _videos.map((e) => File(e.path)).toList(), initialIndex: index),
      ),
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

  Future<void> _promptDownload() async {
    String url = '';
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Download from URL'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter YouTube URL'),
            onChanged: (v) => url = v.trim(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Download'),
            ),
          ],
        );
      },
    );
    if (url.isNotEmpty) {
      await _downloadFromUrl(url);
    }
  }

  Future<void> _downloadFromUrl(String url) async {
    final progress = ValueNotifier<double>(0);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ValueListenableBuilder<double>(
        valueListenable: progress,
        builder: (context, value, child) {
          return AlertDialog(
            title: const Text('Downloading'),
            content: LinearProgressIndicator(value: value),
          );
        },
      ),
    );

    final result = await VideoDownloader.download(
      url,
      onProgress: (p) => progress.value = p,
    );

    Navigator.pop(context); // close progress dialog

    if (result.permissionDenied) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Permission denied')));
      return;
    }

    if (result.path != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Video downloaded')));
      await _loadVideos();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Download failed'), backgroundColor: Colors.red));
    }
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
                  icon: const Icon(Icons.add),
                  onPressed: _promptDownload,
                ),
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
                final size = (file.lengthSync() / (1024 * 1024)).toStringAsFixed(2);
                final checked = _selected.contains(_videos[index]);
                final thumb = _thumbnails[file.path];
                return ListTile(
                  leading: _selectMode
                      ? Checkbox(
                          value: checked,
                          onChanged: (_) => _toggleSelection(_videos[index]),
                        )
                      : (thumb != null
                          ? Image.memory(thumb, width: 64, height: 64, fit: BoxFit.cover)
                          : const SizedBox(width: 64, height: 64)),
                  title: Text(name),
                  subtitle: Text('$size MB'),
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

class LocalVideoFeed extends StatefulWidget {
  final List<File> files;
  final int initialIndex;
  const LocalVideoFeed({super.key, required this.files, this.initialIndex = 0});

  @override
  State<LocalVideoFeed> createState() => _LocalVideoFeedState();
}

class _LocalVideoFeedState extends State<LocalVideoFeed> {
  late PageController _pageController;
  final Map<int, VideoPlayerController> _controllers = {};
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _pageController = PageController(initialPage: _current);
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  Future<VideoPlayerController> _getController(int index) async {
    if (_controllers[index] != null) return _controllers[index]!;
    final controller = VideoPlayerController.file(widget.files[index]);
    await controller.initialize();
    controller.setLooping(true);
    if (index == _current) controller.play();
    _controllers[index] = controller;
    return controller;
  }

  void _onPageChanged(int index) {
    setState(() => _current = index);
    for (final entry in _controllers.entries) {
      if (entry.key == index) {
        entry.value.play();
      } else {
        entry.value.pause();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.files.length,
        scrollDirection: Axis.vertical,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          return FutureBuilder<VideoPlayerController>(
            future: _getController(index),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final controller = snap.data!;
              return Center(
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
