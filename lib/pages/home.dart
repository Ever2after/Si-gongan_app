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
        body: Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  alignment: Alignment.center, fixedSize: Size(130, 130)),
              onPressed: () {
                Navigator.pushNamed(context, '/chat',
                    arguments: ScreenArguments(_myId, 'admin'));
              },
              child: Text(
                '물어보기',
                style: TextStyle(fontSize: 24),
              )),
          Container(
            height: 30,
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  alignment: Alignment.center, fixedSize: Size(130, 130)),
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: Text('닉네임\n재설정', style: TextStyle(fontSize: 24))),
        ],
      ),
    ));
  }

  void _loadMyId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _myId = prefs.getString('id')!;
    });
  }
}
