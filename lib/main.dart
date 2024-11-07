import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:jibber/screens/landing%20pages/username_page.dart';
import 'package:jibber/screens/splash_screen.dart';

import 'firebase_options.dart';
import 'screens/home/home_page.dart';
import 'screens/login/loginscreen.dart';

//global object for accessing device screen size
late Size mq;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initializeFirebase();

  //for setting orientation to portrait only
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jibber',
      theme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFFFF9C89),
          onPrimary: Colors.black54,
          secondary: Color(0xFF9C89FF),
          onSecondary: Colors.black54,
          error: Colors.red,
          onError: Colors.black54,
          surface: Color(0xFF1A1B1E),
          onSurface: Colors.white,
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/username': (context) => const UsernamePage(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

Future<void> _initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  var result = await FlutterNotificationChannel().registerNotificationChannel(
      description: 'For Showing Message Notification',
      id: 'chats',
      importance: NotificationImportance.IMPORTANCE_HIGH,
      name: 'Chats');

  log('\nNotification Channel Result: $result');
}
