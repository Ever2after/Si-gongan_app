import 'dart:convert';
import 'package:http/http.dart' as http;

sendSlackMessage(String messageText) {
  var url = Uri.https('www.slack.com', '/api/chat.postMessage');

  //Makes request headers
  Map<String, String> requestHeader = {
    'Content-type': 'application/json',
    'Authorization':
        'Bearer xoxb-4820105539558-4820114104358-ki8WZlMsXjtRQc9QwbzF1m1Y'
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
