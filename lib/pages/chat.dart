import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../helper/arguments.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<types.Message> _messages = [];
  types.User _user = const types.User(id: '');
  types.User _opponent = const types.User(id: '');
  String _userId = '';
  String _opponentId = '';
  String _roomId = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
    _roomId = args.user == 'admin' ? args.opponent : args.user;
    _userId = args.user;
    _opponentId = args.opponent;
    return Scaffold(
        appBar: AppBar(
          title: Text('물어보기',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        body: StreamBuilder(
            stream: FirebaseDatabase.instance.ref('messages/$_roomId').onValue,
            builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
              final isAdmin = args.user == 'admin';
              if (snapshot.hasData) {
                if (snapshot.data!.snapshot.exists) {
                  Map<dynamic, dynamic> json =
                      snapshot.data!.snapshot.value as dynamic;
                  final messages = _jsonToMessages(json);
                  return _buildChat(messages, isAdmin);
                } else {
                  return _buildChat(_messages, isAdmin);
                }
              } else {
                return _buildChat(_messages, isAdmin);
              }
            }));
  }

  Widget _buildChat(dynamic messages, [bool isAdmin = true]) {
    if (isAdmin) {
      return Chat(
        l10n: const ChatL10nKo(),
        theme: const DefaultChatTheme(
          // color
          primaryColor: Colors.indigoAccent,
          secondaryColor: Colors.white10,
          backgroundColor: Colors.black12,
          // button
          attachmentButtonIcon: Icon(CupertinoIcons.camera_fill),
          attachmentButtonMargin: EdgeInsets.symmetric(),
          sendButtonIcon: Icon(CupertinoIcons.paperplane_fill),
          sendButtonMargin: EdgeInsets.symmetric(),
          receivedMessageBodyTextStyle: TextStyle(color: Colors.white),
        ),
        messages: messages,
        onSendPressed: _handleSendPressed,
        onAttachmentPressed: _handleImageSelection,
        user: _user,
        showUserAvatars: true,
        showUserNames: true,
      );
    } else {
      return Chat(
        l10n: const ChatL10nKo(),
        theme: const DefaultChatTheme(
            // color
            primaryColor: Colors.indigoAccent,
            secondaryColor: Colors.white10,
            backgroundColor: Colors.black12,
            // button
            attachmentButtonIcon: Icon(CupertinoIcons.camera_fill, size: 32),
            attachmentButtonMargin:
                EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            sendButtonIcon: Icon(CupertinoIcons.paperplane_fill, size: 32),
            sendButtonMargin:
                EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            // input
            inputTextStyle: TextStyle(
              fontSize: 24,
            ),
            inputPadding: EdgeInsets.fromLTRB(15, 15, 5, 20),
            // text style
            dateDividerTextStyle:
                TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            sentMessageBodyTextStyle:
                TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            receivedMessageBodyTextStyle:
                TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        messages: messages,
        onSendPressed: _handleSendPressed,
        onAttachmentPressed: _handleImageSelection,
        user: _user,
        showUserAvatars: true,
        showUserNames: true,
      );
    }
  }

  void _handleImageSelection() async {
    final XFile? file = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (file != null) {
      final bytes = await file.readAsBytes();
      final image = await decodeImageFromList(bytes);
      final Uint8List photo = await XFile(file.path).readAsBytes();

      // upload image to the cloud storage and get url
      //final fileName = basename(_photo!.path);
      final storageRef = FirebaseStorage.instance.ref('images/${file.name}');
      await storageRef.putData(photo);
      final imageUrl = await storageRef.getDownloadURL();

      // upload message info
      final author = _user;
      final msgId = const Uuid().v4();
      final timeStamp = DateTime.now().millisecondsSinceEpoch;

      DatabaseReference ref = FirebaseDatabase.instance.ref('rooms/$_roomId');
      final dynamic room = await ref.get();
      if (room.exists) {
        int unread = 0;
        if (room.value['lastSender'] == author.id)
          unread = room.value['unread'] + 1;
        else
          unread = 1;
        await ref.update({
          'lastSender': author.id,
          'unread': unread,
          'timestamp': timeStamp,
          'lastMessage': '사진을 보냈습니다',
        });
      } else {
        await ref.set({
          'status': 'status',
          'title': _user.id == 'admin' ? _opponent.lastName : _user.lastName,
          'lastSender': author.id,
          'unread': 1,
          'timestamp': timeStamp,
          'lastMessage': '사진을 보냈습니다',
        });
      }
      // messages info update
      DatabaseReference ref2 =
          FirebaseDatabase.instance.ref('messages/$_roomId/$msgId');
      await ref2.set({
        'authorId': author.id,
        'type': 'image',
        'message': file.name,
        'height': image.height.toDouble(),
        'size': bytes.length,
        'uri': imageUrl,
        'width': image.width.toDouble(),
        'timestamp': timeStamp,
      });
    } else {
      print('image not selected');
    }
  }

  void _handleSendPressed(types.PartialText message) async {
    final author = _user;
    final msgId = const Uuid().v4();
    final timeStamp = DateTime.now().millisecondsSinceEpoch;

    DatabaseReference ref = FirebaseDatabase.instance.ref('rooms/$_roomId');
    final dynamic room = await ref.get();
    if (room.exists) {
      int unread = 0;
      if (room.value['lastSender'] == author.id)
        unread = room.value['unread'] + 1;
      else
        unread = 1;
      await ref.update({
        'lastSender': author.id,
        'unread': unread,
        'timestamp': timeStamp,
        'lastMessage': message.text,
      });
    } else {
      await ref.set({
        'status': 'status',
        'title': _user.id == 'admin' ? _opponent.lastName : _user.lastName,
        'lastSender': author.id,
        'unread': 1,
        'timestamp': timeStamp,
        'lastMessage': message.text,
      });
    }

    // messages info update
    DatabaseReference ref2 =
        FirebaseDatabase.instance.ref('messages/$_roomId/$msgId');
    await ref2.set({
      'authorId': author.id,
      'type': 'text',
      'message': message.text,
      'timestamp': timeStamp,
    });
  }

  _loadUsers() async {
    final ref = FirebaseDatabase.instance.ref('users/$_roomId');
    final snapshot = await ref.get();
    if (snapshot.exists) {
      final dynamic data = snapshot.value;
      final user = types.User(
        id: _roomId,
        lastName: data[_roomId]['nickname'],
      );
      final admin = types.User(id: 'admin', lastName: 'Admin');
      setState(() {
        _user = _userId == 'admin' ? admin : user;
        _opponent = _userId == 'admin' ? user : admin;
      });
    }
    final ref2 = FirebaseDatabase.instance.ref('rooms/$_roomId');
    final dynamic room = await ref2.get();
    if (room.exists && room.value['lastSender'] != _user.id) {
      await ref2.update({
        'unread': 0,
      });
    }
  }

  List<types.Message> _jsonToMessages(json) {
    final messages = json.keys.map((key) {
      final message = json['$key'];
      final author = message['authorId'] == _userId ? _user : _opponent;
      if (message['type'] == 'text') {
        return types.TextMessage(
            author: author,
            id: key,
            text: message['message'],
            createdAt: message['timestamp']);
      } else if (message['type'] == 'image') {
        return types.ImageMessage(
          author: author,
          createdAt: message['timestamp'],
          height: message['height'],
          id: key,
          name: message['message'],
          size: message['size'],
          uri: message['uri'],
          width: message['width'],
        );
      }
    });
    return List.from(messages)
      ..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
  }
}
