import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class RandomFactDisplay extends StatefulWidget {
  const RandomFactDisplay({Key? key}) : super(key: key);

  @override
  State<RandomFactDisplay> createState() => _RandomFactDisplayState();
}

class _RandomFactDisplayState extends State<RandomFactDisplay> {
  final List<String> _randomFacts = [
    "0 appears only in 1 in a million usernames!",
    "4 can only be used in usernames during January.",
    "1 can appear in usernames on weekends only.",
    "7 is reserved :). Siuuuu...",
  ];

  final _colors = [
    const Color(0xFFC0C0C0), // Silver
    const Color(0xFFFFB974), // Orange
    const Color(0xFF9C89FF), // Purple
    const Color(0xFF89FFDD), // Mint
    const Color(0xFFFF89B4), // Pink
    const Color(0xFF89FF98), // Green
  ];

  int _currentFactIndex = 0;
  int _currentColorIndex = 0;
  Timer? _factChangeTimer;

  @override
  void initState() {
    super.initState();
    // Start the timer to update the fact every few seconds
    _factChangeTimer = Timer.periodic(const Duration(seconds: 7), (timer) {
      setState(() {
        _currentFactIndex = (_currentFactIndex + 1) % _randomFacts.length;
        _currentColorIndex = Random().nextInt(_colors.length);
      });
    });
  }

  @override
  void dispose() {
    _factChangeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Text(
        _randomFacts[_currentFactIndex],
        style: TextStyle(
          color: _colors[_currentColorIndex],
          fontSize: 24,
        ),
        softWrap: true,
      ),
    );
  }
}
