import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SelectScreen extends StatefulWidget {
  const SelectScreen({super.key});

  @override
  State<SelectScreen> createState() => _SelectScreenState();
}

class _SelectScreenState extends State<SelectScreen> {
  bool authSuccess = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.1),
                Text(
                  '사람이 직접 제공하는\n맞춤형 시각자료묘사 서비스',
                  //textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: size.height * 0.05),
                Text('시공간',
                    style:
                        TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                SizedBox(height: size.height * 0.1),
                Container(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        prefs.setString('lastScreen', 'general');
                        Navigator.pushNamed(context, '/loading');
                      },
                      child: Container(
                          alignment: Alignment.center,
                          height: 100,
                          width: size.width * 0.7,
                          child: Text(
                            textAlign: TextAlign.center,
                            '시각자료묘사 서비스가\n 필요합니다',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ))),
                ),
                SizedBox(height: 20),
                Container(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final isAdmin = prefs.getBool('isAdmin') ?? false;
                        if (isAdmin) {
                          Navigator.pushNamed(context, '/admin');
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                StatefulBuilder(builder: _DialogBuilder),
                          ).then((val) async {
                            if (authSuccess) {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              prefs.setBool('isAdmin', true);
                              prefs.setString('lastScreen', 'admin');
                              Navigator.pushNamed(context, '/admin');
                            } else {
                              // print('failed');
                            }
                          });
                        }
                      },
                      child: Container(
                          alignment: Alignment.center,
                          height: 100,
                          width: size.width * 0.7,
                          child: Text(
                            textAlign: TextAlign.center,
                            '해설자로 활동하고 있습니다',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ))),
                ),
              ],
            )));
  }

  Widget _DialogBuilder(BuildContext _context, StateSetter setState) {
    final myController = TextEditingController();
    final size = MediaQuery.of(_context).size;
    return AlertDialog(
      title: Text('해설자 인증'),
      content: TextField(
        decoration: InputDecoration(hintText: "인증 토큰을 입력해주세요"),
        controller: myController,
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('취소', style: TextStyle(color: Colors.redAccent))),
        TextButton(
            onPressed: () {
              final value = myController.text;
              if (value.isNotEmpty && value != null) {
                try {
                  //Map<String, dynamic> payload = parseJwtPayLoad(value);
                  //if (payload['id'] == 'sigongan.first') {
                  if (value == dotenv.env['ADMIN_TOKEN']) {
                    setState(() {
                      authSuccess = true;
                    });
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('토큰 정보가 올바르지 않습니다'),
                      elevation: 10,
                    ));
                    Navigator.pop(context);
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('올바른 형식의 토큰이 아닙니다'), elevation: 10));
                  Navigator.pop(context);
                }
              }
            },
            child: Text('완료', style: TextStyle(color: Colors.white)))
      ],
    );
    /*
    return AlertDialog(
        insetPadding: EdgeInsets.symmetric(
            horizontal: size.width * 0.1, vertical: size.height * 0.2),
        title: Text('하위'),
        content: Form(
          key: _formKey,
          child: TextFormField(
              decoration: InputDecoration(hintText: "인증 토큰을 입력해주세요"),
              validator: ((String? value) {
                if (value == null || value.isEmpty) {
                  return '토큰을 입력해주세요';
                } else {
                  try {
                    Map<String, dynamic> payload = parseJwtPayLoad(value);
                    if (payload['id'] == 'sigongan.first') {
                      return null;
                    } else
                      return '인증에 실패했습니다';
                  } catch (e) {
                    return '잘못된 형식의 토큰입니다';
                  }
                }
              }),
              onSaved: ((String? value) {
                setState(
                  () {
                    authSuccess = true;
                  },
                );
                Navigator.pop(context);
              })),
        ),
        actions: [
          IconButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                }
              },
              icon: Icon(CupertinoIcons.check_mark))
        ]);
        */
  }

  String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!"');
    }

    return utf8.decode(base64Url.decode(output));
  }

  Map<String, dynamic> parseJwtPayLoad(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('invalid token');
    }

    final payload = _decodeBase64(parts[1]);
    final payloadMap = json.decode(payload);
    if (payloadMap is! Map<String, dynamic>) {
      throw Exception('invalid payload');
    }

    return payloadMap;
  }
}
