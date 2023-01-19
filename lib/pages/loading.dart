import 'package:flutter/material.dart';
import '../helper/auth.dart';
import 'home.dart';
import 'login.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  Future<bool> _isFirst = AuthHelper.isFirst();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isFirst,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        List<Widget> children;
        if (snapshot.hasData) {
          if (!snapshot.data!) {
            return Home();
          } else {
            return Login();
          }
        } else if (snapshot.hasError) {
          return Scaffold(
              body: Column(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Error: ${snapshot.error}'),
              ),
            ],
          ));
        } else {
          return Scaffold(
              body: Column(
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Awaiting data...'),
              ),
            ],
          ));
        }
      },
    );
  }
}
