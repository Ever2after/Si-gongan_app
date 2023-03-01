import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text('설정', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),), leading: Semantics(
        child:IconButton(
          icon:Icon(CupertinoIcons.left_chevron,),
          onPressed: (){Navigator.pop(context);},
        ),
        label: '뒤로가기 버튼',
        //excludeSemantics: true,
       )),
      body: ListView(
          children: [
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
        )
    );
  }
}