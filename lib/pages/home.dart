import 'package:flutter/material.dart';
import '../helper/arguments.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _myId = '';
  String _nickName = '';

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text('홈',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ))),
        body: Container(
            width: double.infinity,
            alignment: Alignment.center,
            child: StreamBuilder(
                stream: FirebaseDatabase.instance.ref('rooms/$_myId').onValue,
                builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.snapshot.exists) {
                      final data = snapshot.data!.snapshot.value as dynamic;
                      final unread =
                          data['lastSender'] == 'admin' ? data['unread'] : 0;
                      return _buildColumn(unread, false);
                    } else {
                      return _buildColumn(0, false);
                    }
                  } else {
                    return _buildColumn(0, true);
                  }
                })));
  }

  Widget _buildColumn(int n, [isLoading = true]) {
    if (n > 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: Text('$n개의 새 메세지가 있습니다',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            margin: EdgeInsets.symmetric(vertical: 30),
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  alignment: Alignment.center, fixedSize: Size(130, 130)),
              onPressed: () {
                Navigator.pushNamed(context, '/chat',
                    arguments: ScreenArguments(_myId, 'admin'));
              },
              child: Text(
                '물어보기',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              )),
          Container(
            height: 30,
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  alignment: Alignment.center, fixedSize: Size(130, 130)),
              onPressed: () {
                Navigator.pushNamed(context, '/login',
                    arguments: {'isFirst': false});
              },
              child: Text('닉네임\n재설정',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: Text('도착한 메세지가 없습니다!',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white30)),
            margin: EdgeInsets.symmetric(vertical: 30),
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  alignment: Alignment.center, fixedSize: Size(130, 130)),
              onPressed: () {
                Navigator.pushNamed(context, '/chat',
                    arguments: ScreenArguments(_myId, 'admin'));
              },
              child: Text(
                '물어보기',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              )),
          Container(
            height: 30,
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  alignment: Alignment.center, fixedSize: Size(130, 130)),
              onPressed: () {
                Navigator.pushNamed(context, '/login',
                    arguments: {'isFirst': false});
              },
              child: Text('닉네임\n재설정',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
        ],
      );
    }
  }

  void _loadInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _myId = prefs.getString('id')!;
      _nickName = prefs.getString('nickname')!;
    });
  }
}
