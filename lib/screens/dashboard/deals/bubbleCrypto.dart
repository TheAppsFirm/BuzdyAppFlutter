import 'dart:math';
import 'package:buzdy/screens/dashboard/deals/model.dart/bubbleCoinModel.dart';
import 'package:buzdy/screens/provider/UserViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DealsScreen extends StatefulWidget {
  const DealsScreen({super.key});

  @override
  State<DealsScreen> createState() => _DealsScreenState();
}

class _DealsScreenState extends State<DealsScreen>
    with SingleTickerProviderStateMixin {
  final Random _random = Random();
  late AnimationController _controller;
  List<Bubble> bubbles = [];

  @override
  void initState() {
    super.initState();
    UserViewModel pr = Provider.of<UserViewModel>(context, listen: false);

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 50),
    )..repeat();

    _controller.addListener(() {
      _updateBubblePositions();
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenSize = MediaQuery.of(context).size;
      setState(() {
        bubbles = _generateBubbles(screenSize, pr.bubbleCoins);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// **Generates Crypto Bubbles with Peak Size Limit & Bottom Padding**
  List<Bubble> _generateBubbles(
      Size screenSize, List<BubbleCoinModel> bubbleCoins) {
    final List<Bubble> bubbles = [];
    const double padding = 20;
    const double bottomPadding = 200; // Ensure no bubbles are too low

    for (final coin in bubbleCoins) {
      // **Calculate Bubble Size Based on Hourly Change**
      double hourlyChange = coin.performance["hour"] ?? 0.0;
      double baseSize = screenSize.width / 12; // Slightly increased base size
      double adjustedSize = baseSize + hourlyChange.abs() * 15;

      // **Ensure Peak Size is Limited to Avoid Overly Large Bubbles**
      double bubbleSize = max(baseSize * 1.2, adjustedSize);
      bubbleSize = min(
          bubbleSize, screenSize.width / 5); // Max limit for extreme changes

      Offset position;
      bool overlaps;

      // **Ensure bubbles do not overlap & have bottom padding**
      do {
        overlaps = false;
        position = Offset(
          padding + _random.nextDouble() * (screenSize.width - 2 * padding),
          padding +
              _random.nextDouble() *
                  (screenSize.height -
                      2 * padding -
                      bottomPadding), // Apply bottom padding
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

  /// **Smooth Bubble Floating Animation**
  void _updateBubblePositions() {
    for (final bubble in bubbles) {
      final newPosition = bubble.currentPosition + bubble.velocity;

      if ((newPosition - bubble.origin).distance > bubble.size / 5) {
        bubble.velocity = -bubble.velocity;
      }
      bubble.currentPosition = newPosition;
    }
  }

  /// **Detect Tapped Bubble & Show Details**
  void _onTapBubble(Offset tapPosition) {
    for (final bubble in bubbles) {
      final distance = (tapPosition - bubble.currentPosition).distance;
      if (distance < bubble.size / 2) {
        _showBubbleDetails(bubble);
        break;
      }
    }
  }

  /// **Show Bubble Details in Dialog**
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

/// **Bubble Model**
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

/// **Bubble Painter - Draws Crypto Bubbles**
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

      // **Draw the bubble**
      canvas.drawCircle(bubble.currentPosition, bubble.size / 2, paint);

      // **Draw coin symbol inside the bubble**
      final TextPainter symbolPainter = TextPainter(
        text: TextSpan(
          text: bubble.model.symbol,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: bubble.size / 5, // Increased font size
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      symbolPainter.layout();
      symbolPainter.paint(
        canvas,
        bubble.currentPosition -
            Offset(symbolPainter.width / 2, symbolPainter.height / 2),
      );

      // **Draw hourly performance percentage below symbol**
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
        bubble.currentPosition +
            Offset(-percentagePainter.width / 2, symbolPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
