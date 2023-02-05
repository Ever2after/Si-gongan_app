import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String nickname = '';

  @override
  Widget build(BuildContext context) {
    final dynamic args = ModalRoute.of(context)!.settings.arguments;
    if (args == null) {
      return Scaffold(
        body: GetNickname(),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
            title: Text('닉네임 설정',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
        body: GetNickname(),
      );
    }
  }
}

class GetNickname extends StatefulWidget {
  const GetNickname({super.key});

  @override
  State<GetNickname> createState() => _GetNicknameState();
}

class _GetNicknameState extends State<GetNickname> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? nickname = '';

  @override
  void initState() {
    super.initState();
    _loadNickname();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 160.0, horizontal: 90.0),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 30.0),
                child: Text(
                  '당신의 닉네임은?',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 50.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: '입력',
                    hintText: '10자 이내',
                  ),
                  style: TextStyle(fontSize: 24),
                  validator: (String? value) {
                    // 글자수, 특수문자 등 제한 코드
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  onSaved: (String? value) async {
                    setState(() {
                      nickname = value;
                    });
                    // profile 등록 코드 ---------------------------
                    // using sharedpreferences -> fit
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setString('nickname', nickname!);
                    final id = prefs.getString('id');
                    final ref = FirebaseDatabase.instance.ref('users/$id');
                    await ref.set({'nickname': nickname});

                    final ref2 = FirebaseDatabase.instance.ref('rooms/$id');
                    final snapshot = await ref2.get();
                    if (snapshot.exists) await ref2.update({'title': nickname});

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$nickname님, 환영합니다.')),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: ElevatedButton(
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all(
                    EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  )),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('완료',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ));
  }

  void _loadNickname() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nickname = prefs.getString('nickname')!;
    });
  }
}
