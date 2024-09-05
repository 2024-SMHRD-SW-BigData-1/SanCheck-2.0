import 'package:flutter/material.dart';
import 'package:sancheck/screen/delete_id.dart';
import 'package:sancheck/screen/login_success.dart';
import 'package:sancheck/screen/user_profile.dart'; // UserProfile 위젯을 import

class MyInfo extends StatelessWidget {
  final String formattedDate; // formattedDate를 필드로 추가

  MyInfo({required this.formattedDate}); // 생성자에 formattedDate 추가

  @override
  Widget build(BuildContext context) {
    void _onItemTapped(int index) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => LoginSuccess(selectedIndex: index)),
            (Route<dynamic> route) => false,
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('내 정보',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Color(0xFFF5F5F5),
      ),
      backgroundColor: Color(0xFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: UserProfile(
                  userLevel: 1,
                  nickname: '팜하니',
                  iconUrl: 'https://img.icons8.com/color/96/babys-room.png',
                ),
              ),
              SizedBox(height: screenHeight * 0.05),

              // Info Section
              Container(
                padding: EdgeInsets.all(screenWidth * 0.06),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color(0xFFD9D9D9)),
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
                      icon: "https://img.icons8.com/tiny-color/64/birth-date.png",
                      label: '생년월일',
                      value: formattedDate, // 전달된 formattedDate 사용
                      iconSize: screenWidth * 0.08,
                      circleRadius: screenWidth * 0.1,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    InfoRow(
                      icon: "https://img.icons8.com/ios-glyphs/90/FA5252/ringer-volume.png",
                      label: '전화번호',
                      value: '010-1111-5555',
                      iconSize: screenWidth * 0.08,
                      circleRadius: screenWidth * 0.1,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    InfoRow(
                      icon: "https://img.icons8.com/tiny-color/64/new-post.png",
                      label: '이메일',
                      value: 'qwer@googole.com',
                      iconSize: screenWidth * 0.08,
                      circleRadius: screenWidth * 0.1,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    InfoRow(
                      icon: "https://img.icons8.com/tiny-color/64/gender.png",
                      label: '성별',
                      value: '여',
                      iconSize: screenWidth * 0.08,
                      circleRadius: screenWidth * 0.1,
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.04),

              // Account Settings Section
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => DeleteId()));
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color(0xFFE35154),
                    backgroundColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                    side: BorderSide(color: Color(0xFFD9D9D9)),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: screenWidth * 0.04),
                      Image.network(
                        'https://img.icons8.com/color/96/crying-baby.png',
                        width: screenWidth * 0.06,
                        height: screenWidth * 0.06,
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      Text('회원탈퇴',
                          style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.bold)),
                      Spacer(),
                      Image.network(
                        'https://img.icons8.com/ios-filled/50/double-right.png',
                        width: screenWidth * 0.06,
                        height: screenWidth * 0.06,
                      ),
                      SizedBox(width: screenWidth * 0.04),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white, // 하단바 배경색을 흰색으로 설정
        items: [
          BottomNavigationBarItem(
              icon: Image.network(
                'https://img.icons8.com/pulsar-line/96/mission-of-a-company.png',
                width: 24,
                height: 24,
              ),
              label: '등산하기'),
          BottomNavigationBarItem(
              icon: Image.network(
                'https://img.icons8.com/pulsar-line/96/home.png',
                width: 24,
                height: 24,
              ),
              label: 'HOME'),
          BottomNavigationBarItem(
              icon: Image.network(
                'https://img.icons8.com/pulsar-line/96/groups.png',
                width: 24,
                height: 24,
              ),
              label: '커뮤니티'),
          BottomNavigationBarItem(
              icon: Image.network(
                'https://img.icons8.com/pulsar-color/96/user-male-circle.png',
                width: 24,
                height: 24,
              ),
              label: '마이페이지'),
        ],
        currentIndex: 3,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
      ),
    );
  }
}

// InfoRow 위젯 정의
class InfoRow extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final double iconSize;
  final double circleRadius;

  InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.iconSize = 24.0,
    this.circleRadius = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      children: [
        CircleAvatar(
          radius: 30, // 원의 크기를 더 크게 설정
          backgroundColor: Color(0xFFF1F1F1),
          child: Image.network(
            icon,
            width: 30, // 아이콘 크기 조절
            height: 30,
          ),
        ),
        SizedBox(width: screenWidth * 0.04),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label  ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenWidth * 0.04,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: Color(0xFFB3B3B3),
                    fontSize: screenWidth * 0.04,
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
