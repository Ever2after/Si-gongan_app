import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:Sigongan/helper/arguments.dart';
import 'package:extended_image/extended_image.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:Sigongan/helper/slack.dart';

class ChatMessage{
  String messageContent;
  String authorId;
  String authorName = '시공간';
  String? messageType; // 'text', 'image'
  int createdAt;
  //image
  num? height;
  num? width;
  num? size;
  String? uri;
  
  ChatMessage({required this.messageContent, 
  required this.authorId, 
  required this.createdAt, 
  this.messageType,
  this.height,
  this.width,
  this.size,
  this.uri});
}

class Chat4Blind extends StatefulWidget {
  const Chat4Blind({super.key});

  @override
  State<Chat4Blind> createState() => _Chat4BlindState();
}

class _Chat4BlindState extends State<Chat4Blind> {
  String _roomId = '';
  String _nickname = '';

  @override
  void initState() {
    super.initState();
    //_updateUnread();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as MyArguments;
    _roomId = args.id;
    _nickname = args.nickname;
    List<ChatMessage> _messages = [
    ];
    final scrollController = ScrollController();
    _updateUnread();

    return Scaffold(appBar: 
    AppBar(title:Text('물어보기', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), ),
      leading: Semantics(
        child:IconButton(
          icon:Icon(CupertinoIcons.left_chevron,),
          onPressed: (){Navigator.pop(context);},
        ),
        label: '뒤로가기 버튼',
        //excludeSemantics: true,
       ),),
    body: Column(children: [
      Expanded(child: StreamBuilder(stream: FirebaseDatabase.instance.ref('messages/$_roomId').onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot){
        if (snapshot.hasData){
          if(snapshot.data!.snapshot.exists){
            Map<dynamic, dynamic> json = snapshot.data!.snapshot.value as dynamic;
            final messages = _jsonToMessages(json);
            return _chatBuilder(messages, scrollController);
          }
          return _chatBuilder(_messages, scrollController);
        }
        return _chatBuilder(_messages, scrollController);
      })),
      Align(alignment: Alignment.bottomCenter, child: _bottomBuilder(scrollController))
    ]),
    );
  }

  Widget _chatBuilder(dynamic messages, controller){
    return ListView.builder(
      reverse: true,
      itemCount: messages.length,
      shrinkWrap: true,
      controller: controller,
      padding: EdgeInsets.only(top: 10,bottom: 10),
      itemBuilder: (context, index) => _bubbleBuilder(context, index, messages[index])
    );
  }

  Widget _bubbleBuilder(context, index, message){
    final bool isAdmin = message.authorId == 'admin';
    DateTime date = DateTime.fromMillisecondsSinceEpoch(message.createdAt);
    String createdAt = DateFormat('M월 d일 H시 m분').format(date);

    if(message.messageType == 'text'){
      return Semantics(
        excludeSemantics: true,
        label: isAdmin ? "${message.messageContent}, 시공간이 $createdAt에 전송한 메세지" : "${message.messageContent}, 내가 $createdAt에 전송한 메세지",
        child: Container(
          padding: EdgeInsets.only(left: 14,right: 14,top: 10,bottom: 10),
          child: Align(
            alignment: (isAdmin ? Alignment.topLeft : Alignment.topRight),
            child: 
              Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: (isAdmin ? Colors.black26 : Colors.indigo),
              ),
              padding: EdgeInsets.all(16),
              child: Text(message.messageContent, style: TextStyle(fontSize: 15),),
            )
          ),
        ),)
      ;
    } else {
      return Semantics(
        label: isAdmin ? '시공간이 $createdAt에 전송한 이미지' : '내가 $createdAt에 전송한 이미지',
        child:Container(padding: EdgeInsets.only(left: 14,right: 14,top: 10,bottom: 10),
          child: Align(
            alignment: (isAdmin ? Alignment.topLeft : Alignment.topRight),
            child: 
              Container(
              decoration: BoxDecoration(
                //borderRadius: BorderRadius.circular(20),
                color: (isAdmin ? Colors.black26 : Colors.indigo),
              ),
              //padding: EdgeInsets.all(16),
              child: ExtendedImage.network(message.uri ?? '', width: 300, fit: BoxFit.fill, shape: BoxShape.rectangle ,borderRadius: BorderRadius.circular(10)),
            )
          ),) 
        );
    }
    
  }

  Widget _bottomBuilder(scrollController) {
    final controller = TextEditingController();
    DatabaseReference ref = FirebaseDatabase.instance.ref('rooms/$_roomId');
    return SafeArea(child:Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.only(left: 10,bottom: 10,top: 10),
              height: 60,
              width: double.infinity,
              color: Colors.black26,
              child: Row(
                children: <Widget>[
                  Semantics(
                    //excludeSemantics: true,
                    label: '사진 전송 버튼',
                    child:IconButton(icon: Icon(CupertinoIcons.camera_fill), onPressed:(){
                    showModalBottomSheet(context: context, builder: (context){
                      return SafeArea(child:SizedBox(
                        height: 150,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                try{
                                  _handleImageSelection('gallery');
                                } catch(e){
                                  showDialog(context: context, builder: _failingDialogBuilder);
                                }
                              },
                              child: const Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Text(
                                  '갤러리에서 선택',
                                  style: TextStyle(fontSize: 20, color: Colors.white),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _handleImageSelection('camera');
                              },
                              child: const Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Text('사진 촬영',
                                    style: TextStyle(fontSize: 20, color: Colors.white)),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Text('취소',
                                    style: TextStyle(fontSize: 20, color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
                            ));
                    });
                  }),),
                  
                  SizedBox(width: 15,),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: "메세지를 입력하세요",
                        hintStyle: TextStyle(color: Colors.white60),
                        border: InputBorder.none
                      ),
                    ),
                  ),
                  
                  SizedBox(width: 15,),
                  Semantics(
                    //excludeSemantics: true,
                    label: '메세지 전송 버튼',
                    child:IconButton(
                    icon: Icon(CupertinoIcons.paperplane_fill),
                    onPressed: () async {
                      // send text message
                      final value = controller.text;
                      if(value.isNotEmpty && value != null){
                        final int timeStamp = DateTime.now().millisecondsSinceEpoch;
                        final msgId = const Uuid().v4();
                        DatabaseReference ref2 = FirebaseDatabase.instance.ref('messages/$_roomId/$msgId');
                        await ref2.set({
                          'authorId': _roomId,
                          'type': 'text',
                          'message': value,
                          'timestamp': timeStamp
                        });
                        scrollController.jumpTo(0.0);
                        final dynamic room = await ref.get();
                        if(room.exists){
                          int unread;
                          if (room.value['lastSender'] == _roomId) {
                            unread = room.value['unread'] + 1;
                          } else {
                            unread = 1;
                          }
                          await ref.update({
                            'lastSender': _roomId,
                            'unread': unread,
                            'timestamp': timeStamp,
                            'lastMessage': value
                          });
                        } else {
                          await ref.set({
                            'status': 'status',
                            'title': _nickname,
                            'lastSender': _roomId,
                            'unread': 1,
                            'timestamp': timeStamp,
                            'lastMessage': value
                          });
                        }
                        controller.clear();
                        String msg = '[$_nickname] ${value}';
                        sendSlackMessage(msg);
                      } else {
                        print('hello');
                      }
                      
                    },
                  ),),
                  
                ],
                
              ),
            ),
          ),
        ],));
  }

  _handleImageSelection(String _option) async {
    final XFile? file = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: _option == 'gallery' ? ImageSource.gallery : ImageSource.camera,
    );

    if (file != null) {
      try {
        final bytes = await file.readAsBytes();
        final image = await decodeImageFromList(bytes);
        final Uint8List photo = await XFile(file.path).readAsBytes();

        // upload image to the cloud storage and get url
        //final fileName = basename(_photo!.path);
        final storageRef = FirebaseStorage.instance.ref('images/${file.name}');
        await storageRef.putData(photo);
        final imageUrl = await storageRef.getDownloadURL();

        // upload message info
        final msgId = const Uuid().v4();
        final timeStamp = DateTime.now().millisecondsSinceEpoch;

        DatabaseReference ref = FirebaseDatabase.instance.ref('rooms/$_roomId');
        final dynamic room = await ref.get();
        if (room.exists) {
          int unread = 0;
          if (room.value['lastSender'] == _roomId)
            unread = room.value['unread'] + 1;
          else
            unread = 1;
          await ref.update({
            'lastSender': _roomId,
            'unread': unread,
            'timestamp': timeStamp,
            'lastMessage': '사진을 보냈습니다',
          });
        } else {
          await ref.set({
            'status': 'status',
            'title': _nickname,
            'lastSender': _roomId,
            'unread': 1,
            'timestamp': timeStamp,
            'lastMessage': '사진을 보냈습니다',
          });
        }
        // messages info update
        DatabaseReference ref2 =
            FirebaseDatabase.instance.ref('messages/$_roomId/$msgId');
        await ref2.set({
          'authorId': _roomId,
          'type': 'image',
          'message': file.name,
          'height': image.height.toDouble(),
          'size': bytes.length,
          'uri': imageUrl,
          'width': image.width.toDouble(),
          'timestamp': timeStamp,
        });
        
        String msg = '[$_nickname] 사진을 보냈습니다';
        sendSlackMessage(msg);

        showDialog(context: context, builder: _successDialogBuilder);
      } catch(e) {
        showDialog(context:context, builder: _failingDialogBuilder);
      }
    } else {
      //showDialog(context:context, builder: _failingDialogBuilder);
    }
  }

  Widget _failingDialogBuilder(context){
    return AlertDialog(
      title: Text('사진 전송 실패'),
      content: Text('사진 전송에 실패했습니다. 다시 시도해주세요.'),
      actions: <Widget>[
        TextButton(child: Text('확인', style: TextStyle(color:Colors.white)), onPressed: (){Navigator.pop(context);},),
      ]
    );
  }

  Widget _successDialogBuilder(context){
    return AlertDialog(
      title: Text('사진 전송 성공'),
      content: Text('사진이 성공적으로 전송되었습니다. 해설을 기다려주세요. 구체적인 요구사항을 보내주시면 시간이 더 단축됩니다.'),
      actions: <Widget>[
        TextButton(child: Text('확인', style: TextStyle(color:Colors.white)), onPressed: (){Navigator.pop(context);},),
      ]
    );
  }

  _updateUnread() async {
    final ref = FirebaseDatabase.instance.ref('rooms/$_roomId');
    final dynamic room = await ref.get();
    if (room.exists && room.value['lastSender'] == 'admin') {
      await ref.update({
        'unread': 0,
      });
    }
  }

  List<ChatMessage> _jsonToMessages(json){
    final messages = json.keys.map((key) {
      final message = json['$key'];
      return ChatMessage(authorId: message['authorId'], 
        messageContent: message['message'], 
        messageType: message['type'], 
        createdAt: message['timestamp'],
        height: message['height'],
        width: message['width'],
        size: message['size'],
        uri: message['uri'],
      );
    });
    return List.from(messages)
      ..sort((a,b) => b.createdAt.compareTo(a.createdAt));
  }
}