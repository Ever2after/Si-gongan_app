import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../helper/arguments.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

enum People { none, dayoung, boyoung, junyoung, yubin, jusang, banned }

class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  List<dynamic> _rooms = [];
  dynamic _room;
  People? _character = People.none;
  dynamic nameTable = {
    'none': '없음',
    'jusang': '주상',
    'dayoung': '다영',
    'boyoung': '보영',
    'junyoung': '준영',
    'yubin': '유빈',
    'banned': '차단'
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            //actions: [Text('하위')],
            title: Text('관리자 페이지')),
        endDrawer: Drawer(
          child: ListView(
            children: [
              SizedBox(
                height: 60,
                child: DrawerHeader(
                  padding: EdgeInsets.all(0),
                  child: Row(children: [
                    IconButton(
                      splashRadius: 30,
                      icon: Icon(CupertinoIcons.forward),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Text('설정', style: TextStyle(fontSize: 20))
                  ]),
                ),
              ),
              ListTile(
                  onTap: () async {
                    launchUrl(Uri.parse('http://13.59.92.24:3000'));
                  },
                  leading: Icon(CupertinoIcons.graph_square),
                  title: Text('해설현황 확인', style: TextStyle(fontSize: 20))),
              ListTile(
                  onTap: () async {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/selectScreen', (r) => false);
                  },
                  leading: Icon(CupertinoIcons.delete_left),
                  title: Text('관리자 나가기', style: TextStyle(fontSize: 20))),
            ],
          ),
        ),
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
    final isNone = room['inCharge'] == null || room['inCharge'] == 'none';
    final isBanned = room['inCharge'] == 'banned';

    return Dismissible(
        key: Key(room['id']),
        direction: DismissDirection.endToStart,
        background: Container(),
        secondaryBackground: Container(
          padding: EdgeInsets.only(right: 14),
          alignment: Alignment.centerRight,
          color: Colors.redAccent,
          child: Icon(CupertinoIcons.trash_fill),
        ),
        onDismissed: ((direction) async {
          final ref = FirebaseDatabase.instance.ref('rooms/${room['id']}');
          await ref.remove();
          final ref2 = FirebaseDatabase.instance.ref('messages/${room['id']}');
          await ref2.remove();
        }),
        confirmDismiss: (direction) {
          return showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('대화방 삭제'),
              content: Text('대화내역이 모두 삭제됩니다. 정말 삭제하시겠습니까?'),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    return Navigator.of(context).pop(false);
                  },
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () {
                    return Navigator.of(context).pop(true);
                  },
                  child: const Text('삭제'),
                ),
              ],
            ),
          );
        },
        child: ListTile(
          onLongPress: () {
            // change states
            if (!isNone) {
              for (int i = 0; i < People.values.length; i++) {
                if (People.values[i].toString().contains(room['inCharge'])) {
                  setState(() {
                    _character = People.values[i];
                    _room = room;
                  });
                  break;
                }
              }
            } else {
              setState(() {
                _character = People.none;
                _room = room;
              });
            }
            // show dialog
            showDialog(
              context: context,
              builder: (context) =>
                  StatefulBuilder(builder: _SelectDialogBuilder),
            ).then(
              (value) async {
                final inCharge = _character.toString().split('.')[1];
                final ref =
                    FirebaseDatabase.instance.ref('rooms/${_room['id']}');
                await ref.update({'inCharge': inCharge});
                setState(
                  () {
                    _character = People.none;
                  },
                );
              },
            );
          },
          leading: isBanned
              ? Icon(CupertinoIcons.nosign, size: 30, color: Colors.white38)
              : isNone
                  ? (unread > 0
                      ? Icon(
                          CupertinoIcons.person_solid,
                          size: 30,
                          color: Colors.redAccent,
                        )
                      : Icon(CupertinoIcons.person_solid, size: 30))
                  : Text(
                      nameTable[room['inCharge']],
                      style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
          title: Text(isBanned ? '[ 차단된 사용자입니다 ]' : room['title']),
          subtitle: Text(
            isBanned ? '' : room['lastMessage'],
            maxLines: 2,
          ),
          trailing: isBanned
              ? SizedBox.shrink()
              : Column(
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
                              Text(unread.toString(),
                                  style: TextStyle(fontSize: 12)),
                            ],
                          ),
                  ],
                ),
          onTap: () {
            if (!isBanned) {
              Navigator.pushNamed(context, '/chat',
                  arguments: ScreenArguments('admin', room['id']));
            } else {
              // no action
            }
          },
        ));
  }

  Widget _SelectDialogBuilder(BuildContext _context, StateSetter setState) {
    final size = MediaQuery.of(_context).size;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
          vertical: size.height * 0.5 - 200,
          horizontal: size.width * 0.5 - 100),
      child: Column(children: [
        Container(
            child: Text(
              '담당자 지정',
              style: TextStyle(fontSize: 20),
            ),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30)),
        Expanded(
          child: ListView.builder(
            itemBuilder: (context, index) => ListTile(
              title: Text(
                  nameTable[People.values[index].toString().split('.')[1]]),
              leading: Radio<People>(
                value: People.values[index],
                groupValue: _character,
                onChanged: (People? value) {
                  setState(
                    () {
                      _character = value;
                    },
                  );
                },
              ),
            ),
            itemCount: People.values.length,
          ),
        ),
      ]),
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
        'timestamp': value['timestamp'],
        'inCharge': value['inCharge'],
      };
    });
    return List.from(rooms)
      ..sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
  }
}
