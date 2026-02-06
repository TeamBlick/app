import 'package:flutter/material.dart';

void main() {
  runApp(Blick());
}

class Blick extends StatelessWidget {
  const Blick({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoWidth = size.width * 0.32;

    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white, //배경색 하얗게 만들기
        appBar: AppBar(), //앱 위쪽
        body: SingleChildScrollView(
          child: Padding(
            
            padding: const EdgeInsets.all(40), //사방에 padding 30을 넣을 예정
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start, //왼쪽 정렬
          
              children: [
                Center(
                  child: Image.asset(
                    "assets/images/App_Logo.png",
                    width: logoWidth,
                  ),
                ),
                SizedBox(height: 50),
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("아이디", style: TextStyle(color: Colors.grey)),
                      TextField(
                        decoration: InputDecoration(hintText: "아이디를 입력해주세요"),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 50),
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("비밀번호", style: TextStyle(color: Colors.grey)),
                      TextField(
                        obscureText: true,
                        decoration: InputDecoration(hintText: "비밀번호를 입력해주세요"),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 50),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(onPressed: () {},
                    child:Text("로그인",style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(83,102,251,1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                      )
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("도담도담으로"),
                    InkWell(
                      //로그인이라는 글자를 누르도록 만들려면 InkWell안에 어떤 코드를 넣어야하냐면
                      child: Text("로그인", style: TextStyle(color: Colors.blue)),
                      onTap: () {
                        //누르면 도담도담으로 로그인하는 사이트로 이동시키게
                        //걍 예시로
                        print("클릭됨");
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
