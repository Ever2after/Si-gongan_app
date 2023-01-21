import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import '../helper/arguments.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  static const routeName = '/chat';
  List<types.Message> _messages = [];
  types.User _user = types.User(id: '');
  types.User _opponent = types.User(id: '');
  String _roomId = '';
  int count = 0;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
    _user = types.User(id: args.user, lastName: args.user);
    _opponent = types.User(id: args.opponent, lastName: args.opponent);
    _roomId = args.user == 'admin' ? args.opponent : args.user;

    return Scaffold(
        body: StreamBuilder(
            stream:
                FirebaseDatabase.instance.ref('messages/${_roomId}').onValue,
            builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.snapshot.exists) {
                  Map<dynamic, dynamic> json =
                      snapshot.data!.snapshot.value as dynamic;
                  final messages = _jsonToMessages(json);

                  return Chat(
                    messages: messages,
                    onSendPressed: _handleSendPressed,
                    onAttachmentPressed: _handleImageSelection,
                    user: _user,
                    showUserAvatars: true,
                    showUserNames: true,
                  );
                } else {
                  return Chat(
                    messages: _messages,
                    onSendPressed: _handleSendPressed,
                    onAttachmentPressed: _handleImageSelection,
                    user: _user,
                    showUserAvatars: true,
                    showUserNames: true,
                  );
                }
              } else {
                return Chat(
                  messages: _messages,
                  onSendPressed: _handleSendPressed,
                  onAttachmentPressed: _handleImageSelection,
                  user: _user,
                  showUserAvatars: true,
                  showUserNames: true,
                );
              }
            }));
  }

  /*
      Chat(
        messages: _messages,
        onAttachmentPressed: _handleAttachmentPressed,
        onMessageTap: _handleMessageTap,
        onPreviewDataFetched: _handlePreviewDataFetched,
        onSendPressed: _handleSendPressed,
        showUserAvatars: true,
        showUserNames: true,
        user: _user,
      ),*/

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

/*
  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          height: 144,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleImageSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Photo'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleFileSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('File'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
*/
  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      final message = types.FileMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        mimeType: lookupMimeType(result.files.single.path!),
        name: result.files.single.name,
        size: result.files.single.size,
        uri: result.files.single.path!,
      );

      _addMessage(message);
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
      count++;
      final author = count % 2 == 0 ? _user : _opponent;
      final msgId = const Uuid().v4();
      final timeStamp = DateTime.now().millisecondsSinceEpoch;
      DatabaseReference ref = FirebaseDatabase.instance.ref('rooms/${_roomId}');
      await ref.set({
        'status': 'status',
        'timestamp': timeStamp,
        'lastMessage': '사진을 보냈습니다',
      });
      // messages info update
      DatabaseReference ref2 =
          FirebaseDatabase.instance.ref('messages/${_roomId}/${msgId}');
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

  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        try {
          final index =
              _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (_messages[index] as types.FileMessage).copyWith(
            isLoading: true,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });

          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes;
          final documentsDir = (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final index =
              _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (_messages[index] as types.FileMessage).copyWith(
            isLoading: null,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });
        }
      }

      await OpenFilex.open(localPath);
    }
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      _messages[index] = updatedMessage;
    });
  }

  void _handleSendPressed(types.PartialText message) async {
    count++;
    final author = count % 2 == 0 ? _user : _opponent;
    final msgId = const Uuid().v4();
    final timeStamp = DateTime.now().millisecondsSinceEpoch;
    // add message in db
    // room info update

    DatabaseReference ref = FirebaseDatabase.instance.ref('rooms/${_roomId}');
    await ref.set({
      'status': 'status',
      'timestamp': timeStamp,
      'lastMessage': message.text,
    });
    // messages info update
    DatabaseReference ref2 =
        FirebaseDatabase.instance.ref('messages/${_roomId}/${msgId}');
    await ref2.set({
      'authorId': author.id,
      'type': 'text',
      'message': message.text,
      'timestamp': timeStamp,
    });
  }

  void _loadMessages() async {
    final ref = FirebaseDatabase.instance.ref('/messages/${_roomId}}');
    final snapshot = await ref.get();
    if (snapshot.exists) {
      final messages = _jsonToMessages(snapshot.value);
      setState(() {
        _messages = messages;
      });

      // set state _messages = messages;
    } else {
      // no data here
    }
  }

  List<types.Message> _jsonToMessages(json) {
    final messages = json.keys.map((key) {
      final message = json['$key'];
      final author = message['authorId'] == _user.id ? _user : _opponent;
      if (message['type'] == 'text') {
        return types.TextMessage(
            author: author,
            id: key,
            text: message['message'],
            createdAt: message['timestamp']);
      } else if (message['type'] == 'image') {
        return types.ImageMessage(
          author: _user,
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

  _loadUsers() {}
}
