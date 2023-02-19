import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

sendSlackMessage(String messageText) {
  var url = Uri.https('www.slack.com', '/api/chat.postMessage');
  var token = dotenv.env['SLACK_BOT_TOKEN'];
  //Makes request headers
  Map<String, String> requestHeader = {
    'Content-type': 'application/json',
    'Authorization': 'Bearer $token'
  };

  var request = {
    'text': messageText,
    'channel': 'message_alert',
  };

  var result = http
      .post(url, body: json.encode(request), headers: requestHeader)
      .then((response) {
    print(json.decode(response.body));
  });
  print(result);
}
