import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TwinklingStarsBackground extends StatelessWidget {
  const TwinklingStarsBackground({Key? key}) : super(key: key);

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
              100, // Number of stars
              (index) => _TwinklingStar(
                index: index,
                maxWidth: constraints.maxWidth,
                maxHeight: constraints.maxHeight,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TwinklingStar extends StatelessWidget {
  final int index;
  final double maxWidth;
  final double maxHeight;

  const _TwinklingStar({
    required this.index,
    required this.maxWidth,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final random = Random(index);

    // Random position for the star
    final initialX = random.nextDouble() * maxWidth;
    final initialY = random.nextDouble() * maxHeight;

    // Random size for the star
    final size = random.nextDouble() * 4 + 1; // Size between 1-5

    // Duration for twinkling effect
    final duration = random.nextDouble() * 1 + 0.5; // 0.5s to 1.5s

    return Positioned(
        left: initialX,
        top: initialY,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(1), // Star color
          ),
        )
            .animate(
              onPlay: (controller) => controller.repeat(),
            )
            .fadeIn(duration: duration.ms)
            .fadeOut(duration: duration.ms)
            .animate(
                delay: Duration(
                    seconds: (duration * 0.5)
                        .toInt()))); // Delay for a staggered twinkling effect
  }
}
