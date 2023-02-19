import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'selectScreen.dart';
import 'Home.dart';
import 'Loading.dart';
import 'Admin.dart';
import '../helper/auth.dart';

class Select extends StatefulWidget {
  const Select({super.key});

  @override
  State<Select> createState() => _SelectState();
}

class _SelectState extends State<Select> {
  Future<String> _lastScreen = AuthHelper.lastScreen();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _lastScreen,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == 'general') {
            return Loading();
          }
        } else {
          return SelectScreen();
        }
        return SelectScreen();
      },
    );
  }
}
