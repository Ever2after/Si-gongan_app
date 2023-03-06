import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'helper/auth.dart';
import 'helper/notification.dart';

import 'pages/home.dart';
import 'pages/login.dart';
import 'pages/loading.dart';
import 'pages/select.dart';
import 'pages/chat.dart';
import 'pages/chat4blind.dart';
import 'pages/admin.dart';
import 'pages/selectScreen.dart';
import 'pages/settings.dart';
import 'pages/usage.dart';

void main() async {
  // firebase initilization
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AuthHelper.signInAnonymously();
  // notification initialize
  LocalNotification.initialize();
  // load env file
  await dotenv.load(fileName: '.env');
  // run app
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
      initialRoute: '/select',
      routes: {
        '/': (context) => Home(),
        '/login': (context) => Login(),
        '/loading': (context) => Loading(),
        '/select': (context) => Select(),
        '/selectScreen': (context) => SelectScreen(),
        '/admin': (context) => Admin(),
        '/chat': (context) => ChatPage(),
        '/chat4blind': (context) => Chat4Blind(),
        '/setting': (context) => Setting(),
        '/usage': (context) => Usage(),
      },
      //showSemanticsDebugger: true,
      debugShowCheckedModeBanner: false,
    );
  }
}

