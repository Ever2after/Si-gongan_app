import 'package:flutter/cupertino.dart';
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
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
            title: Text('닉네임 설정',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), leading: Semantics(
        child:IconButton(
          icon:Icon(CupertinoIcons.left_chevron,),
          onPressed: (){Navigator.pop(context);},
        ),
        label: '뒤로가기 버튼',
       )),
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
    final size = MediaQuery.of(context).size;
    return Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: size.height * 0.1, horizontal: size.width * 0.1),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: size.height * 0.1),
                child: Text(
                  '닉네임을 입력해주세요',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: size.height * 0.05),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: '입력',
                    hintText: '10자 이내',
                  ),
                  style: TextStyle(fontSize: 24),
                  validator: (String? value) {
                    // 글자수, 특수문자 등 제한 코드
                    if (value == null || value.isEmpty) {
                      return '닉네임을 입력해주세요';
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
                padding: EdgeInsets.fromLTRB(0, size.height * 0.1, 0, 0),
                child: ElevatedButton(
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all(
                    EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  )),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/loading', (r) => false);
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
