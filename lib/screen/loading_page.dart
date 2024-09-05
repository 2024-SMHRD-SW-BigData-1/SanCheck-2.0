// 앱 시작 시 로딩 화면
// 위치권한, 로그인 여부 체크 + 산 데이터 전역변수에 저장해서 처음 지도 초기화 속도 빠르게

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
      _selectAllMountain();
      _readLoginInfo();
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


  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
      builder: (context) => AlertDialog(
        title: Text('위치 권한 설정'),
        content: Text('위치 권한이 필요합니다. 설정에서 권한을 허용해 주세요.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();  // 권한 설정 페이지로 이동
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginSuccess(selectedIndex: 1)),
      );
    }else{
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('~~~~~~~~~~~~산책~~~~~~~~~~~~~'),
      ),
    );
  }
}
