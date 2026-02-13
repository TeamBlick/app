import 'package:flutter/material.dart';

void main() {
  runApp(blick());
}

class blick extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white, //배경색 하얗게 만들기
        appBar: AppBar(), //앱 위쪽
        body: Padding(padding:
          const EdgeInsets.all(30.0), //사방에 padding 30을 넣을 예정
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, //왼쪽 정렬
            children: [
              Image.asset("assets/images/App_Logo.png"),
              SizedBox(height: 50,)
            ],//로고,input,버튼 들어갈 예정
          ),
        ),
      ),
    );
  }
}