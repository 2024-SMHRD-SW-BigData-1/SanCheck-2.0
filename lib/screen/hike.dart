import 'dart:async';
import 'dart:io'; // 추가
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:sancheck/globals.dart';
import 'package:sancheck/provider/hike_provider.dart';
import 'package:sancheck/screen/hike_map.dart';
import 'package:sancheck/screen/hike_record.dart';
import 'package:sancheck/screen/login_success.dart';
import 'package:sancheck/service/flask_service.dart';
import 'package:shared_preferences/shared_preferences.dart';  // SharedPreferences 추가
import 'package:image_picker/image_picker.dart'; // 이미지 픽커 추가
import 'package:sancheck/screen/weather.dart';
import 'package:sancheck/screen/hike_record.dart'; // HikeRecordModal 정의 파일
import 'package:sancheck/screen/medal.dart'; // MedalModal 정의 파일


class Hike extends StatefulWidget {
  const Hike({super.key});

  @override
  _HikeState createState() => _HikeState();
}

class _HikeState extends State<Hike> {
  static const weatherIconUrl = 'https://img.icons8.com/fluency/96/weather.png';
  static const clockIconUrl = 'https://img.icons8.com/color/96/clock-pokemon.png';

  Future<void> _initializeNaverMapSdk() async {
    // 네이버 앱 인증
    await NaverMapSdk.instance.initialize(
      clientId: '119m2j9zpj',
      onAuthFailed: (ex) {
        print("********* 네이버맵 인증오류 : $ex *********");
      },
    );
  }

