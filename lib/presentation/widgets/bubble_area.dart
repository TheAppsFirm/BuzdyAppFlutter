import 'dart:ui' as ui;
import 'package:buzdy/core/enhanced_bubble_painter.dart';
import 'package:buzdy/data/models/bubble.dart';
import 'package:flutter/material.dart';

class BubbleArea extends StatefulWidget {
  final List<Bubble> bubbles;
  final bool isLoading;
  final String? errorMessage;
  final String selectedTimeframe;
  final Map<String, ui.Image> imageCache;
  final String sortBy;
  final AnimationController controller;
  final Duration bubbleAnimationDuration;
  final Function(Offset) onTapBubble;
  final Function() onRetry;
  final Function() onResetFilters;
  final double filterPanelHeight;
  final double bottomNavHeight;

  const BubbleArea({
    Key? key,
    required this.bubbles,
    required this.isLoading,
    required this.errorMessage,
    required this.selectedTimeframe,
    required this.imageCache,
    required this.sortBy,
    required this.controller,
    required this.bubbleAnimationDuration,
    required this.onTapBubble,
    required this.onRetry,
    required this.onResetFilters,
    required this.filterPanelHeight,
    required this.bottomNavHeight,
  }) : super(key: key);

  @override
  _BubbleAreaState createState() => _BubbleAreaState();
}

class _BubbleAreaState extends State<BubbleArea>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    final visibleHeight = screenSize.height - widget.filterPanelHeight - padding.bottom;
    final visibleRect = Rect.fromLTWH(
      0,
      widget.filterPanelHeight,
      screenSize.width,
      visibleHeight,
    );

    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [Color(0xFF1A1A2E), Colors.black],
          stops: [0.0, 1.0],
        ),
      ),
      child: Stack(
        children: [
          CustomPaint(
            size: Size(screenSize.width, visibleHeight),
            painter: GridBackgroundPainter(),
          ),
          // Show loading indicator
          if (widget.isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.blueAccent,
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading bubbles...',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            )
          // Show error if present
          else if (widget.errorMessage != null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.errorMessage!,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: widget.onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry', style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          // After loading, always show bubble area (even if the bubble list is empty)
          else
            GestureDetector(
              onTapUp: (details) => widget.onTapBubble(details.localPosition),
              child: AnimatedBuilder(
                animation:
                    Listenable.merge([widget.controller, _glowController]),
                builder: (context, _) => CustomPaint(
                  size: Size(screenSize.width, visibleHeight),
                  painter: EnhancedBubblePainter(
                    bubbles: widget.bubbles,
                    timeframe: widget.selectedTimeframe,
                    imageCache: widget.imageCache,
                    sortBy: widget.sortBy,
                    visibleRect: visibleRect,
                    animationValue: _glowAnimation.value,
                  ),
                ),
              ),
            ),
          // Bubble count indicator – displayed when not loading and there is at least one coin
          if (!widget.isLoading && widget.bubbles.isNotEmpty)
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bubble_chart,
                      size: 18,
                      color: Colors.blueAccent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${widget.bubbles.length} coins",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class GridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 0.5;

    const double gridSize = 50.0;

    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
