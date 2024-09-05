import 'package:flutter/material.dart';
import 'package:sancheck/globals.dart';
import 'package:sancheck/screen/delete_id.dart';
import 'package:sancheck/screen/loading_page.dart';
import 'package:sancheck/screen/login_success.dart';

class MyInfo extends StatefulWidget {

  final String formattedDate;

  // 생성자를 통해 user와 formattedDate를 받음
  MyInfo({required this.formattedDate});


  @override
  State<MyInfo> createState() => _MyInfoState();
}

class _MyInfoState extends State<MyInfo> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }



  @override
  Widget build(BuildContext context) {

    if(userModel==null){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>LoadingPage()));
    }

    void _onItemTapped(int index) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginSuccess(selectedIndex: index)), // 이동할 페이지
            (Route<dynamic> route) => false, // 모든 이전 화면을 제거
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('내 정보', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Color(0xFFF5F5F5),
      ),
      backgroundColor: Color(0xFFF5F5F5), // 배경색을 Home 페이지와 동일하게 설정
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Home 페이지와 동일하게 패딩 설정
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 27,
                    backgroundColor: Color(0xFFCBCBCB),
                    backgroundImage: NetworkImage("https://via.placeholder.com/54"),
                  ),
                  SizedBox(width: 20),
                  Text.rich(
                    TextSpan(
                      children: [
                        // 레벨
                        TextSpan(
                          text: '등린이 ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        
                        // 이름 
                        TextSpan(
                          text: userModel!.userName,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),

            // Info Section
            Container(
              width: 340,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xFFD9D9D9)), // 테두리 색상 Home 페이지와 동일하게 설정
                boxShadow: [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 4,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoRow(
                    icon: "https://via.placeholder.com/35x35",
                    label: '생년월일',
                    value: widget.formattedDate,
                  ),
                  SizedBox(height: 20),
                  InfoRow(
                    icon: "https://via.placeholder.com/45x45",
                    label: '전화번호',
                    value: userModel!.userPhone,
                  ),
                  SizedBox(height: 20),
                  InfoRow(
                    icon: "https://via.placeholder.com/45x45",
                    label: '이메일',
                    value: userModel!.userId,
                  ),
                  SizedBox(height: 20),
                  InfoRow(
                    icon: "https://via.placeholder.com/30x30",
                    label: '성별',
                    value: userModel!.userGender == 'M' ?'남성':'여성',
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),

            // Account Settings Section
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white, // 버튼 배경색을 흰색으로 설정
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFC7C7C7),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  // 회원탈퇴 버튼 동작
                  Navigator.push(context, MaterialPageRoute(builder: (_)=>DeleteId()));
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Color(0xFFE35154), // 글씨 색상을 E35154로 설정
                  backgroundColor: Colors.transparent, // 배경색을 투명으로 설정
                  padding: EdgeInsets.symmetric(vertical: 20), // 버튼의 상하 패딩 설정
                  side: BorderSide(color: Color(0xFFD9D9D9)), // 테두리 색상 #D9D9D9로 설정
                  elevation: 0, // 그림자 제거
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ), // 버튼 클릭 시 색상 #C7C7C7로 설정
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 16), // 왼쪽에 공백 추가
                    Image.network(
                      'https://img.icons8.com/fluency/96/christmas-star.png',
                      width: 24, // 아이콘 크기 조정
                      height: 24,
                    ),
                    SizedBox(width: 16), // 아이콘과 텍스트 사이의 공백 추가
                    Text('회원탈퇴', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), // 글자색 E35154로 설정 및 굵게 변경
                    Spacer(), // 왼쪽 공백을 최대화
                    Image.network(
                      'https://img.icons8.com/ios-filled/50/double-right.png',
                      width: 24, // 아이콘 크기 조정
                      height: 24,
                    ),
                    SizedBox(width: 16), // 오른쪽 공백 추가
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Image.network(
                'https://img.icons8.com/pulsar-line/96/mission-of-a-company.png',
                width: 24, height: 24,
              ), label: '등산하기'),

          BottomNavigationBarItem(
              icon: Image.network(
                'https://img.icons8.com/pulsar-line/96/home.png',
                width: 24, height: 24,
              ),
              label: 'HOME'),

          BottomNavigationBarItem(
              icon:Image.network(
                'https://img.icons8.com/pulsar-line/96/groups.png',
                width: 24, height: 24,
              ), label: '커뮤니티'),

          BottomNavigationBarItem(
              icon: Image.network(
                'https://img.icons8.com/pulsar-color/96/user-male-circle.png',
                width: 24, height: 24,), label: '마이페이지'),
        ],
        currentIndex: 3,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black, // 선택된 아이템의 텍스트 색상
        unselectedItemColor: Colors.black, // 선택되지 않은 아이템의 텍스트 색상
      ),

    );
  }
}






// InfoRow 클래스 정의
class InfoRow extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22.5,
          backgroundColor: Color(0xFFF1F1F1),
          child: Image.network(icon),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label  ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: Color(0xFFB3B3B3),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}