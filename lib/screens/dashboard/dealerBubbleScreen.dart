import 'dart:math';
import 'package:flutter/material.dart';
import 'package:buzdy/views/customText.dart'; // Assuming you have this widget
import 'package:buzdy/views/colors.dart'; // Assuming you have this widget

class DealerBubbleScreen extends StatelessWidget {
  final List<Map<String, dynamic>> dealers = [
    {
      "name": "Amazon",
      "percentage": "+10%",
      "size": 120.0,
      "color": Colors.green
    },
    {"name": "Ebay", "percentage": "+15%", "size": 140.0, "color": Colors.blue},
    {
      "name": "Walmart",
      "percentage": "-5%",
      "size": 100.0,
      "color": Colors.red
    },
    {
      "name": "BestBuy",
      "percentage": "+8%",
      "size": 110.0,
      "color": Colors.purple
    },
    {
      "name": "Target",
      "percentage": "+12%",
      "size": 130.0,
      "color": Colors.orange
    },
    {
      "name": "Amazon",
      "percentage": "+10%",
      "size": 120.0,
      "color": Colors.green
    },
    {"name": "Ebay", "percentage": "+15%", "size": 140.0, "color": Colors.blue},
    {
      "name": "Walmart",
      "percentage": "-5%",
      "size": 100.0,
      "color": Colors.red
    },
    {
      "name": "BestBuy",
      "percentage": "+8%",
      "size": 110.0,
      "color": Colors.purple
    },
    {
      "name": "Target",
      "percentage": "+12%",
      "size": 130.0,
      "color": Colors.orange
    },
    {
      "name": "Costco",
      "percentage": "-2%",
      "size": 90.0,
      "color": Colors.yellow
    },
    {
      "name": "Kroger",
      "percentage": "+6%",
      "size": 115.0,
      "color": Colors.teal
    },
    {"name": "Ebay", "percentage": "+15%", "size": 140.0, "color": Colors.blue},
    {
      "name": "Walmart",
      "percentage": "-5%",
      "size": 100.0,
      "color": Colors.red
    },
    {
      "name": "BestBuy",
      "percentage": "+8%",
      "size": 110.0,
      "color": Colors.purple
    },
  ];

  DealerBubbleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: kText(
          text: "Dealers",
          fSize: 20,
          fWeight: FontWeight.bold,
          tColor: whiteColor,
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: dealers.map((dealer) {
          final random = Random();
          final bubbleLeft =
              random.nextDouble() * (screenWidth - dealer["size"]);
          final bubbleTop =
              random.nextDouble() * (screenHeight - dealer["size"]);

          return Positioned(
            left: bubbleLeft,
            top: bubbleTop,
            child: DealerBubble(
              name: dealer["name"],
              percentage: dealer["percentage"],
              size: dealer["size"],
              color: dealer["color"],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class DealerBubble extends StatelessWidget {
  final String name;
  final String percentage;
  final double size;
  final Color color;

  const DealerBubble({
    super.key,
    required this.name,
    required this.percentage,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to details or show more info
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: kText(text: "Clicked on $name", tColor: whiteColor)),
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.8),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 3,
            )
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              kText(
                text: name,
                fSize: size * 0.2,
                fWeight: FontWeight.bold,
                tColor: whiteColor,
              ),
              SizedBox(height: 4),
              kText(
                text: percentage,
                fSize: size * 0.15,
                fWeight: FontWeight.w600,
                tColor: whiteColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
