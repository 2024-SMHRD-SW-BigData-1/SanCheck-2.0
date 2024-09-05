import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:location/location.dart';
import 'package:sancheck/screen/hike_record.dart';
import 'package:shared_preferences/shared_preferences.dart';  // SharedPreferences 추가
import 'package:sancheck/screen/weather.dart';
import 'package:sancheck/screen/medal.dart'; // MedalModal 정의 파일



class Hike extends StatefulWidget {
  const Hike({super.key});

  @override
  _HikeState createState() => _HikeState();
}

class _HikeState extends State<Hike> {
  Location location = Location();
  static const goIconUrl = 'https://img.icons8.com/ios-glyphs/90/40C057/go.png';
  static const pauseIconUrl = 'https://img.icons8.com/ios-filled/100/40C057/circled-pause.png';
  static const playIconUrl = 'https://img.icons8.com/ios-glyphs/90/40C057/circled-play.png';
  static const stopIconUrl = 'https://img.icons8.com/ios-filled/100/FA5252/stop-circled.png';
  static const weatherIconUrl = 'https://img.icons8.com/fluency/96/weather.png';
  static const clockIconUrl = 'https://img.icons8.com/color/96/clock-pokemon.png';
  NCameraPosition _cameraPosition = const NCameraPosition(
      target: NLatLng(37.5665, 126.978),
      zoom: 10,
      bearing: 0,
      tilt: 0,
    );

  bool _isTracking = false;
  bool _isPaused = false;
  Timer? _timer;
  ValueNotifier<int> _secondsNotifier = ValueNotifier<int>(0);


