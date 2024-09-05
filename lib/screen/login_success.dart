import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sancheck/provider/mountain_provider.dart';
import 'package:sancheck/screen/chat.dart';
import 'hike.dart';
import 'home.dart';
import 'community.dart';
import 'mypage.dart';

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
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // BottomNavigationBar 아이템을 탭할 때 호출되는 메서드
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

  // AppBar의 제목을 현재 페이지에 따라 설정하는 메서드
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

  // AppBar의 액션 버튼을 설정하는 메서드
  List<Widget> _getAppBarActions() {
    return [
      IconButton(
        icon: Image.network(
          'https://img.icons8.com/doodle/96/retro-robot.png',
          width: 32,
          height: 32,
        ),
        onPressed: _showChatPage,
      ),
    ];
  }

  // 채팅 페이지를 모달로 표시하는 메서드
  void _showChatPage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: ChatPage(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 상단의 AppBar 설정
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(),
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFF5F5F5),
        actions: _getAppBarActions(),
      ),
      // 메인 콘텐츠 영역을 PageView로 구성
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
      // 하단 네비게이션 바 설정
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        items: [
          BottomNavigationBarItem(
            icon: _selectedIndex == 0
                ? Image.network(
              'https://img.icons8.com/pulsar-color/96/mission-of-a-company.png',
              width: 24,
              height: 24,
            )
                : Image.network(
              'https://img.icons8.com/pulsar-line/96/mission-of-a-company.png',
              width: 24,
              height: 24,
            ),
            label: '등산하기',
          ),
          BottomNavigationBarItem(
            icon: _selectedIndex == 1
                ? Image.network(
              'https://img.icons8.com/pulsar-color/96/home.png',
              width: 24,
              height: 24,
            )
                : Image.network(
              'https://img.icons8.com/pulsar-line/96/home.png',
              width: 24,
              height: 24,
            ),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: _selectedIndex == 2
                ? Image.network(
              'https://img.icons8.com/pulsar-color/96/groups.png',
              width: 24,
              height: 24,
            )
                : Image.network(
              'https://img.icons8.com/pulsar-line/96/groups.png',
              width: 24,
              height: 24,
            ),
            label: '커뮤니티',
          ),
          BottomNavigationBarItem(
            icon: _selectedIndex == 3
                ? Image.network(
              'https://img.icons8.com/pulsar-color/96/user-male-circle.png',
              width: 24,
              height: 24,
            )
                : Image.network(
              'https://img.icons8.com/pulsar-line/96/user-male-circle.png',
              width: 24,
              height: 24,
            ),
            label: '마이페이지',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
      ),
    );
  }
}
