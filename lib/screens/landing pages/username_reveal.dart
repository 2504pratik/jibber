import 'package:flutter/material.dart';
import 'package:jibber/helper/auth_service.dart';
import 'dart:math';

import '../../helper/random_fact.dart';

class UsernameRevealPage extends StatefulWidget {
  final String baseUsername;

  const UsernameRevealPage({Key? key, required this.baseUsername})
      : super(key: key);

  @override
  _UsernameRevealPageState createState() => _UsernameRevealPageState();
}

class _UsernameRevealPageState extends State<UsernameRevealPage>
    with SingleTickerProviderStateMixin {
  late String _fullUsername;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Generate the full username with a random prefix
    _fullUsername = generateRandomUsername(widget.baseUsername);

    // Initialize the animation controller
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Define the opacity animation from 0 to 1
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Start the animation after a slight delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String generateRandomUsername(String baseUsername) {
    final random = Random();
    final currentDate = DateTime.now();
    String prefix = '';
    bool validPrefix = false;

    // Keep generating a prefix until a valid one is found
    while (!validPrefix) {
      int randomNum = random.nextInt(10);

      // Apply restrictions based on the generated number
      switch (randomNum) {
        case 0:
          if (random.nextInt(1000000) == 0) {
            prefix = '0._';
            validPrefix = true;
          }
          break;
        case 1:
          if (currentDate.weekday == 6 || currentDate.weekday == 7) {
            prefix = '1._';
            validPrefix = true;
          }
          break;
        case 4:
          if (currentDate.month == 1) {
            prefix = '4._';
            validPrefix = true;
          }
          break;
        case 7:
          randomNum = random.nextInt(9); // Generate a new number
          break;
        default:
          prefix = '$randomNum._';
          validPrefix = true;
          break;
      }
      // Final check to ensure no 7 is used, and prefix rules are followed
      if (randomNum == 7) {
        randomNum = random.nextInt(9); // Retry to avoid 7
        prefix = '$randomNum._';
      }
    }

    // Concatenate the valid prefix with the base username
    return '$prefix$baseUsername';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          ),
          child: const Text(
            'Jibber',
            style: TextStyle(
              fontSize: 32,
              fontFamily: 'Lobster',
              fontWeight: FontWeight.bold,
              color: Colors.white, // Set color to enable gradient
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Congratulations Text
            Text(
              "Wohhh!!!",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            // Animated Username Reveal
            FadeTransition(
              opacity: _opacityAnimation,
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                ),
                child: Text(
                  _fullUsername,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Set color to enable gradient
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              "This will be your unique username.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            Container(
              height: 200,
              padding: const EdgeInsets.only(left: 64),
              child: const Stack(
                children: [
                  // Big quote symbol in the background
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "“",
                      style: TextStyle(
                        color: Colors
                            .white24, // Lighter color for subtle background effect
                        fontSize: 100,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Facts
                  Positioned(
                    top: 35,
                    left: 32,
                    right: 32,
                    child: RandomFactDisplay(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Continue Button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              if (_fullUsername.isNotEmpty) {
                AuthService().saveUsername(context, _fullUsername);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              shadowColor: Theme.of(context).colorScheme.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Continue",
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
