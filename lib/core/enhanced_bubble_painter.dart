import 'dart:ui' as ui;
import 'package:buzdy/data/models/bubble.dart';
import 'package:flutter/material.dart';

class EnhancedBubblePainter extends CustomPainter {
  final List<Bubble> bubbles;
  final String timeframe;
  final Map<String, ui.Image> imageCache;
  final String sortBy;

  EnhancedBubblePainter({
    required this.bubbles,
    required this.timeframe,
    required this.imageCache,
    required this.sortBy,
  });

  String _formatLargeNumber(num number) {
    if (number >= 1e9) return '${(number / 1e9).toStringAsFixed(2)}B';
    if (number >= 1e6) return '${(number / 1e6).toStringAsFixed(2)}M';
    if (number >= 1e3) return '${(number / 1e3).toStringAsFixed(2)}K';
    return number.toString();
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final bubble in bubbles) {
      final coin = bubble.model;
      final performance = coin.performance[timeframe] ?? 0.0;

      // Determine bubble color based on performance
      final color = performance >= 0 ? Colors.green : Colors.red;
      final paint = Paint()
        ..color = color.withOpacity(0.6)
        ..style = PaintingStyle.fill;

      // Draw a border around the bubble
      final borderPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      // Draw the bubble
      canvas.drawCircle(bubble.currentPosition, bubble.size / 2, paint);
      canvas.drawCircle(bubble.currentPosition, bubble.size / 2, borderPaint);

      // Draw the coin image inside the bubble if available
      if (imageCache.containsKey(coin.id)) {
        final image = imageCache[coin.id]!;
        final imageSize = bubble.size * 0.6;
        final imageRect = Rect.fromCircle(
          center: bubble.currentPosition,
          radius: imageSize / 2,
        );

        final srcRect = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
        final dstRect = Rect.fromLTWH(
          bubble.currentPosition.dx - imageSize / 2,
          bubble.currentPosition.dy - imageSize / 2,
          imageSize,
          imageSize,
        );

        canvas.drawImageRect(image, srcRect, dstRect, Paint());
      }

      // Draw the symbol text with a shadow
      final textPainter = TextPainter(
        text: TextSpan(
          text: coin.symbol,
          style: TextStyle(
            color: Colors.white,
            fontSize: bubble.size * 0.2,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          bubble.currentPosition.dx - textPainter.width / 2,
          bubble.currentPosition.dy - bubble.size * 0.15,
        ),
      );

      // Draw the performance text with a shadow
      final performanceTextPainter = TextPainter(
        text: TextSpan(
          text: '${performance.toStringAsFixed(1)}%',
          style: TextStyle(
            color: Colors.white,
            fontSize: bubble.size * 0.15,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      performanceTextPainter.layout();
      performanceTextPainter.paint(
        canvas,
        Offset(
          bubble.currentPosition.dx - performanceTextPainter.width / 2,
          bubble.currentPosition.dy + bubble.size * 0.15,
        ),
      );

      // Draw the sort value text (Rank, Price, Volume, or Market Cap)
      String sortValue = "";
      if (sortBy == "Rank") {
        sortValue = "#${coin.rank}";
      } else if (sortBy == "Price") {
        sortValue = "\$${coin.price.toStringAsFixed(2)}";
      } else if (sortBy == "Volume") {
        sortValue = "\$${_formatLargeNumber(coin.volume)}";
      } else if (sortBy == "Market Cap") {
        sortValue = "\$${_formatLargeNumber(coin.marketcap)}";
      }

      final sortTextPainter = TextPainter(
        text: TextSpan(
          text: sortValue,
          style: TextStyle(
            color: Colors.white,
            fontSize: bubble.size * 0.15,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      sortTextPainter.layout();
      sortTextPainter.paint(
        canvas,
        Offset(
          bubble.currentPosition.dx - sortTextPainter.width / 2,
          bubble.currentPosition.dy,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}