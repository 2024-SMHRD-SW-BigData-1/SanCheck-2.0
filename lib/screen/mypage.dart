// my_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sancheck/globals.dart';
import 'package:sancheck/screen/loading_page.dart';
import 'package:sancheck/service/auth_service.dart';
import 'my_info.dart'; // my_info.dart import
import 'mt_memo.dart'; // MtMemo 페이지 import
import 'my_medal.dart'; // MyMedal 페이지 import
import 'user_profile.dart'; // UserProfile import

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final AuthService _authService = AuthService(); // AuthService 인스턴스 생성
  late String _formattedDate;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    if (userModel == null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoadingPage()));
    }else{
      setState(() {
        _formattedDate = DateFormat('yyyy-MM-dd').format(userModel!.userBirthdate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if(userModel==null){
      return CircularProgressIndicator();
    }


    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5), // 배경색 설정
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: screenWidth * 0.9), // 최대 너비를 화면 너비의 90%로 설정
            child: Padding(
              padding: const EdgeInsets.all(16.0), // 화면 가장자리에서 일정한 여백 추가
              child: Column(
                children: [
                  _buildProfileSection(),
                  SizedBox(height: 20), // 프로필과 버튼들 사이 간격
                  _buildMenuButtons(), // 메뉴 버튼들을 포함한 위젯
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 프로필 섹션 위젯
  Widget _buildProfileSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: UserProfile(
        userLevel: 1, // 원하는 레벨을 설정하세요
        nickname: userModel!.userName,
        iconUrl: 'https://img.icons8.com/color/96/babys-room.png',
      ),
    );
  }

  // 메뉴 버튼들을 포함한 위젯
  Widget _buildMenuButtons() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch, // 버튼들을 stretch로 설정해 화면 너비에 맞춤
        children: [
          _buildMenuButton('내 정보'),
          SizedBox(height: 10),
          _buildMenuButton('등산 기록'),
          SizedBox(height: 10),
          _buildMenuButton('수집 메달'),
          SizedBox(height: 10),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  // 메뉴 버튼 생성 함수
  Widget _buildMenuButton(String title) {
    return SizedBox(
      width: double.infinity, // 화면 너비에 맞추기
      height: 50, // 버튼 높이 조정
      child: ElevatedButton(
        onPressed: () {
          // 버튼 클릭 시 실행할 기능
          switch (title) {
            case '내 정보':
              Navigator.push(context, MaterialPageRoute(builder: (_) => MyInfo(formattedDate: _formattedDate)));
              break;
            case '등산 기록':
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => MtMemo(mountainName: '북한산'))); // MtMemo로 이동
              break;
            case '수집 메달':
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => MyMedal())); // MyMedal로 이동
              break;
            default:
              return;
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green, // 초록색 버튼
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  // 로그아웃 버튼 생성 함수
  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity, // 화면 너비에 맞추기
      height: 50, // 버튼 높이 조정
      child: ElevatedButton(
        onPressed: () {
          handleLogout();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          '로그아웃',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  // 로그아웃 처리 함수
  void handleLogout() async {
    try {
      await _authService.logout(); // AuthService를 사용하여 로그아웃 처리
      userModel = null;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoadingPage()), // 이동할 페이지
            (Route<dynamic> route) => false, // 모든 이전 화면을 제거
      );
    } catch (e) {
      print('Logout failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('로그아웃 실패'), backgroundColor: Colors.redAccent));
    }
  }
}