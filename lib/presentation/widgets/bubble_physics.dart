import 'dart:math';
import 'package:buzdy/data/models/bubble.dart';
import 'package:buzdy/presentation/screens/dashboard/crypto/model.dart/bubbleCoinModel.dart';
import 'package:flutter/material.dart';

class BubblePhysics {
  final Random _random = Random();
  final double zoom;
  final double repulsionForce;
  final double centeringForce;
  final int simulationSteps;

  BubblePhysics({
    required this.zoom,
    this.repulsionForce = 10.0,
    this.centeringForce = 0.00005,
    this.simulationSteps = 50, // Reduced simulation steps
  });

  List<Bubble> generateBubbles(
    Size screenSize,
    List<BubbleCoinModel> bubbleCoins, {
    required double filterPanelHeight,
    required double bottomNavHeight,
  }) {
    final List<Bubble> generatedBubbles = [];
    if (bubbleCoins.isEmpty || screenSize.width <= 0 || screenSize.height <= 0) return [];

    final double availableHeight = screenSize.height - filterPanelHeight - bottomNavHeight;
    final Offset center = Offset(
      screenSize.width / 2,
      filterPanelHeight + (availableHeight * 0.3),
    );

    double minMarketCap = double.maxFinite;
    double maxMarketCap = 0;
    for (final coin in bubbleCoins) {
      if (coin.marketcap > 0) {
        minMarketCap = min(minMarketCap, coin.marketcap.toDouble());
        maxMarketCap = max(maxMarketCap, coin.marketcap.toDouble());
      }
    }
    minMarketCap = minMarketCap == double.maxFinite ? 1000000 : minMarketCap;
    maxMarketCap = maxMarketCap == 0 ? 1000000000000 : maxMarketCap;

    final double bubbleAreaMultiplier = zoom;
    final double minSize = 30.0 * bubbleAreaMultiplier;
    final double maxSize = min(screenSize.width * 0.2, 100.0) * bubbleAreaMultiplier;

    for (final coin in bubbleCoins) {
      if (coin.marketcap <= 0) continue;

      double bubbleSize = minSize;
      try {
        double logMin = log(minMarketCap);
        double logMax = log(maxMarketCap);
        double logVal = log(coin.marketcap.toDouble());
        double ratio = (logVal - logMin) / (logMax - logMin);
        ratio = ratio.clamp(0.0, 1.0);
        bubbleSize = minSize + ratio * (maxSize - minSize);
      } catch (_) {}

      final double radius = min(screenSize.width, availableHeight) * 0.9 / zoom;
      final double angle = _random.nextDouble() * 2 * pi;
      final double distance = _random.nextDouble() * radius;

      final Offset initialPosition = center + Offset(cos(angle) * distance, sin(angle) * distance);
      generatedBubbles.add(Bubble(
        model: coin,
        origin: initialPosition,
        currentPosition: initialPosition,
        size: bubbleSize,
        velocity: Offset.zero,
      ));
    }

    // Use a grid-based spatial partitioning to optimize repulsion calculations
    final gridSize = 100.0; // Size of each grid cell
    final gridWidth = (screenSize.width / gridSize).ceil();
    final gridHeight = (screenSize.height / gridSize).ceil();
    final grid = List.generate(gridWidth, (_) => List.generate(gridHeight, (_) => <Bubble>[]));

    // Assign bubbles to grid cells
    for (final bubble in generatedBubbles) {
      final gridX = (bubble.currentPosition.dx / gridSize).clamp(0, gridWidth - 1).toInt();
      final gridY = (bubble.currentPosition.dy / gridSize).clamp(0, gridHeight - 1).toInt();
      grid[gridX][gridY].add(bubble);
    }

    for (int step = 0; step < simulationSteps; step++) {
      for (int i = 0; i < generatedBubbles.length; i++) {
        final bubbleA = generatedBubbles[i];
        Offset totalForce = (center - bubbleA.currentPosition) * centeringForce;

        // Find the grid cell of bubbleA
        final gridX = (bubbleA.currentPosition.dx / gridSize).clamp(0, gridWidth - 1).toInt();
        final gridY = (bubbleA.currentPosition.dy / gridSize).clamp(0, gridHeight - 1).toInt();

        // Check neighboring grid cells (including the current cell)
        for (int dx = -1; dx <= 1; dx++) {
          for (int dy = -1; dy <= 1; dy++) {
            final checkX = gridX + dx;
            final checkY = gridY + dy;
            if (checkX < 0 || checkX >= gridWidth || checkY < 0 || checkY >= gridHeight) continue;

            for (final bubbleB in grid[checkX][checkY]) {
              if (bubbleA == bubbleB) continue;
              final Offset direction = bubbleA.currentPosition - bubbleB.currentPosition;
              final double distance = max(direction.distance, 0.1);
              final double minDistance = (bubbleA.size + bubbleB.size) / 2;

              if (distance < minDistance * 1.05) {
                final double forceMagnitude = repulsionForce * (minDistance * 1.05 - distance) / (minDistance * 1.05);
                totalForce += Offset(direction.dx / distance * forceMagnitude, direction.dy / distance * forceMagnitude);
              }
            }
          }
        }

        bubbleA.currentPosition += totalForce * (1.0 - step / simulationSteps);
        final double padding = bubbleA.size / 2;
        bubbleA.currentPosition = Offset(
          bubbleA.currentPosition.dx.clamp(padding, screenSize.width - padding),
          bubbleA.currentPosition.dy.clamp(filterPanelHeight + padding, screenSize.height - bottomNavHeight - padding),
        );
        if (step == simulationSteps - 1) bubbleA.origin = bubbleA.currentPosition;

        // Update grid cell for bubbleA
        final newGridX = (bubbleA.currentPosition.dx / gridSize).clamp(0, gridWidth - 1).toInt();
        final newGridY = (bubbleA.currentPosition.dy / gridSize).clamp(0, gridHeight - 1).toInt();
        if (newGridX != gridX || newGridY != gridY) {
          grid[gridX][gridY].remove(bubbleA);
          grid[newGridX][newGridY].add(bubbleA);
        }
      }
    }

    for (final bubble in generatedBubbles) {
      bubble.velocity = Offset((_random.nextDouble() * 2 - 1) * 0.1, (_random.nextDouble() * 2 - 1) * 0.1);
    }

    return generatedBubbles;
  }

