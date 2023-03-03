import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../helper/arguments.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Sigongan/helper/notification.dart';
import 'package:Sigongan/helper/slack.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  String _myId = '';
  String _nickName = '';
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  @override
  Widget build(BuildContext context) {
    LocalNotification.requestPermission();
    final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text('홈',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ))),
        /*
        endDrawer: Drawer(
          semanticLabel: "설정 메뉴 열기",
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
                  Text('설정',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
                ]),
              ),
            ),
            ListTile(
                onTap: () {
                  Navigator.pushNamed(context, '/login',
                      arguments: {'isFirst': false});
                },
                leading: Icon(CupertinoIcons.person_solid),
                title: Text('닉네임 변경',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            ListTile(
                onTap: () {
                  launchUrl(Uri.parse(
                      'https://sigongan.notion.site/sigongan/240c0475323a48a094b9de346a13f04a'));
                },
                leading: Icon(CupertinoIcons.person_2_fill),
                title: Text('팀 시공간 소개',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            ListTile(
                onTap: () {
                  launchUrl(Uri.parse('https://www.instagram.com/si_gongan/'));
                },
                leading: Icon(CupertinoIcons.speaker_1_fill),
                title: Text('공지사항',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            ListTile(
                onTap: () {
                  launchUrl(Uri.parse('mailto:ever2after1@gmail.com'));
                },
                leading: Icon(CupertinoIcons.mail_solid),
                title: Text('문의하기',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            ListTile(
                onTap: () {
                  launchUrl(Uri.parse(
                      'https://sites.google.com/view/sigongan/%ED%99%88'));
                },
                leading: Icon(CupertinoIcons.doc_fill),
                title: Text('개인정보처리방침',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            ListTile(
                onTap: () async {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/selectScreen', (r) => false);
                },
                leading: Icon(CupertinoIcons.delete_left_fill),
                title: Text('시작화면으로 나가기',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          ],
        )),*/
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
                      return _ColumnBuilder(unread, size, false);
                    } else {
                      return _ColumnBuilder(0, size, false);
                    }
                  } else {
                    return _ColumnBuilder(0, size, true);
                  }
                })));
  }

  Widget _ColumnBuilder(int n, size, [isLoading = true]) {
    final double length = 120;
    final double fontSize = 20;
    final double gap = 24;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          child: Text(n > 0 ? '$n개의 새 메세지가 있습니다' : '도착한 메세지가 없습니다',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: n > 0 ? Colors.white : Colors.white30)),
          margin: EdgeInsets.symmetric(vertical: 30),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    alignment: Alignment.center,
                    fixedSize: Size(length, length)),
                onPressed: () {
                  Navigator.pushNamed(context, '/chat4blind',
                      arguments: MyArguments(_myId, _nickName));
                },
                child: Text(
                  '물어보기',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )),
            Container(width: gap),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    alignment: Alignment.center,
                    fixedSize: Size(length, length)),
                onPressed: () {
                  /*
                  showDialog(
                          context: context,
                          builder: (context) =>
                              StatefulBuilder(builder: _DiaglogBuilder))
                      .then(((value) {
                    setState(() {
                      pageIndex = 0;
                    });
                  }));
                  */
                  Navigator.pushNamed(context, '/usage');
                },
                child: Text('사용방법',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          ],
        ),
        Container(height: gap),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                child: Text('닉네임\n변경',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                    alignment: Alignment.center,
                    fixedSize: Size(length, length)),
                onPressed: () {
                  Navigator.pushNamed(context, '/login', arguments: {"isFirst": false});
                }),
            Container(width: gap),
            ElevatedButton(
              child: Text('설정',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                  alignment: Alignment.center, fixedSize: Size(length, length)),
              onPressed: () {
                Navigator.pushNamed(context, '/setting');
              },
            ),
          ],
        )
      ],
    );
  }

  Widget _DiaglogBuilder(BuildContext _context, StateSetter setState) {
    final size = MediaQuery.of(_context).size;
    return Dialog(
        insetPadding: EdgeInsets.symmetric(
            horizontal: size.width * 0.1, vertical: size.height * 0.2),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 40, horizontal: 0),
              child: PageView(
                onPageChanged: (value) {
                  setState(() {
                    pageIndex = value;
                  });
                },
                children: [
                  _PageBuilder(
                      '안녕하세요, 시각장애인을 위한 일대일 시각자료묘사 서비스, 시공간에 오신 것을 환영합니다. 서비스 이용 방법을 알려드리겠습니다.'),
                  _PageBuilder(
                      '홈 화면 중앙에 4개의 버튼이 있습니다. 물어보기 버튼을 눌러 채팅방에 입장할 수 있습니다.'),
                  _PageBuilder(
                      '채팅방 왼쪽 아래의 미디어 보내기 버튼을 눌러 해설이 필요한 사진을 전송하세요. 구체적인 요구사항을 같이 보내주시면 더욱 빠르고 자세하게 해설해드립니다.'),
                  _PageBuilder(
                      '평균 해설 소요 시간은 10분입니다. 해설진 사정에 따라 답변 시간이 상이할 수 있습니다.'),
                  _PageBuilder(
                      '폭언, 욕설 채팅 혹은 선정성, 혐오성 이미지 전송 시 서비스 이용이 영구적으로 제한됩니다.'),
                  _PageBuilder(
                      '닉네임 변경 버튼을 통해 닉네임을 변경할 수 있습니다. 닉네임은 해설자에게 보여지는 이름입니다.'),
                  _PageBuilder(
                      '홈 화면 맨 오른쪽 위에 위치한 버튼을 눌러 설정 탭을 이용할 수 있습니다. 시각장애인만을 위한 시각자료묘사 서비스 시공간을 지금 바로 이용해보세요!')
                ],
              ),
            ),
            Container(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(CupertinoIcons.xmark),
                onPressed: () {
                  Navigator.pop(_context);
                },
              ),
            ),
            Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                alignment: Alignment.topLeft,
                child: Text(
                  '${pageIndex + 1} / 7',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ))
          ],
        ));
  }

  Widget _PageBuilder(String text) {
    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Text(
          text,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ));
  }

  void _loadInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _myId = prefs.getString('id')!;
      _nickName = prefs.getString('nickname') ?? '';
    });
  }

  List<String> _intro = [
    '안녕하세요, 시각장애인을 위한 일대일 시각자료묘사 서비스, 시공간에 오신것을 환영합니다.',
    '반갑습니다',
    'ㅁㅁㅁㅁ'
  ];
}
