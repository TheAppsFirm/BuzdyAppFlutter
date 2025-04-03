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

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) {
      debugPrint("Invalid canvas size: $size");
      return;
    }

    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    _drawGridLines(canvas, size);

    // Draw bubbles in order (largest first).
    final sortedBubbles = List<Bubble>.from(bubbles)
      ..sort((a, b) => b.size.compareTo(a.size));

    for (final bubble in sortedBubbles) {
      if (bubble.currentPosition.dx < -bubble.size ||
          bubble.currentPosition.dx > size.width + bubble.size ||
          bubble.currentPosition.dy < -bubble.size ||
          bubble.currentPosition.dy > size.height + bubble.size) {
        continue;
      }

      double performance = bubble.model.performance[timeframe] ?? 0.0;
      final Color primaryColor =
          performance >= 0 ? Colors.greenAccent : Colors.redAccent;
      final Color secondaryColor = performance >= 0
          ? Colors.green.shade900
          : Colors.red.shade900;

      final Paint paint = Paint()
        ..shader = RadialGradient(
          colors: [
            primaryColor.withOpacity(0.9),
            primaryColor.withOpacity(0.7),
            secondaryColor.withOpacity(0.5),
          ],
          stops: const [0.0, 0.7, 1.0],
          center: const Alignment(0.2, -0.2),
        ).createShader(
          Rect.fromCircle(
            center: bubble.currentPosition,
            radius: bubble.size / 2,
          ),
        );

      final Paint glowPaint = Paint()
        ..color = primaryColor.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

      canvas.drawCircle(bubble.currentPosition, bubble.size / 2 + 5, glowPaint);

      final circlePath = Path()
        ..addOval(
          Rect.fromCircle(
            center: bubble.currentPosition,
            radius: bubble.size / 2,
          ),
        );
      canvas.drawShadow(circlePath, Colors.black, 10.0, true);
      canvas.drawCircle(bubble.currentPosition, bubble.size / 2, paint);

      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawArc(
        Rect.fromCircle(
          center: bubble.currentPosition - Offset(bubble.size / 6, bubble.size / 6),
          radius: bubble.size / 3,
        ),
        -0.5,
        1.5,
        false,
        highlightPaint,
      );

      // Display text based on sort option.
      String displayText;
      switch (sortBy) {
        case "Rank":
          displayText = "#${bubble.model.rank}";
          break;
        case "Price":
          displayText = "\$${bubble.model.price.toStringAsFixed(2)}";
          break;
        case "Volume":
          if (bubble.model.volume >= 1000000000) {
            displayText =
                "\$${(bubble.model.volume / 1000000000).toStringAsFixed(1)}B";
          } else if (bubble.model.volume >= 1000000) {
            displayText =
                "\$${(bubble.model.volume / 1000000).toStringAsFixed(1)}M";
          } else {
            displayText = "\$${bubble.model.volume}";
          }
          break;
        case "Market Cap":
          if (bubble.model.marketcap >= 1000000000) {
            displayText =
                "\$${(bubble.model.marketcap / 1000000000).toStringAsFixed(1)}B";
          } else if (bubble.model.marketcap >= 1000000) {
            displayText =
                "\$${(bubble.model.marketcap / 1000000).toStringAsFixed(1)}M";
          } else {
            displayText = "\$${bubble.model.marketcap}";
          }
          break;
        default:
          displayText = bubble.model.symbol;
      }

      // Draw the coin image or fallback text.
      ui.Image? coinImage = imageCache[bubble.model.id];
      if (coinImage != null) {
        final imageSize = bubble.size * 0.6;
        final imageRect = Rect.fromCenter(
          center: bubble.currentPosition,
          width: imageSize,
          height: imageSize,
        );

        canvas.save();
        final clipPath = Path()..addOval(imageRect);
        canvas.clipPath(clipPath);

        try {
          paintImage(
            canvas: canvas,
            rect: imageRect,
            image: coinImage,
            fit: BoxFit.contain,
          );
        } catch (e) {
          debugPrint("Error painting image: $e");
          canvas.restore();
          _drawFallbackText(canvas, bubble, displayText);
        }
        canvas.restore();

        final borderPaint = Paint()
          ..color = Colors.white.withOpacity(0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawCircle(bubble.currentPosition, imageSize / 2, borderPaint);
      } else {
        _drawFallbackText(canvas, bubble, displayText);
      }

      _drawEnhancedPerformanceText(canvas, bubble, performance);
    }
  }

  void _drawGridLines(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 0.5;
    const gridSpacing = 50.0;
    for (double x = 0; x <= size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawFallbackText(Canvas canvas, Bubble bubble, String text) {
    final bgPaint = Paint()..color = Colors.white.withOpacity(0.1);
    canvas.drawCircle(bubble.currentPosition, bubble.size * 0.3, bgPaint);

    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: bubble.size / 5,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.6),
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
      bubble.currentPosition - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  void _drawEnhancedPerformanceText(Canvas canvas, Bubble bubble, double performance) {
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: bubble.currentPosition + Offset(0, bubble.size * 0.3),
        width: bubble.size * 0.7,
        height: bubble.size * 0.2,
      ),
      Radius.circular(bubble.size * 0.1),
    );

    final bgPaint = Paint()
      ..color = performance >= 0
          ? Colors.green.withOpacity(0.7)
          : Colors.red.withOpacity(0.7);

    canvas.drawRRect(bgRect, bgPaint);

    final TextPainter percentagePainter = TextPainter(
      text: TextSpan(
        text: "${performance.toStringAsFixed(1)}%",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: bubble.size / 8,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.7),
              offset: const Offset(1, 1),
              blurRadius: 1,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    percentagePainter.layout();
    percentagePainter.paint(
      canvas,
      bubble.currentPosition + Offset(-percentagePainter.width / 2, bubble.size * 0.25),
    );

    final arrowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final arrowPath = Path();
    if (performance >= 0) {
      arrowPath.moveTo(bubble.currentPosition.dx - 5, bubble.currentPosition.dy + bubble.size * 0.37);
      arrowPath.lineTo(bubble.currentPosition.dx + 5, bubble.currentPosition.dy + bubble.size * 0.37);
      arrowPath.lineTo(bubble.currentPosition.dx, bubble.currentPosition.dy + bubble.size * 0.32);
      arrowPath.close();
    } else {
      arrowPath.moveTo(bubble.currentPosition.dx - 5, bubble.currentPosition.dy + bubble.size * 0.32);
      arrowPath.lineTo(bubble.currentPosition.dx + 5, bubble.currentPosition.dy + bubble.size * 0.32);
      arrowPath.lineTo(bubble.currentPosition.dx, bubble.currentPosition.dy + bubble.size * 0.37);
      arrowPath.close();
    }
    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
