import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:buzdy/core/utils.dart';
import 'package:buzdy/data/models/bubble.dart';
import 'package:flutter/material.dart';

class EnhancedBubblePainter extends CustomPainter {
  final List<Bubble> bubbles;
  final String timeframe;
  final Map<String, ui.Image> imageCache;
  final String sortBy;
  final Rect visibleRect;
  final double animationValue;

  EnhancedBubblePainter({
    required this.bubbles,
    required this.timeframe,
    required this.imageCache,
    required this.sortBy,
    required this.visibleRect,
    this.animationValue = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(visibleRect);

    for (final bubble in bubbles) {
      final bubbleRect = Rect.fromCircle(
        center: bubble.currentPosition,
        radius: bubble.size / 2,
      );
      if (!visibleRect.overlaps(bubbleRect)) continue;

      final coin = bubble.model;
      final performance = coin.performance[timeframe] ?? 0.0;
      final isSignificant = performance.abs() > 5.0;
      final double radius = bubble.size / 2;

      // Main gradient fill using a radial gradient.
      final gradient = RadialGradient(
        center: Alignment.center,
        radius: 0.9,
        colors: [
          performance >= 0
              ? Colors.green.shade800.withOpacity(0.5)
              : Colors.red.shade800.withOpacity(0.5),
          performance >= 0
              ? Colors.green.shade500.withOpacity(0.2)
              : Colors.red.shade500.withOpacity(0.2),
        ],
        stops: const [0.2, 1.0],
      );
      final mainPaint = Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(center: bubble.currentPosition, radius: radius),
        )
        ..style = PaintingStyle.fill;

      // Glow effect around the bubble.
      final glowOpacity = isSignificant
          ? 0.2 + 0.1 * (1 + math.sin(animationValue * 2 * math.pi))
          : 0.2;
      final glowPaint = Paint()
        ..color = (performance >= 0 ? Colors.green : Colors.red).withOpacity(glowOpacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, bubble.size * 0.1);

      // Shadow layers.
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
      final innerShadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

      // Border around the bubble.
      final borderOpacity = isSignificant
          ? 0.5 + 0.2 * (1 + math.sin(animationValue * 2 * math.pi))
          : 0.5;
      final borderPaint = Paint()
        ..color = (performance >= 0 ? Colors.greenAccent : Colors.redAccent).withOpacity(borderOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      // Draw layers in order.
      canvas.drawCircle(bubble.currentPosition, radius + 4, glowPaint);
      canvas.drawCircle(bubble.currentPosition, radius + 2, shadowPaint);
      canvas.drawCircle(bubble.currentPosition, radius, mainPaint);
      canvas.drawCircle(bubble.currentPosition, radius - 2, innerShadowPaint);
      canvas.drawCircle(bubble.currentPosition, radius, borderPaint);

      // Define bubble boundaries.
      final bubbleTop = bubble.currentPosition.dy - bubble.size / 2;
      final bubbleBottom = bubble.currentPosition.dy + bubble.size / 2;

      // Calculate font sizes based on bubble size.
      final double baseFontSize = bubble.size * 0.12;
      final double minFontSize = 6.0;
      final bool isLargeBubble = bubble.size >= 80;
      final double coinNameFontSize = baseFontSize.clamp(minFontSize, 14.0);
      final double sortValueFontSize = (baseFontSize * 0.8).clamp(minFontSize * 0.8, 12.0);
      final double performanceFontSize = (baseFontSize * 0.9).clamp(minFontSize * 0.9, 12.0);
      final double symbolFontSize = (baseFontSize * 1.1).clamp(minFontSize * 1.1, 14.0);

      // Calculate image size for the coin logo.
      final double baseImageSize = bubble.size * 0.3;
      final double minImageSize = 10.0;
      final double imageSize = baseImageSize.clamp(minImageSize, 40.0);

      // Draw coin image (or placeholder) in the upper half.
      final imageTopOffset = bubbleTop + bubble.size * 0.2;
      if (imageCache.containsKey(coin.id)) {
        final image = imageCache[coin.id]!;
        final srcRect = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
        final dstRect = Rect.fromLTWH(
          bubble.currentPosition.dx - imageSize / 2,
          imageTopOffset,
          imageSize,
          imageSize,
        );
        canvas.drawImageRect(image, srcRect, dstRect, Paint());
      } else {
        final placeholderGradient = RadialGradient(
          center: Alignment.center,
          radius: 0.9,
          colors: [
            Colors.grey.shade600.withOpacity(0.5),
            Colors.grey.shade400.withOpacity(0.2),
          ],
          stops: const [0.2, 1.0],
        );
        final placeholderPaint = Paint()
          ..shader = placeholderGradient.createShader(
            Rect.fromCircle(center: bubble.currentPosition, radius: bubble.size * 0.4),
          )
          ..style = PaintingStyle.fill;
        canvas.drawCircle(bubble.currentPosition, bubble.size * 0.4, placeholderPaint);
        final placeholderText = ui.ParagraphBuilder(ui.ParagraphStyle(
          textAlign: TextAlign.center,
          fontSize: coinNameFontSize,
          fontWeight: FontWeight.bold,
          textDirection: TextDirection.ltr,
        ))
          ..pushStyle(ui.TextStyle(
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.7),
                offset: const Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ))
          ..addText(coin.symbol.toUpperCase());
        final placeholderParagraph = placeholderText.build()
          ..layout(const ui.ParagraphConstraints(width: double.infinity));
        canvas.drawParagraph(
          placeholderParagraph,
          Offset(
            bubble.currentPosition.dx - placeholderParagraph.width / 2,
            bubble.currentPosition.dy - placeholderParagraph.height / 2,
          ),
        );
      }

      // Text layout: leave extra bottom margin so the last line does not touch the bubble boundary.
      final imageBottom = imageTopOffset + imageSize;
      final double bottomMargin = bubble.size * 0.1;
      final double availableTextSpace = bubbleBottom - imageBottom - bottomMargin;
      final double padding = bubble.size * 0.05;

      if (isLargeBubble) {
        // Large bubbles: show coin name, sort value, and performance.
        final coinNameTextPainter = TextPainter(
          text: TextSpan(
            text: coin.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: coinNameFontSize,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.7),
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        coinNameTextPainter.layout(maxWidth: bubble.size * 0.9);
        final coinNameHeight = coinNameTextPainter.height;

        String sortValue = "";
        if (sortBy == "Rank") {
          sortValue = "#${coin.rank}";
        } else if (sortBy == "Price") {
          sortValue = "\$${coin.price.toStringAsFixed(2)}";
        } else if (sortBy == "Volume") {
          sortValue = "\$${formatLargeNumber(coin.volume)}";
        } else if (sortBy == "Market Cap") {
          sortValue = "\$${formatLargeNumber(coin.marketcap)}";
        }
        final sortTextPainter = TextPainter(
          text: TextSpan(
            text: sortValue,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: sortValueFontSize,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.7),
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        sortTextPainter.layout(maxWidth: bubble.size * 0.9);
        final sortValueHeight = sortTextPainter.height;

        final performanceTextPainter = TextPainter(
          text: TextSpan(
            text: '${performance >= 0 ? '+' : ''}${performance.toStringAsFixed(1)}%',
            style: TextStyle(
              color: performance >= 0 ? Colors.greenAccent.shade100 : Colors.redAccent.shade100,
              fontSize: performanceFontSize,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.7),
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        performanceTextPainter.layout(maxWidth: bubble.size * 0.9);
        final performanceHeight = performanceTextPainter.height;

        final totalTextHeight = coinNameHeight + sortValueHeight + performanceHeight + 2 * padding;
        final textSpaceRatio = availableTextSpace / totalTextHeight;
        final scaleFactor = math.min(1.0, textSpaceRatio);

        final coinNameTop = imageBottom + padding * scaleFactor;
        coinNameTextPainter.paint(
          canvas,
          Offset(
            bubble.currentPosition.dx - coinNameTextPainter.width / 2,
            math.min(coinNameTop, bubbleBottom - totalTextHeight - bottomMargin),
          ),
        );

        final sortValueTop = coinNameTop + coinNameHeight + padding * scaleFactor;
        sortTextPainter.paint(
          canvas,
          Offset(
            bubble.currentPosition.dx - sortTextPainter.width / 2,
            math.min(sortValueTop, bubbleBottom - performanceHeight - sortValueHeight - bottomMargin - padding),
          ),
        );

        final performanceTop = sortValueTop + sortValueHeight + padding * scaleFactor;
        performanceTextPainter.paint(
          canvas,
          Offset(
            bubble.currentPosition.dx - performanceTextPainter.width / 2,
            math.min(performanceTop, bubbleBottom - performanceHeight - bottomMargin),
          ),
        );
      } else {
        // Small bubbles: show coin symbol, sort value, and performance.
        final symbolTextPainter = TextPainter(
          text: TextSpan(
            text: coin.symbol.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontSize: symbolFontSize,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.7),
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        symbolTextPainter.layout(maxWidth: bubble.size * 0.9);
        final symbolHeight = symbolTextPainter.height;

        String sortValue = "";
        if (sortBy == "Rank") {
          sortValue = "#${coin.rank}";
        } else if (sortBy == "Price") {
          sortValue = "\$${coin.price.toStringAsFixed(2)}";
        } else if (sortBy == "Volume") {
          sortValue = "\$${formatLargeNumber(coin.volume)}";
        } else if (sortBy == "Market Cap") {
          sortValue = "\$${formatLargeNumber(coin.marketcap)}";
        }
        final sortValueTextPainter = TextPainter(
          text: TextSpan(
            text: sortValue,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: sortValueFontSize,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.7),
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        sortValueTextPainter.layout(maxWidth: bubble.size * 0.9);
        final sortValueHeight = sortValueTextPainter.height;

        final performanceTextPainter = TextPainter(
          text: TextSpan(
            text: '${performance >= 0 ? '+' : ''}${performance.toStringAsFixed(1)}%',
            style: TextStyle(
              color: performance >= 0 ? Colors.greenAccent.shade100 : Colors.redAccent.shade100,
              fontSize: performanceFontSize,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.7),
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        performanceTextPainter.layout(maxWidth: bubble.size * 0.9);
        final performanceHeight = performanceTextPainter.height;

        final totalTextHeight = symbolHeight + sortValueHeight + performanceHeight + 2 * padding;
        final textSpaceRatio = availableTextSpace / totalTextHeight;
        final scaleFactor = math.min(1.0, textSpaceRatio);

        final symbolTop = imageBottom + padding * scaleFactor;
        symbolTextPainter.paint(
          canvas,
          Offset(
            bubble.currentPosition.dx - symbolTextPainter.width / 2,
            math.min(symbolTop, bubbleBottom - totalTextHeight - bottomMargin),
          ),
        );

        final sortValueTop = symbolTop + symbolHeight + padding * scaleFactor;
        sortValueTextPainter.paint(
          canvas,
          Offset(
            bubble.currentPosition.dx - sortValueTextPainter.width / 2,
            math.min(sortValueTop, bubbleBottom - performanceHeight - sortValueHeight - bottomMargin - padding),
          ),
        );

        final performanceTop = sortValueTop + sortValueHeight + padding * scaleFactor;
        performanceTextPainter.paint(
          canvas,
          Offset(
            bubble.currentPosition.dx - performanceTextPainter.width / 2,
            math.min(performanceTop, bubbleBottom - performanceHeight - bottomMargin),
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant EnhancedBubblePainter oldDelegate) {
    return true;
  }
}
