import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'helper/auth.dart';

import 'pages/home.dart';
import 'pages/login.dart';
import 'pages/loading.dart';
import 'pages/chat.dart';
import 'pages/admin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AuthHelper.signInAnonymously();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '시(視)공간',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        primaryColor: Colors.indigoAccent,
        brightness: Brightness.dark,
      ),
      initialRoute: '/loading',
      routes: {
        '/': (context) => Home(),
        '/login': (context) => Login(),
        '/loading': (context) => Loading(),
        '/admin': (context) => Admin(),
        '/chat': (context) => ChatPage(),
      },
    );
  }
}