  void updateBubblePositions(
    List<Bubble> bubbles,
    Size screenSize, {
    required double filterPanelHeight,
    required double bottomNavHeight,
  }) {
    final double availableHeight = screenSize.height - filterPanelHeight - bottomNavHeight;
    final Offset center = Offset(
      screenSize.width / 2,
      filterPanelHeight + (availableHeight * 0.3),
    );

    // Use a grid-based spatial partitioning for updates
    final gridSize = 100.0;
    final gridWidth = (screenSize.width / gridSize).ceil();
    final gridHeight = (screenSize.height / gridSize).ceil();
    final grid = List.generate(gridWidth, (_) => List.generate(gridHeight, (_) => <Bubble>[]));

    // Assign bubbles to grid cells
    for (final bubble in bubbles) {
      final gridX = (bubble.currentPosition.dx / gridSize).clamp(0, gridWidth - 1).toInt();
      final gridY = (bubble.currentPosition.dy / gridSize).clamp(0, gridHeight - 1).toInt();
      grid[gridX][gridY].add(bubble);
    }

    for (final bubble in bubbles) {
      final double padding = bubble.size / 2;
      final double minX = padding;
      final double maxX = screenSize.width - padding;
      final double minY = filterPanelHeight + padding;
      final double maxY = screenSize.height - bottomNavHeight - padding;

      // More aggressive repositioning if the bubble is outside the visible area
      if (bubble.currentPosition.dx < minX || bubble.currentPosition.dx > maxX ||
          bubble.currentPosition.dy < minY || bubble.currentPosition.dy > maxY) {
        final double newY = filterPanelHeight + (availableHeight * (0.3 + _random.nextDouble() * 0.4));
        final double newX = screenSize.width * (0.3 + _random.nextDouble() * 0.4);
        bubble.currentPosition = Offset(newX, newY);
        bubble.origin = bubble.currentPosition;
        bubble.velocity = Offset((_random.nextDouble() * 2 - 1) * 0.1, (_random.nextDouble() * 2 - 1) * 0.1);
      }

      final newPosition = bubble.currentPosition + bubble.velocity;
      if ((newPosition - bubble.origin).distance > bubble.size / 8) {
        bubble.velocity = -bubble.velocity * 0.95;
      }
      bubble.currentPosition = newPosition;

      if (bubble.currentPosition.dx < minX || bubble.currentPosition.dx > maxX) {
        bubble.velocity = Offset(-bubble.velocity.dx, bubble.velocity.dy);
      }
      if (bubble.currentPosition.dy < minY || bubble.currentPosition.dy > maxY) {
        bubble.velocity = Offset(bubble.velocity.dx, -bubble.velocity.dy);
      }
      bubble.currentPosition = Offset(
        bubble.currentPosition.dx.clamp(minX, maxX),
        bubble.currentPosition.dy.clamp(minY, maxY),
      );

      // Update grid cell for the bubble
      final gridX = (bubble.currentPosition.dx / gridSize).clamp(0, gridWidth - 1).toInt();
      final gridY = (bubble.currentPosition.dy / gridSize).clamp(0, gridHeight - 1).toInt();
      grid[gridX][gridY].add(bubble);
    }
  }
}