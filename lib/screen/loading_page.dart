// 앱 시작 시 로딩 화면
// 위치권한, 로그인 여부 체크 + 모든 산 데이터 전역변수에 저장해서 처음 지도 초기화 속도 빠르게
// 관심있는 산을 전역변수로 가져온 다음, 이후 별표 누를 때마다 서버 통신 진행되는 동시에 전역변수 값도 바꿔서 사용자 경험 향상

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sancheck/globals.dart';
import 'package:sancheck/model/user_model.dart';
import 'package:sancheck/screen/login_page.dart';
import 'package:sancheck/screen/login_success.dart';
import 'package:sancheck/service/auth_service.dart';
import 'package:sancheck/service/mountain_service.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> with WidgetsBindingObserver {
  final AuthService _authService = AuthService(); // Create instance of AuthService
  final MountainService _mountainService = MountainService(); // MountainService 인스턴스 생성

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }

  Future<void> _checkPermission() async {
    var status = await Permission.location.status;

    if (status.isDenied) {
      // 권한이 거절된 경우
      _showPermissionDialog();
    } else if (status.isGranted) {
      // 권한이 허용된 경우
      await _selectAllMountain();
      await _readLoginInfo();
    } else if (status.isPermanentlyDenied) {
      // 권한이 영구적으로 거절된 경우
      _showPermissionSettingsDialog();
    }
  }

  Future<void> _selectAllMountain() async {
    try {
      List<dynamic> mountains = await _mountainService.fetchAllMountains();
      allMountains = mountains;
    } catch (e) {
      print("Error fetching all mountains: $e");
    }
  }

  Future<void> _selectFavMountain(String userId) async{
    try {
      List<dynamic> mountains = await _mountainService.searchFavMountain(userId);
      favMountains = mountains;
    } catch (e) {
      print("Error fetching fav mountains: $e");
    }
  }


  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('위치 권한 필요'),
            content: Text('이 앱은 위치 권한이 필요합니다. 권한을 허용해 주세요.'),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  var status = await Permission.location.request();
                  if (status.isDenied) {
                    _showPermissionSettingsDialog();
                  } else if (status.isGranted) {
                    _readLoginInfo();
                  }
                },
                child: Text('권한 요청'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('취소'),
              ),
            ],
          ),
    );
  }

  void _showPermissionSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('위치 권한 설정'),
            content: Text('위치 권한이 필요합니다. 설정에서 권한을 허용해 주세요.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  openAppSettings(); // 권한 설정 페이지로 이동
                },
                child: Text('설정으로 이동'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('취소'),
              ),
            ],
          ),
    );
  }

  // 이미 로그인 돼있다면 로그인 성공 페이지로 이동
  Future<void> _readLoginInfo() async {
    UserModel? user = await _authService.readLoginInfo();

    if (user != null) {
      userModel = user;

      await _selectFavMountain(userModel!.userId); // 페이지 이동 전 관심있는 산 가져오기
      print('favMountain : $favMountains');
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginSuccess(selectedIndex: 1)),
      );
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;

    return Scaffold(
      backgroundColor: Colors.white, // 배경색 설정
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 아이콘 이미지 추가 (크기를 화면 비율에 맞게 조정)
            Image.network(
              'https://img.icons8.com/external-smashingstocks-flat-smashing-stocks/66/external-Mountain-vacation-and-traveling-smashingstocks-flat-smashing-stocks.png',
              width: screenWidth * 0.4, // 화면 너비의 40%로 설정
              height: screenHeight * 0.25, // 화면 높이의 25%로 설정
              fit: BoxFit.contain, // 이미지가 잘 맞도록 설정
            ),
            SizedBox(height: 30), // 이미지와 인디케이터 사이 간격
            // 로딩 중인 애니메이션 효과 추가
            CircularProgressIndicator(
              color: Colors.green, // 로딩 인디케이터 색상
              strokeWidth: 3.0, // 인디케이터의 두께
            ),
            SizedBox(height: 20), // 인디케이터와 텍스트 사이 간격
            Text(
              'SANCHECK', // 로딩 중인 메시지
              style: TextStyle(
                fontSize: screenWidth * 0.05, // 화면 크기에 맞춰 텍스트 크기 설정
                fontWeight: FontWeight.bold,
                color: Colors.black54, // 텍스트 색상
              ),
            ),
          ],
        ),
      ),
    );
  }
}
