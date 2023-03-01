import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Usage extends StatefulWidget {
  const Usage({super.key});

  @override
  State<Usage> createState() => _UsageState();
}

class _UsageState extends State<Usage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text('사용 방법', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),), leading: Semantics(
        child:IconButton(
          icon:Icon(CupertinoIcons.left_chevron,),
          onPressed: (){Navigator.pop(context);},
        ),
        label: '뒤로가기 버튼',
       )),
    body: SingleChildScrollView(child: Column(children: [
       _textBox(
                      '안녕하세요, 시각장애인을 위한 일대일 시각자료묘사 서비스, 시공간에 오신 것을 환영합니다. 서비스 이용 방법을 알려드리겠습니다.'),
                  _textBox(
                      '홈 화면 중앙에 4개의 버튼이 있습니다. 물어보기 버튼을 눌러 채팅방에 입장할 수 있습니다.'),
                  _textBox(
                      '채팅방 왼쪽 아래의 사진 전송 버튼을 눌러 해설이 필요한 사진을 전송하세요. 구체적인 요구사항을 같이 보내주시면 더욱 빠르고 자세하게 해설해드립니다.'),
                  _textBox(
                      '평균 해설 소요 시간은 10분입니다. 해설진 사정에 따라 답변 시간이 상이할 수 있습니다.'),
                  _textBox(
                      '폭언, 욕설 채팅 혹은 선정성, 혐오성 이미지 전송 시 서비스 이용이 영구적으로 제한됩니다.'),
                  _textBox(
                      '닉네임 변경 버튼을 통해 닉네임을 변경할 수 있습니다. 닉네임은 해설자에게 보여지는 이름입니다.'),
                  _textBox(
                      '설정 버튼을 눌러 더 다양한 정보를 확인할 수 있습니다. 시각장애인만을 위한 시각자료묘사 서비스 시공간을 지금 바로 이용해보세요!')
                

    ],),) );
  }

  Widget _textBox(String text){
    return Container(
      padding: EdgeInsets.all(20),
      child: Text(text, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
    );
  }
}