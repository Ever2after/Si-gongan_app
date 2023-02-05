import 'package:flutter/cupertino.dart';
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
      leading: Icon(CupertinoIcons.person_solid, size: 30),
      title: Text(room['title']),
      subtitle: Text(
        room['lastMessage'],
        maxLines: 2,
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(d12, style: TextStyle(fontSize: 12)),
          SizedBox(height: 6),
          unread == 0
              ? SizedBox.shrink()
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(CupertinoIcons.circle_fill,
                        color: Colors.redAccent, size: 26),
                    Text(unread.toString(), style: TextStyle(fontSize: 12)),
                  ],
                ),
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
