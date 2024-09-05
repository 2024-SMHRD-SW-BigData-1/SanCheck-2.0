import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sancheck/provider/mountain_provider.dart';
import 'package:sancheck/screen/chat.dart';
import 'hike.dart'; // 'Hike' 클래스를 포함한 파일을 import
import 'home.dart'; // 'Home' 클래스를 포함하는 파일을 import
import 'community.dart'; // 'Community' 클래스를 포함하는 파일을 import
import 'mypage.dart'; // 'MyPage' 클래스를 포함하는 파일을 import



class LoginSuccess extends StatefulWidget {

  final int selectedIndex;
  LoginSuccess({required this.selectedIndex});

  @override
  State<LoginSuccess> createState() => _LoginSuccessState();
}

class _LoginSuccessState extends State<LoginSuccess> {

  late PageController _pageController;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _pageController = PageController(initialPage: _selectedIndex);  // 초기 페이지 설정
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  void _onItemTapped(int index) {
    Provider.of<MountainProvider>(context, listen: false).resetMountain();
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  // 현재 선택된 페이지에 따라 AppBar의 제목을 반환하는 메서드
  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return '등산하기';
      case 1:
        return 'HOME';
      case 2:
        return '커뮤니티';
      case 3:
        return '마이페이지';
      default:
        return '';
    }
  }

  // 현재 선택된 페이지에 따라 AppBar의 actions를 반환하는 메서드
  List<Widget>? _getAppBarActions() {
      return [
        IconButton(
          icon: Image.network(
            'https://img.icons8.com/doodle/96/retro-robot.png',
            width: 32,
            height: 32,
          ),
          onPressed: _showChatPage, // 아이콘 클릭 시 채팅 페이지 팝업
        ),
      ];
  }

  void _showChatPage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: ChatPage(), // ChatPage가 chat.dart에서 정의된 페이지입니다.
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), // 현재 선택된 페이지에 따른 제목
        centerTitle: true,
        backgroundColor: Color(0xFFF5F5F5),
        actions: _getAppBarActions(), // actions를 동적으로 설정
      ),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
            Provider.of<MountainProvider>(context, listen: false).resetMountain();
          },
          children: [
            Hike(),
            Home(),
            Community(),
            MyPage(),
          ],
        ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: _selectedIndex == 0
              ? Image.network(
                'https://img.icons8.com/pulsar-color/96/mission-of-a-company.png',
            width: 24, height: 24,)
              : Image.network(
                'https://img.icons8.com/pulsar-line/96/mission-of-a-company.png',
            width: 24, height: 24,
          ), label: '등산하기'),

          BottomNavigationBarItem(
              icon: _selectedIndex == 1
              ? Image.network(
            'https://img.icons8.com/pulsar-color/96/home.png',
            width: 24, height: 24,)
              : Image.network(
            'https://img.icons8.com/pulsar-line/96/home.png',
            width: 24, height: 24,
          ), label: 'HOME'),

          BottomNavigationBarItem(
              icon: _selectedIndex == 2
                  ? Image.network(
                'https://img.icons8.com/pulsar-color/96/groups.png',
                width: 24, height: 24,)
                  : Image.network(
                'https://img.icons8.com/pulsar-line/96/groups.png',
                width: 24, height: 24,
              ), label: '커뮤니티'),

          BottomNavigationBarItem(
              icon: _selectedIndex == 3
                  ? Image.network(
                'https://img.icons8.com/pulsar-color/96/user-male-circle.png',
                width: 24, height: 24,)
                  : Image.network(
                'https://img.icons8.com/pulsar-line/96/user-male-circle.png',
                width: 24, height: 24,
              ), label: '마이페이지'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black, // 선택된 아이템의 텍스트 색상
        unselectedItemColor: Colors.black, // 선택되지 않은 아이템의 텍스트 색상
      ),
    );
  }

}