  // 날씨 api 모달
  void _showWeatherModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WeatherModal();
      },
    );
  }

  // 등산 기록 모달
  void _showHikeRecodeModal() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return HikeRecordModal();
        // return Dialog(
        //   backgroundColor: Colors.white,
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(20.0),
        //   ),
        //   child: HikeRecordModal(),
        // );
      },
    );
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
    // final hikeProvider = Provider.of<HikeProvider>(context);

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
              backgroundColor: Colors.white, // AppBar 전체 배경을 흰색으로 설정
              elevation: 0, // 그림자 제거
              title: Consumer<HikeProvider>(
                builder: (context, hikeProvider, child) {
                  return Column(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (selectedTrail != null && !hikeProvider.isTracking)
                        Text(
                          '선택된 등산로: ${selectedTrail!['trail_name']} ',
                          style: TextStyle(fontSize: 16),
                        ),
                      if (selectedTrail == null && !hikeProvider.isTracking)
                        Text(
                          '선택된 등산로: 없음 ',
                          style: TextStyle(fontSize: 16),
                        ),
                      if (selectedTrail == null && hikeProvider.isTracking)
                        Row(
                          children: [
                            Text(
                              '경과 시간: ',
                              style: TextStyle(fontSize: 16, color: Colors.black), // 텍스트 색상 설정
                            ),
                            Text(
                              _formatTime(hikeProvider.secondNotifier),
                              style: TextStyle(fontSize: 16, color: Colors.black), // 텍스트 색상 설정
                            ),
                          ],
                        ),
                      if (selectedTrail != null && hikeProvider.isTracking)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '선택된 등산로: ${selectedTrail!['trail_name']} ',
                              style: TextStyle(fontSize: 16),
                            ),
                            Row(
                              children: [
                                Text(
                                  '경과 시간: ',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  _formatTime(hikeProvider.secondNotifier),
                                  style: TextStyle(fontSize: 16, color: Colors.black), // 텍스트 색상 설정
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  );
                }
              ),
              foregroundColor: Colors.black,
              actions: [
                Consumer<HikeProvider>(
                  builder: (context, hikeProvider, child) {
                    // Consumer 내부에서 List<Widget> 생성 후 반환
                    if (selectedTrail != null && !hikeProvider.isTracking) {
                      return IconButton(
                        icon: Icon(Icons.dangerous),
                        onPressed: () {
                          setState(() {
                            selectedTrail = null;
                            selectedMountain = null;
                            selectedSpots = null;
                          });
                        },
                      );
                    } else {
                      return Container(); // 빈 위젯을 반환하여 오류 방지
                    }
                  },
                ),
              ],
            ),
            body: Stack(
              children: [
                const HikeMap(),
                const TimerButtons(),
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






///////////////////////////////////////////////////////////////////////////////////////////////////////////////


// 타이머 버튼&기능 클래스
class TimerButtons extends StatefulWidget {
  const TimerButtons({super.key});

  @override
  State<TimerButtons> createState() => _TimerButtonsState();
}

class _TimerButtonsState extends State<TimerButtons> {
  static const goIconUrl = 'https://img.icons8.com/ios-glyphs/90/40C057/go.png';
  static const pauseIconUrl = 'https://img.icons8.com/ios-filled/100/40C057/circled-pause.png';
  static const playIconUrl = 'https://img.icons8.com/ios-glyphs/90/40C057/circled-play.png';
  static const stopIconUrl = 'https://img.icons8.com/ios-filled/100/FA5252/stop-circled.png';
  bool _isTracking = false;
  bool _isPaused = false;
  Timer? _timer;
  ValueNotifier<int> _secondsNotifier = ValueNotifier<int>(0);
  SharedPreferences? _prefs;
  File? _capturedImage; // 촬영한 사진 저장 변수
  FlaskService _flaskService = FlaskService();

  // _isTracking의 getter
  bool get isTracking => _isTracking;

  // _secondsNotifier의 getter
  ValueNotifier<int> get secondsNotifier => _secondsNotifier;

  // prefs 인스턴스 생성
  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // _isTracking 토글
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

  // 타이머 시간 저장
  Future<void> _saveTimerValue(int seconds) async {
    await _prefs!.setInt('timer_value', seconds);
  }

  // 타이머 시작
  void _startTimer() {
    // Provider에서 HikeProvider 인스턴스를 가져옵니다.
    final hikeProvider = context.read<HikeProvider>();

    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      _secondsNotifier.value++;
      hikeProvider.updateSecondNotifier(_secondsNotifier.value);
      _saveTimerValue(_secondsNotifier.value); // 타이머 값 저장
    });
  }

  // 타이머 일시정지
  void _pauseTimer() {
    _timer?.cancel();
  }

  // 저장된 타이머 불러오기
  Future<void> _loadTimerValue() async {
    int savedSeconds = _prefs?.getInt('timer_value') ?? 0;
    _secondsNotifier.value = savedSeconds;
  }

  // 타이머 종료 메서드
  void _confirmStop() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Center(
            child: Text(
              '등산을 그만할까요?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          content: Text(
            '진행 중인 등산을 중단하고\n기록을 저장하시겠습니까?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      '아니오',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showPhotoOptionModal(); // 사진 촬영 여부 묻는 모달 호출
                    },
                    child: Text(
                      '예',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // 사진 촬영 여부 묻는 모달
  void _showPhotoOptionModal() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Center(
            child: Text(
              '사진 촬영?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          content: Text(
            '정상석 촬영 시 스탬프 획득 가능!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showHikeRecodeModal(); // 사진 촬영 안할 시 등산 기록 모달만 호출
                    },
                    child: Text(
                      '아니오',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _captureImage(); // 사진 촬영 할 시 카메라 촬영 호출
                    },
                    child: Text(
                      '예',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // 이미지 촬영 함수 수정
  Future<void> _captureImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    // 사진이 찍으면 동시에
    // 해야되는 것  
    // 1) 운동 기록 플라스크에 보내서 이미지로 저장  
    // 2) 사용자가 찍은 사진 플라스크에 보내서 yolo로 분석 후 일치하면 dallE제작 
    // 3) 불일치하면 다시 사진 찍을건지 물어보기
    if (pickedFile != null) {
      setState(() {
        _capturedImage = File(pickedFile.path);
      });
      await _sendImageToFlask(_capturedImage!);

      // 조건 체크 후 메달 모달 띄우기
      bool conditionMet = _capturedImage != null; // 실제 조건 체크 로직으로 교체
      if (conditionMet) {
        _showMedalModal(); // 조건 일치하면 메달 제작 로직
      } else {
        _showPhotoOptionModal(); // 조건을 만족하지 않으면 다시 사진 찍을건지 물어보기
      }
    } else {
      _showHikeRecodeModal(); // 사진을 찍지 않았을 경우에도 등산 기록 모달로 이동
    }
  }



  Future<void> _sendImageToFlask (File imageFile) async {
    await _flaskService.sendImageToFlask(imageFile);
  }



  // 메달 모달을 닫으면 등산 기록 모달을 호출
  void _showMedalModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MedalModal(
          medalImageUrl: 'https://example.com/medal.png',
        );
      },
    ).then((_) {
      _showHikeRecodeModal(); // 메달 모달이 닫힌 후 등산 기록 모달 호출
    });
  }

  // 등산 기록 모달
  void _showHikeRecodeModal() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return HikeRecordModal();
      },
    ).then((_) {
      // 등산 기록 모달이 닫힌 후 등산하기 페이지로 돌아옴
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // 등산하기 페이지로 이동
        _resetTimer();
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LoginSuccess(selectedIndex: 0), // 등산하기 페이지로 돌아가기
          ),
        );
        _resetTimer();
      }
    });
  }

  // 타이머 초기화
  void _resetTimer() {
    _pauseTimer();

    // Provider에서 HikeProvider 인스턴스를 가져옵니다.
    final hikeProvider = context.read<HikeProvider>();

    setState(() {
      _isTracking = false;
      _isPaused = false;
      _secondsNotifier.value = 0;
      _saveTimerValue(0); // 타이머 값 초기화 후 저장
    });

    // Provider의 상태 초기화
    hikeProvider.resetTracking(); // Provider의 초기화 메서드를 호출
    hikeProvider.resetSecond();
  }

  @override
  void initState() {
    super.initState();
    _loadTimerValue();
    _initPrefs();
  }


  @override
  void dispose() {
    _timer?.cancel();
    _secondsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hikeProvider = Provider.of<HikeProvider>(context, listen: false);
    return Positioned(
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
              onPressed: (){
                _toggleTracking();
                hikeProvider.toggleTracking();
              },
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
                      setState(() {
                        _isPaused = !_isPaused;
                        _startTimer();
                      });
                    } else {
                      setState(() {
                        _isPaused = !_isPaused;
                        _pauseTimer();
                      });
                    }
                  },
                ),
                if (_isPaused) // 타이머가 멈춘 상태에서만 stop(빨간색 네모) 아이콘을 표시
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
    );
  }
}
