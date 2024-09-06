// user_profile.dart

import 'package:flutter/material.dart';

class UserProfile extends StatelessWidget {
  final int userLevel; // 사용자 레벨
  final String nickname; // 사용자 닉네임
  final String iconUrl; // 아이콘 URL

  UserProfile({
    Key? key,
    this.userLevel = 1,
    this.nickname = '닉네임',
    this.iconUrl = 'https://img.icons8.com/color/96/babys-room.png',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width; // 화면의 너비

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