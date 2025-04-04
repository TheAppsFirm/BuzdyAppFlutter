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

  Widget _buildDetailRow(String label, String value, IconData icon, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 22),
          const SizedBox(width: 12),
          Text("$label:", style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500, fontSize: 16)),
          const Spacer(),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    double performance = bubble.model.performance[selectedTimeframe] ?? 0.0;

    return AlertDialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (imageCache.containsKey(bubble.model.id))
            Container(
              width: 48,
              height: 48,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ClipOval(child: RawImage(image: imageCache[bubble.model.id], fit: BoxFit.contain)),
            ),
          Flexible(
            child: Text(
              bubble.model.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
        ],
      ),
      content: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow("Symbol", bubble.model.symbol, Icons.label_outline),
            const Divider(color: Colors.white24),
            _buildDetailRow("Price", "\$${bubble.model.price.toStringAsFixed(2)}", Icons.attach_money),
            const Divider(color: Colors.white24),
            _buildDetailRow("${selectedTimeframe[0].toUpperCase()}${selectedTimeframe.substring(1)} Change", "${performance.toStringAsFixed(2)}%",
                Icons.timeline,
                valueColor: performance > 0 ? Colors.green[400] : Colors.red[400]),
            const Divider(color: Colors.white24),
            _buildDetailRow("Market Cap", "\$${formatLargeNumber(bubble.model.marketcap)}", Icons.equalizer),
            const Divider(color: Colors.white24),
            _buildDetailRow("Rank", "#${bubble.model.rank}", Icons.military_tech),
            const Divider(color: Colors.white24),
            _buildDetailRow("Volume", "\$${formatLargeNumber(bubble.model.volume)}", Icons.bar_chart),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: Colors.blueAccent,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            elevation: 3,
          ),
          child: const Text("Close", style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ],
    );
  }
}