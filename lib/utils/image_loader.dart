// image_loader.dart
import 'dart:async';
import 'dart:ui' as ui;
import 'package:buzdy/presentation/screens/dashboard/crypto/model.dart/bubbleCoinModel.dart';
import 'package:flutter/material.dart';

class ImageLoader {
  final Map<String, ui.Image> imageCache;

  ImageLoader({required this.imageCache});

  Future<void> loadInitialImages(List<BubbleCoinModel> coins) async {
    for (var coin in coins) {
      if (!imageCache.containsKey(coin.id)) {
        final image = await _loadImage(coin.image);
        imageCache[coin.id] = image;
      }
    }
  }

  Future<void> loadRemainingImagesInBackground(List<BubbleCoinModel> allCoins, int coinRange) async {
    final remainingCoins = allCoins.skip(coinRange).toList();
    const int batchSize = 100;
    for (int i = 0; i < remainingCoins.length; i += batchSize) {
      final batch = remainingCoins.skip(i).take(batchSize).toList();
      await Future.wait(batch.map((coin) async {
        if (!imageCache.containsKey(coin.id)) {
          final image = await _loadImage(coin.image);
          imageCache[coin.id] = image;
        }
      }));
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  Future<ui.Image> _loadImage(String url) async {
    if (url.isEmpty) return _createFallbackImage();
    try {
      if (url.startsWith('data/logos/') || !url.startsWith('http')) {
        url = 'https://cryptobubbles.net/backend/' + url;
      }
      final completer = Completer<ui.Image>();
      final networkImage = NetworkImage(url);
      final stream = networkImage.resolve(const ImageConfiguration());
      stream.addListener(ImageStreamListener(
        (info, _) => completer.complete(info.image),
        onError: (error, _) => completer.complete(_createFallbackImage()),
      ));
      return await completer.future;
    } catch (e) {
      return _createFallbackImage();
    }
  }

  Future<ui.Image> _createFallbackImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(Rect.fromLTWH(0, 0, 1, 1), Paint()..color = Colors.transparent);
    return (recorder.endRecording()).toImage(1, 1);
  }
}