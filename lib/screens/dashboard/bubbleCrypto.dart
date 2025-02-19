import 'dart:math';
import 'package:flutter/material.dart';

class DealsScreen extends StatefulWidget {
  @override
  State<DealsScreen> createState() => _DealsScreenState();
}

class _DealsScreenState extends State<DealsScreen>
    with SingleTickerProviderStateMixin {
  final Random _random = Random();
  late AnimationController _controller;

  final List<Map<String, dynamic>> cryptoCoins = List.generate(60, (index) {
    final randomPercentage = (Random().nextDouble() * 20 - 10);
    return {
      "name": "Coin $index",
      "symbol": "C$index",
      "priceChange": randomPercentage,
      "price": "\$${(randomPercentage * 1000).toStringAsFixed(2)}",
      "description": "This is a sample description for Coin $index."
    };
  });

  List<Bubble> bubbles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 16),
    )..repeat();

    _controller.addListener(() {
      _updateBubblePositions();
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenSize = MediaQuery.of(context).size;
      bubbles = _generateBubbles(screenSize);
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Bubble> _generateBubbles(Size screenSize) {
    final List<Bubble> bubbles = [];
    const double padding = 20;

    for (final coin in cryptoCoins) {
      final bubbleSize = max((screenSize.width / 20),
          (screenSize.width / 20) + (coin["priceChange"] as double).abs() * 5);

      Offset position;
      bool overlaps;

      do {
        overlaps = false;
        position = Offset(
          padding + _random.nextDouble() * (screenSize.width - 2 * padding),
          padding + _random.nextDouble() * (screenSize.height - 2 * padding),
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
        origin: position,
        currentPosition: position,
        size: bubbleSize,
        data: coin,
        velocity: Offset(
          (_random.nextDouble() * 2 - 1) * 0.5,
          (_random.nextDouble() * 2 - 1) * 0.5,
        ),
      ));
    }
    return bubbles;
  }

  void _updateBubblePositions() {
    for (final bubble in bubbles) {
      final newPosition = bubble.currentPosition + bubble.velocity;

      if ((newPosition - bubble.origin).distance > bubble.size / 4) {
        bubble.velocity = -bubble.velocity;
      }

      bubble.currentPosition = newPosition;
    }
  }

  /// **Detect which bubble was tapped**
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
            bubble.data["name"] ?? "Unknown Coin", // Default value if null
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Symbol: ${bubble.data["symbol"] ?? "N/A"}"),
              Text("Price: ${bubble.data["price"] ?? "N/A"}"),
              Text(
                "Change: ${bubble.data["priceChange"]?.toStringAsFixed(1) ?? "0"}%",
                style: TextStyle(
                  color: (bubble.data["priceChange"] ?? 0) > 0
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                bubble.data["description"] ?? "No description available.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
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

class Bubble {
  final Offset origin;
  Offset currentPosition;
  double size;
  Offset velocity;
  Map<String, dynamic> data;

  Bubble({
    required this.origin,
    required this.currentPosition,
    required this.size,
    required this.velocity,
    required this.data,
  });
}

class BubblePainter extends CustomPainter {
  final List<Bubble> bubbles;

  BubblePainter({required this.bubbles});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;

    for (final bubble in bubbles) {
      paint.color = bubble.data["priceChange"] > 0
          ? Colors.green.withOpacity(0.6)
          : Colors.red.withOpacity(0.6);

      canvas.drawCircle(bubble.currentPosition, bubble.size / 2, paint);

      final TextPainter symbolPainter = TextPainter(
        text: TextSpan(
          text: bubble.data["symbol"],
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: bubble.size / 6,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      symbolPainter.layout();
      symbolPainter.paint(
        canvas,
        bubble.currentPosition -
            Offset(symbolPainter.width / 2, symbolPainter.height),
      );

      final TextPainter percentagePainter = TextPainter(
        text: TextSpan(
          text: "${bubble.data["priceChange"].toStringAsFixed(1)}%",
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
        bubble.currentPosition -
            Offset(percentagePainter.width / 2, -symbolPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
