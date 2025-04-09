import 'dart:ui' as ui;
import 'package:buzdy/core/utils.dart';
import 'package:buzdy/data/models/bubble.dart';
import 'package:flutter/material.dart';

class BubbleDetailsDialog extends StatelessWidget {
  final Bubble bubble;
  final String selectedTimeframe;
  final Map<String, ui.Image> imageCache;

  const BubbleDetailsDialog({
    Key? key,
    required this.bubble,
    required this.selectedTimeframe,
    required this.imageCache,
  }) : super(key: key);

  String formatPrice(double price) {
    // For very small prices, show up to 6 significant digits
    if (price < 1) {
      return price.toStringAsFixed(6).replaceAll(RegExp(r'([.]*0)(?!.*\d)'), '');
    }
    // For larger prices, show 2 decimal places
    return price.toStringAsFixed(2).replaceAll(RegExp(r'([.]*0)(?!.*\d)'), '');
  }

  Widget _buildDetailRow(String label, String value, IconData icon, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$label:",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double performance = bubble.model.performance[selectedTimeframe] ?? 0.0;

    return AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      content: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey[900]!,
              Colors.grey[850]!,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (imageCache.containsKey(bubble.model.id))
                    Container(
                      width: 48,
                      height: 48,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.2),
                            Colors.white.withOpacity(0.05),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: RawImage(
                          image: imageCache[bubble.model.id],
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  Flexible(
                    child: Text(
                      bubble.model.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildDetailRow("Symbol", bubble.model.symbol, Icons.label_outline),
                  const Divider(color: Colors.white24, height: 1),
                  _buildDetailRow("Price", "\$${formatPrice(bubble.model.price)}", Icons.attach_money),
                  const Divider(color: Colors.white24, height: 1),
                  _buildDetailRow(
                    "${selectedTimeframe[0].toUpperCase()}${selectedTimeframe.substring(1)} Change",
                    "${performance.toStringAsFixed(2)}%",
                    Icons.timeline,
                    valueColor: performance > 0 ? Colors.green[400] : Colors.red[400],
                  ),
                  const Divider(color: Colors.white24, height: 1),
                  _buildDetailRow("Market Cap", "\$${formatLargeNumber(bubble.model.marketcap)}", Icons.equalizer),
                  const Divider(color: Colors.white24, height: 1),
                  _buildDetailRow("Rank", "#${bubble.model.rank}", Icons.military_tech),
                  const Divider(color: Colors.white24, height: 1),
                  _buildDetailRow("Volume", "\$${formatLargeNumber(bubble.model.volume)}", Icons.bar_chart),
                ],
              ),
            ),
            // Actions Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  elevation: 5,
                  shadowColor: Colors.black45,
                ),
                child: const Text(
                  "Close",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}