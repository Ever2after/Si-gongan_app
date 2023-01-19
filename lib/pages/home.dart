import 'package:flutter/material.dart';
import '../helper/arguments.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _myId = '';

  @override
  void initState() {
    super.initState();
    _loadMyId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/loading');
              },
              child: Text('loading')),
          ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: Text('login')),
          ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/chat',
                    arguments: ScreenArguments(_myId, 'admin'));
              },
              child: Text('chat')),
          ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/admin');
              },
              child: Text('admin')),
        ],
      ),
    );
  }

  void _loadMyId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _myId = prefs.getString('id')!;
    });
  }
}
