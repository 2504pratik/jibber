import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedBackground extends StatelessWidget {
  final int height;
  const AnimatedBackground({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: List.generate(
              64, // Number of balls
              (index) => _FloatingBall(
                index: index,
                maxWidth: constraints.maxWidth,
                maxHeight: constraints.maxHeight,
                height: height,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FloatingBall extends StatelessWidget {
  final int index;
  final double maxWidth;
  final double maxHeight;
  final int height;

  const _FloatingBall({
    required this.index,
    required this.maxWidth,
    required this.maxHeight,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final random = Random(index);

    // Calculate vertical position with a focus on the top 75%
    double initialY;
    if (index < 75) {
      // 75 balls in the top 75%
      initialY = random.nextDouble() * (maxHeight * (height * 0.01));
    } else {
      return SizedBox(); // No balls below 75% height
    }

    // Smaller size range for more balls
    final size = random.nextDouble() * 6 + 3; // Size between 3-9
    final initialX = random.nextDouble() * (maxWidth - size);

    final verticalPosition = initialY / maxHeight;
    final moveDistance =
        (25 + random.nextDouble() * 15) * (1 - verticalPosition * 0.6);

    // Slightly faster base movement for more dynamic feel
    final baseDuration = random.nextDouble() * 2.5 + 1.5;
    final duration = (baseDuration * (1 + verticalPosition * 0.5)).seconds;

    final sizeMultiplier = 1 - (verticalPosition * 0.3);
    final actualSize = size * sizeMultiplier;

    final colors = [
      const Color(0xFFC0C0C0), // Silver
      const Color(0xFFFFB974), // Orange
      const Color(0xFF9C89FF), // Purple
      const Color(0xFF89FFDD), // Mint
      const Color(0xFFFF89B4), // Pink
      const Color(0xFF89FF98), // Green
    ];
    final color = colors[random.nextInt(colors.length)];

    // Adjusted opacity for better visibility with more balls
    final opacity = 0.8 - (verticalPosition * 0.3);

    return Positioned(
      left: initialX,
      top: initialY,
      child: Container(
        width: actualSize,
        height: actualSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(opacity),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(
                  opacity * 0.3), // Reduced shadow for less GPU load
              blurRadius: actualSize / 2,
              spreadRadius: actualSize / 4,
            ),
          ],
        ),
      )
          .animate(
            onPlay: (controller) => controller.repeat(),
          )
          .fadeIn(duration: 600.ms)
          .scaleXY(
            begin: 0.5,
            end: 1,
            duration: 600.ms,
            curve: Curves.easeOut,
          )
          .then()
          .moveY(
            begin: 0,
            end: -moveDistance,
            duration: duration,
            curve: Curves.easeInOut,
          )
          .then()
          .moveY(
            begin: -moveDistance,
            end: 0,
            duration: duration,
            curve: Curves.easeInOut,
          )
          .animate(delay: duration * 0.2)
          .moveX(
            begin: 0,
            end: moveDistance,
            duration: duration * 1.2,
            curve: Curves.easeInOut,
          )
          .then()
          .moveX(
            begin: moveDistance,
            end: 0,
            duration: duration * 1.2,
            curve: Curves.easeInOut,
          ),
    );
  }
}
