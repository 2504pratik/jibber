import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../main.dart';
import '../../api/apis.dart';
import 'home/home_page.dart';
import 'login/loginscreen.dart';

//splash screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      log('\nUser: ${APIs.auth.currentUser}');

      //navigate
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => APIs.auth.currentUser != null
                ? const HomeScreen()
                : const LoginScreen(),
          ));
    });
  }

  @override
  Widget build(BuildContext context) {
    //initializing media query (for getting device screen size)
    mq = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1B1E),
      //body
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              'assets/icon.png',
              color: Colors.white,
            ),
          ),
          RichText(
            text: TextSpan(
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
          )
        ],
      ),
    );
  }
}