  @override
  void initState() {
    super.initState();
    _initialize(); // 지도 초기화
  }



Future<void> _initialize() async{
  WidgetsFlutterBinding.ensureInitialized();
  final LocationData currentLocation = await location.getLocation();

  double nx = (currentLocation.latitude!);
  double ny = (currentLocation.longitude!);

  _cameraPosition = NCameraPosition(
  target: NLatLng(nx, ny),
  zoom: 10,
  bearing: 0,
  tilt: 0,
  );
  // 네이버 앱 인증
  await NaverMapSdk.instance.initialize(
    clientId: '119m2j9zpj',
    onAuthFailed: (ex) {
    print("********* 네이버맵 인증오류 : $ex *********");
    },
  );

  // 위치 서비스 확인 및 요청
  bool _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      return;
    }
  }

  // 위치 권한 확인 및 요청
  PermissionStatus _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      return;
    }
  }
  await _loadTimerValue();  // 앱 시작 시 저장된 타이머 값 불러오기
}


  Future<void> _initializeNaverMapSdk() async {
    await NaverMapSdk.instance.initialize(clientId: '119m2j9zpj');
  }

  Future<void> _saveTimerValue(int seconds) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('timer_value', seconds);
  }

  Future<void> _loadTimerValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int savedSeconds = prefs.getInt('timer_value') ?? 0;
    _secondsNotifier.value = savedSeconds;
  }


  void _showWeatherModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WeatherModal();
      },
    );
  }

  void _showHikeRecodeModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return HikeRecordModal();
      },
    );
  }

  void _toggleTracking() {
    setState(() {
      _isTracking = !_isTracking;

      if (_isTracking) {
        _startTimer();
        _isPaused = false;
      } else {
        _pauseTimer();
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      _secondsNotifier.value++;
      _saveTimerValue(_secondsNotifier.value);  // 타이머 값 저장
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
  }

  void _confirmStop() async {
    return showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(
            '등산을 그만할까요?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Text(
            '진행 중인 등산을 중단하고 \n 기록을 저장하시겠습니까?',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(
                '아니오',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text(
                '예',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: CupertinoColors.destructiveRed,
                ),
              ),
              onPressed: () {
                _resetTimer();
                Navigator.of(context).pop(); // 대화 상자를 닫고 상태를 초기화
                _showHikeRecodeModal(); // 기존 모달 호출
                _showMedalModal(); // 메달 모달 호출
              },
            ),
          ],
        );
      },
    );
  }

  void _showMedalModal() {
    // 조건 체크 및 MedalModal 표시
    bool conditionMet = true; // 실제 조건 체크 로직으로 교체
    if (conditionMet) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return MedalModal(
            medalImageUrl: 'https://example.com/medal.png', // 실제 메달 이미지 URL로 교체
          );
        },
      );
    }
  }

  void _resetTimer() {
    _pauseTimer();
    setState(() {
      _isTracking = false;
      _isPaused = false;
      _secondsNotifier.value = 0;
      _saveTimerValue(0);  // 타이머 값 초기화 후 저장
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _secondsNotifier.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int hours = minutes ~/ 60;
    final int remainingMinutes = minutes % 60;
    final int remainingSeconds = seconds % 60;

    return '${hours.toString().padLeft(2, '0')}:${remainingMinutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeNaverMapSdk(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isTracking)
                    Row(
                      children: [
                        Text(
                          '경과 시간: ',
                          style: TextStyle(fontSize: 16),
                        ),
                        ValueListenableBuilder<int>(
                          valueListenable: _secondsNotifier,
                          builder: (context, seconds, child) {
                            return Text(
                              _formatTime(seconds),
                              style: TextStyle(fontSize: 16),
                            );
                          },
                        ),
                      ],
                    ),
                ],
              ),
              backgroundColor: Colors.grey[200],
              elevation: 0,
              foregroundColor: Colors.black,
            ),
            body: Stack(
              children: [
                NaverMap(
                  forceGesture: true,
                  options: NaverMapViewOptions(
                    initialCameraPosition: _cameraPosition,
                    consumeSymbolTapEvents: false,
                    locationButtonEnable: true,
                    logoClickEnable: false,
                    minZoom: 5, // default is 0
                    maxZoom: 17, // default is 21
                    extent: const NLatLngBounds(
                      southWest: NLatLng(31.43, 122.37),
                      northEast: NLatLng(44.35, 132.0),
                    ),
                  ),
                  onMapReady: (controller) {
                    print("등산하기 맵 로딩 완료");
                    NLocationTrackingMode mode = NLocationTrackingMode.follow;
                    controller.setLocationTrackingMode(mode);
                  },
                ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!_isTracking) // 타이머가 작동 중이지 않을 때 Go 버튼만 표시
                        IconButton(
                          icon: Image.network(
                            goIconUrl,
                            width: 48,
                            height: 48,
                          ),
                          onPressed: _toggleTracking,
                        ),
                      if (_isTracking) // 타이머가 작동 중일 때는 버튼을 업데이트
                        Row(
                          children: [
                            IconButton(
                              icon: Image.network(
                                _isPaused ? playIconUrl : pauseIconUrl,
                                width: 48,
                                height: 48,
                              ),
                              onPressed: () {
                                if (_isPaused) {
                                  // When paused, clicking the button should resume tracking
                                  setState(() {
                                    _isPaused = false;
                                    _startTimer();
                                  });
                                } else {
                                  // When tracking, clicking the button should pause tracking
                                  setState(() {
                                    _isPaused = true;
                                    _pauseTimer();
                                  });
                                }
                              },
                            ),
                            if (_isPaused) // 타이머가 멈춘 상태에서만 stop 아이콘을 표시
                              IconButton(
                                icon: Image.network(
                                  stopIconUrl,
                                  width: 32,
                                  height: 32,
                                ),
                                onPressed: _confirmStop, // stop 아이콘 클릭 시 초기화
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 80,
                  left: 20,
                  child: IconButton(
                    icon: Image.network(
                      weatherIconUrl,
                      width: 48,
                      height: 48,
                    ),
                    onPressed: _showWeatherModal,
                  ),
                ),
                Positioned(
                  bottom: 80,
                  right: 20,
                  child: IconButton(
                    icon: Image.network(
                      clockIconUrl,
                      width: 48,
                      height: 48,
                    ),
                    onPressed: _showHikeRecodeModal,
                  ),
                ),
              ],
            ),

          );
        }
      },
    );
  }
}
