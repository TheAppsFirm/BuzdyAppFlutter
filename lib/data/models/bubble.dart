import 'dart:ui';
import 'package:buzdy/presentation/screens/dashboard/crypto/model.dart/bubbleCoinModel.dart';

class Bubble {
  final BubbleCoinModel model;
  Offset origin;
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