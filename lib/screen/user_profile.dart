import 'package:flutter/material.dart';

class UserProfile extends StatelessWidget {
  final int userLevel; // 사용자 레벨
  final String nickname; // 사용자 닉네임

  UserProfile({
    Key? key,
    this.userLevel = 1,
    this.nickname = '닉네임', required String iconUrl,
  }) : super(key: key);

  // 레벨에 따른 아이콘 URL을 반환하는 함수
  String _getIconUrl(int level) {
    switch (level) {
      case 1:
        return 'https://img.icons8.com/external-yogi-aprelliyanto-flat-yogi-aprelliyanto/64/external-eggs-basket-spring-season-yogi-aprelliyanto-flat-yogi-aprelliyanto.png';
      case 2:
        return 'https://img.icons8.com/external-justicon-flat-justicon/64/external-chicken-easter-day-justicon-flat-justicon-1.png';
      case 3:
        return 'https://img.icons8.com/external-justicon-flat-justicon/64/external-chicken-easter-day-justicon-flat-justicon.png';
      case 4:
        return 'https://img.icons8.com/external-vitaliy-gorbachev-flat-vitaly-gorbachev/58/external-chicken-easter-vitaliy-gorbachev-flat-vitaly-gorbachev.png';
      case 5:
        return 'https://img.icons8.com/flat-round/64/crown--v1.png';
      default:
        return 'https://img.icons8.com/color/96/babys-room.png'; // 기본 아이콘
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width; // 화면의 너비
    final iconUrl = _getIconUrl(userLevel); // 레벨에 따른 아이콘 URL 가져오기

    return Row(
      children: [
        CircleAvatar(
          radius: screenWidth * 0.07, // 화면 크기에 맞춰 크기 조정
          backgroundColor: Color(0xFFCBCBCB),
          backgroundImage: NetworkImage(iconUrl), // 아이콘 이미지를 설정
        ),
        SizedBox(width: screenWidth * 0.05),
        Flexible(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Lv.$userLevel ', // 레벨에 따른 등급 표시
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenWidth * 0.05,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                TextSpan(
                  text: nickname,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenWidth * 0.05,
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
