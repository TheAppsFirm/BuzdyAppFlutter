import 'package:flutter/material.dart';

class LineChart extends StatelessWidget {
  final List<double> data;
  const LineChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox(height: 100);
    final maxY = data.reduce((a,b) => a > b ? a : b);
    final minY = data.reduce((a,b) => a < b ? a : b);
    return SizedBox(
      height: 100,
      child: CustomPaint(
        painter: _LineChartPainter(data, minY, maxY),
        size: Size.infinite,
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> data;
  final double minY;
  final double maxY;
  _LineChartPainter(this.data, this.minY, this.maxY);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path();
    for (var i = 0; i < data.length; i++) {
      final x = i / (data.length - 1) * size.width;
      final y = size.height - ((data[i] - minY) / (maxY - minY)) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}
