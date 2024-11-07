import 'dart:math';

import 'package:flutter/material.dart';
import 'package:jibber/background/animated_background.dart';
import 'package:jibber/screens/landing%20pages/username_reveal.dart';

class UsernamePage extends StatefulWidget {
  const UsernamePage({super.key});

  @override
  State<UsernamePage> createState() => _UsernamePageState();
}

class _UsernamePageState extends State<UsernamePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  late AnimationController _animationController;
  late Animation<Color?> _borderColorAnimation;

  // List of animal avatar images
  final List<String> _avatarImages = [
    'assets/cat.png',
    'assets/dog.png',
    'assets/monkey.png',
    'assets/panda.png',
    'assets/tiger.png',
  ];

  // Selected avatar
  late String _selectedAvatar;

  @override
  void initState() {
    super.initState();

    _selectedAvatar = _avatarImages[Random().nextInt(_avatarImages.length)];

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _borderColorAnimation = ColorTween(
      begin: const Color(0xFF9C89FF).withOpacity(0.5),
      end: Theme.of(context).colorScheme.primary,
    ).animate(_animationController);

    _usernameController.addListener(() {
      if (_usernameController.text.isNotEmpty) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  // Method to select a random avatar
  void _chooseRandomAvatar() {
    setState(() {
      _selectedAvatar = _avatarImages[Random().nextInt(_avatarImages.length)];
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          // Animated Background
          const AnimatedBackground(height: 30),
          // Welcome Text
          Positioned(
            top: MediaQuery.of(context).size.height * 0.1,
            left: 16,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Welcome to,\n',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.2,
                    ),
                  ),
                  TextSpan(
                    text: 'Jibber',
                    style: TextStyle(
                      fontSize: 48,
                      fontFamily: 'Lobster',
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..shader = LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                          ],
                        ).createShader(
                          const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                        ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glowing Border with Gradient
                    Container(
                      width: 125, // Slightly larger than the avatar radius
                      height: 125,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF9C89).withOpacity(0.5),
                            blurRadius: 15,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),

                    // Avatar Circle with Image
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage(_selectedAvatar),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Username TextField
                AnimatedBuilder(
                  animation: _borderColorAnimation,
                  builder: (context, child) {
                    return TextField(
                      controller: _usernameController,
                      cursorColor: Theme.of(context).colorScheme.secondary,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        labelStyle: TextStyle(
                          color: Colors.grey[300],
                        ),
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: Colors.white,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _borderColorAnimation.value!,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _borderColorAnimation.value!,
                            width: 2.0,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey[900]!.withOpacity(0.5),
                      ),
                      style: const TextStyle(color: Colors.white),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Informative Text
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Text(
                      "Your username will have a special twist. Tap 'Continue' to see.",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          // Continue Btn
          Positioned(
            bottom: 32, // Adjust padding from the bottom
            left: 24, // Padding from the left
            right: 24, // Padding from the right
            child: SizedBox(
              width:
                  MediaQuery.of(context).size.width - 48, // Adjust for padding
              child: ElevatedButton(
                onPressed: () {
                  if (_usernameController.text.isNotEmpty) {
                    // Handle username submission
                    print('Username: ${_usernameController.text}');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UsernameRevealPage(
                            baseUsername: _usernameController.text),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shadowColor: Theme.of(context).colorScheme.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Next',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
