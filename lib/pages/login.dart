import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String nickname = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetNickname(),
    );
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
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 30.0),
              child: Text('당신의 닉네임은?'),
            ),
            TextFormField(
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
                /* using sqlite -> 굳이...
                String fid = await AuthHelper.getUserId();
                String nickname = this.nickname!;
                final user = User(fid: fid, nickname: nickname);
                await UserHelper.add(user);
                */
                // using sharedpreferences -> fit
                final prefs = await SharedPreferences.getInstance();
                prefs.setString('nickname', nickname!);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$value님, 환영합니다.')),
                );
              },
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Navigator.pop(context);
                  }
                },
                child: const Text('완료'),
              ),
            )
          ],
        ));
  }
}
