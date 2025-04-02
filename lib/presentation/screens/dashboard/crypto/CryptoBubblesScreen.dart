import 'dart:math';
import 'package:buzdy/presentation/screens/dashboard/crypto/model.dart/bubbleCoinModel.dart';
import 'package:buzdy/presentation/viewmodels/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CryptoBubblesScreen extends StatefulWidget {
  const CryptoBubblesScreen({super.key});

  @override
  State<CryptoBubblesScreen> createState() => _CryptoBubblesScreenState();
}

class _CryptoBubblesScreenState extends State<CryptoBubblesScreen>
    with SingleTickerProviderStateMixin {
  final Random _random = Random();
  late AnimationController _controller;
  List<Bubble> bubbles = [];

  @override
  void initState() {
    super.initState();
    UserViewModel userVM = Provider.of<UserViewModel>(context, listen: false);

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 50),
    )..repeat();

    _controller.addListener(() {
      _updateBubblePositions();
      setState(() {});
    });

    // Generate bubbles after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenSize = MediaQuery.of(context).size;
      setState(() {
        bubbles = _generateBubbles(screenSize, userVM.bubbleCoins);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Generates crypto bubbles with a peak size limit and bottom padding.
  List<Bubble> _generateBubbles(
      Size screenSize, List<BubbleCoinModel> bubbleCoins) {
    final List<Bubble> bubbles = [];
    const double padding = 20;
    const double bottomPadding = 200; // Ensure no bubbles are too low

    for (final coin in bubbleCoins) {
      // Calculate bubble size based on hourly change.
      double hourlyChange = coin.performance["hour"] ?? 0.0;
      double baseSize = screenSize.width / 12; // Slightly increased base size
      double adjustedSize = baseSize + hourlyChange.abs() * 15;

      // Ensure peak size is limited to avoid overly large bubbles.
      double bubbleSize = max(baseSize * 1.2, adjustedSize);
      bubbleSize = min(bubbleSize, screenSize.width / 5); // Max limit

      Offset position;
      bool overlaps;

      // Ensure bubbles do not overlap and apply bottom padding.
      do {
        overlaps = false;
        position = Offset(
          padding + _random.nextDouble() * (screenSize.width - 2 * padding),
          padding +
              _random.nextDouble() *
                  (screenSize.height - 2 * padding - bottomPadding),
        );

        for (final other in bubbles) {
          final distance = (position - other.origin).distance;
          if (distance < (bubbleSize / 2 + other.size / 2)) {
            overlaps = true;
            break;
          }
        }
      } while (overlaps);

      bubbles.add(Bubble(
        model: coin,
        origin: position,
        currentPosition: position,
        size: bubbleSize,
        velocity: Offset(
          (_random.nextDouble() * 2 - 1) * 0.4,
          (_random.nextDouble() * 2 - 1) * 0.4,
        ),
      ));
    }
    return bubbles;
  }

  /// Smooth bubble floating animation update.
  void _updateBubblePositions() {
    for (final bubble in bubbles) {
      final newPosition = bubble.currentPosition + bubble.velocity;
      if ((newPosition - bubble.origin).distance > bubble.size / 5) {
        bubble.velocity = -bubble.velocity;
      }
      bubble.currentPosition = newPosition;
    }
  }

  /// Detect tapped bubble and show details.
  void _onTapBubble(Offset tapPosition) {
    for (final bubble in bubbles) {
      final distance = (tapPosition - bubble.currentPosition).distance;
      if (distance < bubble.size / 2) {
        _showBubbleDetails(bubble);
        break;
      }
    }
  }

  /// Show bubble details in a dialog.
  void _showBubbleDetails(Bubble bubble) {
    double hourlyPerformance = bubble.model.performance["hour"] ?? 0.0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
            bubble.model.name,
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Symbol: ${bubble.model.symbol}",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Price: \$${bubble.model.price.toStringAsFixed(2)}"),
              Text(
                "Hourly Change: ${hourlyPerformance.toStringAsFixed(2)}%",
                style: TextStyle(
                  color: hourlyPerformance > 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text("Market Cap: \$${bubble.model.marketcap}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: GestureDetector(
        onTapDown: (details) {
          _onTapBubble(details.localPosition);
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: screenSize,
              painter: BubblePainter(bubbles: bubbles),
            );
          },
        ),
      ),
    );
  }
}

/// Bubble model for crypto bubbles.
class Bubble {
  final BubbleCoinModel model;
  final Offset origin;
  Offset currentPosition;
  double size;
  Offset velocity;

  Bubble({
    required this.model,
    required this.origin,
    required this.currentPosition,
    required this.size,
    required this.velocity,
  });
}

/// Custom painter to draw crypto bubbles.
class BubblePainter extends CustomPainter {
  final List<Bubble> bubbles;

  BubblePainter({required this.bubbles});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;

    for (final bubble in bubbles) {
      double hourlyPerformance = bubble.model.performance["hour"] ?? 0.0;
      paint.color = hourlyPerformance > 0
          ? Colors.green.withOpacity(0.7)
          : Colors.red.withOpacity(0.7);

      // Draw the bubble.
      canvas.drawCircle(bubble.currentPosition, bubble.size / 2, paint);

      // Draw coin symbol inside the bubble.
      final TextPainter symbolPainter = TextPainter(
        text: TextSpan(
          text: bubble.model.symbol,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: bubble.size / 5,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      symbolPainter.layout();
      symbolPainter.paint(
        canvas,
        bubble.currentPosition - Offset(symbolPainter.width / 2, symbolPainter.height / 2),
      );

      // Draw hourly performance percentage below the symbol.
      final TextPainter percentagePainter = TextPainter(
        text: TextSpan(
          text: "${hourlyPerformance.toStringAsFixed(1)}%",
          style: TextStyle(
            color: Colors.white,
            fontSize: bubble.size / 8,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      percentagePainter.layout();
      percentagePainter.paint(
        canvas,
        bubble.currentPosition + Offset(-percentagePainter.width / 2, symbolPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
