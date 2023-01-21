import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:firebase_database/firebase_database.dart';
import '../helper/arguments.dart';

class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  List<dynamic> _rooms = [];
  final _user = const types.User(id: 'everafter', lastName: 'user');
  final _opponent = const types.User(id: 'admin', lastName: 'opponent');

  @override
  void initState() {
    super.initState();
    _loadRooms();
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
    return ListTile(
      leading: FlutterLogo(size: 30),
      title: Text(room['name']),
      subtitle: Text(room['lastMessage']),
      trailing: Text(room['unread'].toString()),
      onTap: () {
        Navigator.pushNamed(context, '/chat',
            arguments: ScreenArguments('admin', room['name']));
      },
    );
  }

  List<dynamic> _jsonToList(json) {
    final rooms = json.keys.map((key) {
      final value = json['$key'];
      return {
        'name': key,
        'status': value['status'],
        'unread': value['unread'],
        'lastMessage': value['lastMessage'],
        'timestamp': value['timestamp']
      };
    });
    return List.from(rooms)
      ..sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
  }

  void _loadRooms() async {
    final ref = FirebaseDatabase.instance.ref('/rooms');
    final snapshot = await ref.get();
    if (snapshot.exists) {
      final rooms = _jsonToList(snapshot.value);
      setState(() {
        _rooms = rooms;
      });
    }
  }
}
