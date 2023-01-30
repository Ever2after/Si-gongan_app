import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../helper/arguments.dart';
import 'package:intl/intl.dart';

class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  List<dynamic> _rooms = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
      stream: FirebaseDatabase.instance.ref('rooms').onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.snapshot.exists) {
            Map<dynamic, dynamic> json =
                snapshot.data!.snapshot.value as dynamic;
            final rooms = _jsonToList(json);
            return ListView.builder(
                itemCount: rooms.length,
                itemBuilder: ((context, index) {
                  return _roomToTile(rooms[index]);
                }));
          } else {
            return ListView.builder(
                itemCount: _rooms.length,
                itemBuilder: ((context, index) {
                  return _roomToTile(_rooms[index]);
                }));
          }
        } else {
          return ListView.builder(
              itemCount: _rooms.length,
              itemBuilder: ((context, index) {
                return _roomToTile(_rooms[index]);
              }));
        }
      },
    ));
  }

  Widget _roomToTile(dynamic room) {
    final unread = room['lastSender'] == 'admin' ? 0 : room['unread'];
    final dt = new DateTime.fromMillisecondsSinceEpoch(room['timestamp']);
    final d12 = DateFormat('MM/dd hh:mm a').format(dt);

    return ListTile(
      leading: FlutterLogo(size: 30),
      title: Text(room['title']),
      subtitle: Text(room['lastMessage']),
      trailing: Column(
        children: [
          Text(d12, style: TextStyle(fontSize: 12)),
          Text(unread == 0 ? '' : unread.toString(),
              style: TextStyle(color: Colors.red, fontSize: 16)),
        ],
      ),
      onTap: () {
        Navigator.pushNamed(context, '/chat',
            arguments: ScreenArguments('admin', room['id']));
      },
    );
  }

  List<dynamic> _jsonToList(json) {
    final rooms = json.keys.map((key) {
      final value = json['$key'];
      return {
        'id': key,
        'title': value['title'],
        'status': value['status'],
        'lastSender': value['lastSender'],
        'unread': value['unread'],
        'lastMessage': value['lastMessage'],
        'timestamp': value['timestamp']
      };
    });
    return List.from(rooms)
      ..sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
  }
}
