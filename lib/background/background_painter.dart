import 'package:flutter/material.dart';
import 'dart:math' as math;

class BackgroundPainter extends CustomPainter {
  final double animationValue;
  final double particleValue;

  final List<Color> colors = [
    const Color(0xFFC0C0C0), // Silver
    const Color(0xFFFFB974), // Orange
    const Color(0xFF9C89FF), // Purple
    const Color(0xFF89FFDD), // Mint
    const Color(0xFFFF89B4), // Pink
    const Color(0xFF89FF98), // Green
  ];

  BackgroundPainter(this.animationValue, this.particleValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.srcOver;

    // Create animated gradient background
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Calculate color indices based on animation value
    int colorIndex1 = (animationValue * colors.length).floor();
    int colorIndex2 = (colorIndex1 + 1) % colors.length;
    int colorIndex3 = (colorIndex1 + 2) % colors.length;

    // Calculate interpolation factor
    double t = (animationValue * colors.length) - colorIndex1;

    // Create smooth color transitions
    final gradient = LinearGradient(
      begin: Alignment(
        math.cos(animationValue * 2 * math.pi),
        math.sin(animationValue * 2 * math.pi),
      ),
      end: Alignment(
        math.cos((animationValue + 0.5) * 2 * math.pi),
        math.sin((animationValue + 0.5) * 2 * math.pi),
      ),
      colors: [
        Color.lerp(colors[colorIndex1], colors[colorIndex2], t)!,
        Color.lerp(colors[colorIndex2], colors[colorIndex3], t)!,
        colors[colorIndex3],
      ],
      stops: [0.0, 0.5, 1.0],
    );

    paint.shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // Add floating particles with varying sizes and opacity
    for (var i = 0; i < 100; i++) {
      final progress = (particleValue + i / 100) % 1.0;
      final size1 = (i % 4 + 1) * 2.0;

      final particlePaint = Paint()
        ..color = colors[i % colors.length].withOpacity(0.3)
        ..style = PaintingStyle.fill;

      // Create smooth circular motion with varying radiuses
      final radius = size.width * (0.2 + (i % 3) * 0.1);
      final x = size.width / 2 + math.cos(progress * 2 * math.pi + i) * radius;
      final y = size.height / 2 + math.sin(progress * 2 * math.pi + i) * radius;

      canvas.drawCircle(Offset(x, y), size1, particlePaint);
    }
  }

  @override
  bool shouldRepaint(BackgroundPainter oldDelegate) =>
      animationValue != oldDelegate.animationValue ||
      particleValue != oldDelegate.particleValue;
}
