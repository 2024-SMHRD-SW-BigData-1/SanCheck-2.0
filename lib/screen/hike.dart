import 'dart:async';
import 'dart:io'; // 추가
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:location/location.dart';
import 'package:pedometer/pedometer.dart';
import 'package:provider/provider.dart';
import 'package:sancheck/globals.dart';
import 'package:sancheck/provider/hike_provider.dart';
import 'package:sancheck/screen/hike_map.dart';
import 'package:sancheck/screen/hike_record.dart';
import 'package:sancheck/screen/login_success.dart';
import 'package:sancheck/service/hiking_service.dart';
import 'package:shared_preferences/shared_preferences.dart';  // SharedPreferences 추가
import 'package:image_picker/image_picker.dart'; // 이미지 픽커 추가
import 'package:sancheck/screen/weather.dart';
import 'package:sancheck/screen/hike_record.dart'; // HikeRecordModal 정의 파일
import 'package:sancheck/screen/medal.dart'; // MedalModal 정의 파일

// pedometer로 운동 데이터 로딩
late Stream<StepCount> _stepCountStream;
late Stream<PedestrianStatus> _pedestrianStatusStream;
int _initialSteps = 0;
int _stepsOffset = 0;
double _useCal = 0;
double _useDist = 0;


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

  // Timer? _timer;
  // SharedPreferences? _prefs;
  File? _capturedImage; // 촬영한 사진 저장 변수
  bool _isLoading = false;
  HikingService _hikingService = HikingService();

  // 위도, 경도, LineString 배열 생성
  // List<double> loc_lst_lat = [];
  // List<double> loc_lst_lon = [];
  // List<double> loc_lst = [];


  void onStepCount(StepCount event) {
    final hikeProvider = Provider.of<HikeProvider>(context, listen: false);
    if (!hikeProvider.isPaused) {
      hikeProvider.updateCurrentSteps(
          event.steps - _initialSteps - _stepsOffset);

      //print("걸음 수 측정");
      // _currentSteps = event.steps - _initialSteps - _stepsOffset; // 오프셋을 고려한 걸음 수 계산
      //print(hikeProvider.currentSteps);
      _useCal = hikeProvider.currentSteps * 70.0 * 0.0005;
      _useDist = hikeProvider.currentSteps / 1000;

      hikeProvider.updateRoundedUseCal(double.parse(_useCal.toStringAsFixed(2)));
      hikeProvider.updateRoundedDistance(double.parse(_useDist.toStringAsFixed(2)));
    }
  }

  void onStepCountError(error) {
    print('Step Count Error: $error');
  }

  Future<void> initPlatformState() async {
    _stepCountStream = Pedometer.stepCountStream;

    _stepCountStream.listen((event) {
      if (_initialSteps == 0) {
        setState(() {
          _initialSteps = event.steps; // 최초의 걸음 수 저장
        });
      }
      onStepCount(event);
    }).onError(onStepCountError);
  }

  void resetSteps() {
    final hikeProvider = Provider.of<HikeProvider>(context, listen: false);
    setState(() {
      _stepsOffset = hikeProvider.currentSteps + _stepsOffset; // 오프셋 업데이트
      hikeProvider.resetCurrentSteps(); // 걸음 수 리셋
    });
  }


  // // 현재 위치를 리스트에 추가
  // void get_route() async{
  //   Location _location = Location();
  //
  //   // 경로 초기화
  //   print("경로 저장");
  //
  //   // 현재 위치 받아오기
  //   var get_location = await _location.getLocation();
  //   double? now_lat = get_location.latitude;
  //   double? now_lon = get_location.longitude;
  //
  //   // 받아온 위치 리스트에 저장
  //   if (now_lat != null && now_lon != null){
  //     loc_lst_lat.add(now_lat);
  //     loc_lst_lon.add(now_lon);
  //   }
  //   print("lat : ${now_lat}");
  //   print("lon : ${now_lon}");
  //
  // }


  // void reset_route(){
  //   loc_lst_lat.clear();
  //   loc_lst_lon.clear();
  // }


  // String combinedString = "";

  // 저장된 경로 리스트를 lineString 형태로 전환
  // void get_route_lst () {
  //
  //   for(int i = 0; i < loc_lst_lat.length; i++){
  //     loc_lst.add(loc_lst_lat[i]);
  //     loc_lst.add(loc_lst_lon[i]);
  //   }
  //
  //   // Linestring 형태로 전환
  //   combinedString = loc_lst.asMap().entries.map((entry) {
  //     if(entry.key % 2 == 0){
  //       return '${loc_lst[entry.key]} ${loc_lst[entry.key + 1]}';
  //     } else {
  //       return null;
  //     }
  //   }).where((element) => element != null).join(', ');
  //
  // }


  // 저장된 lineStiring 형태의 경로를 DB에 업로드
  Future<bool> save_route() async {
    setState(() {
      _isLoading = true;
    });

    final hikeProvider = Provider.of<HikeProvider>(context, listen: false);
    Dio dio = Dio();

    print("db업로드 시작");
    await hikeProvider.get_route_lst();

    if (hikeProvider.loc_lst.isEmpty) {
      print("Error : Location list is empty");
      return false;
    }
    String linestring = "LineString(${hikeProvider.combinedString})";

    String url = "http://192.168.219.200:8000/mountain/uploadHikingResult";
    //print("currentSteps : $_currentSteps");
    String user_id = userModel!.userId;
    print("user_id : ${user_id}");
    print("lineStirng : $linestring");

    print("trail_idx : ${selectedTrail ?? '선택된 등산로 없음'}");
    print(selectedMountain?["mount_name"] ?? '선택된 산 없음');

    try {
      Response res = await dio.post(url, data: {
        "user_id": user_id,
        "mount_name" : selectedMountain?["mount_name"],
        "trail_idx": selectedTrail?["trail_idx"],
        "hiking_date": DateTime.now().toIso8601String(),
        "hiking_steps": hikeProvider.currentSteps,
        "hiking_state": 1,
        "hiking_time": hikeProvider.secondNotifier,
        "hiking_route": linestring,
        "hiking_dist" : hikeProvider.roundedDistance
      });

      print(res.statusCode);
      print(res.realUri);

      setState(() {
        _isLoading = false;
      });
      return res.data['success'];
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error sending request: $e');
      return false;
    }
  }

  // prefs 인스턴스 생성
  // Future<void> _initPrefs() async {
  //   _prefs ??= await SharedPreferences.getInstance();
  //   // await _loadTimerValue();
  // }


  // // 타이머 데이터 영구 저장
  // Future<void> _saveTimerValue() async {
  //   await _prefs!.setInt('timer_value', _secondsNotifier.value);
  //   await _prefs!.setBool('isTracking', _isTracking);
  //   await _prefs!.setBool('isPaused', _isPaused);
  // }

  // // 타이머 시작
  // void _startTimer() {
  //   // Provider에서 HikeProvider 인스턴스를 가져옵니다.
  //   final hikeProvider = Provider.of<HikeProvider>(context, listen: false);
  //
  //   hikeProvider.togglePaused();
  //
  //   _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
  //     hikeProvider.updateSecondNotifier(hikeProvider.secondNotifier+1);
  //     print(hikeProvider.secondNotifier);
  //     // _saveTimerValue(); // 타이머 값 저장
  //     if(hikeProvider.secondNotifier % 2 == 0){
  //       get_route();
  //     }
  //   });
  // }

  // // 타이머 일시정지
  // void _pauseTimer() {
  //   final hikeProvider = Provider.of<HikeProvider>(context, listen: false);
  //   hikeProvider.togglePaused();
  //   _timer?.cancel();
  // }

  // 저장된 타이머 불러오기
  // Future<void> _loadTimerValue() async {
  //   int savedSeconds = _prefs?.getInt('timer_value') ?? 0;
  //   bool isTracking = _prefs?.getBool('isTracking') ?? false;
  //   bool isPaused = _prefs?.getBool('isPaused') ?? true;
  //
  //   setState(() {
  //     _secondsNotifier.value = savedSeconds;
  //     _isTracking = isTracking;
  //     _isPaused = isPaused;
  //   });
  //
  //   print('ssss $_isTracking');
  //   print('ffff $_isPaused');
  // }


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
            style: TextStyle(fontSize: 16),
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
                    onPressed: () async {
                      Navigator.of(context).pop();
                      bool isSuccess = await save_route();

                      if (isSuccess) {
                        _showPhotoOptionModal(); // 사진 촬영 여부 묻는 모달 호출
                      } else {
                        _showFailedModal(); // 실패 시 실패창
                      }
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

  void _showFailedModal() {
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
              '서버 통신 실패',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.red
              ),
            ),
          ),
          content: Text(
            '나중에 다시 시도하세요.',
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
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) =>
                              LoginSuccess(selectedIndex: 0), // 등산하기 페이지로 돌아가기
                        ),
                      );
                      _resetTimer();
                    },
                    child: Text(
                      '확인',
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
              '사진을 촬영하시겠습니까?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,

              ),
            ),
          ),
          content: Text(
            '정상석 촬영 시 \n 스탬프 획득 가능합니다!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
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
                      setState(() {
                        _isLoading = false;
                      });
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
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await _captureImage(); // 사진 촬영 할 시 카메라 촬영 호출
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


  // 오류나서 다시 사진 촬영 여부 묻는 모달
  void _againPhotoOptionModal() {
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
              '정상석과 일치하는 산이 없습니다.',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.red

              ),
            ),
          ),
          content: Text(
            '다시 촬영하시겠습니까?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
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
                      setState(() {
                        _isLoading = false;
                      });
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
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await _captureImage(); // 사진 촬영 할 시 카메라 촬영 호출
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
    setState(() {
      _isLoading = true;
    });

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    // 사진이 찍으면 동시에
    // 해야되는 것
    // 1) 사용자가 찍은 사진 플라스크에 보내서 yolo로 분석 후 일치하면 dallE제작
    // 2) 불일치하면 다시 사진 찍을건지 물어보기
    if (pickedFile != null) {
      setState(() {
        _capturedImage = File(pickedFile.path);
      });
      // 조건 체크 후 메달 모달 띄우기
      Map<String, dynamic> res =  await _hikingService.sendImageToFlask(_capturedImage!);

      if (res['success']) {
        _showMedalModal(res['url']); // 조건 일치하면 메달 제작 로직
      } else {
        _againPhotoOptionModal(); // 조건을 만족하지 않으면 다시 사진 찍을건지 물어보기
      }
    } else {
      _againPhotoOptionModal(); // 사진 안찍혔으면 다시 사진찍을건지 물어보는 모달
    }
  }


  // 메달 모달을 닫으면 등산 기록 모달을 호출
  void _showMedalModal(String url) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MedalModal(
          medalImageUrl: url,
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
            builder: (context) =>
                LoginSuccess(selectedIndex: 0), // 등산하기 페이지로 돌아가기
          ),
        );
        _resetTimer();
      }
    });
  }

  // 타이머 초기화
  void _resetTimer() async {
    // Provider에서 HikeProvider 인스턴스를 가져옵니다.
    final hikeProvider = context.read<HikeProvider>();

    // Provider의 상태 초기화
    hikeProvider.resetTimer();
    hikeProvider.resetTracking();
    hikeProvider.resetPaused();
    hikeProvider.resetSecond();
    hikeProvider.resetCurrentSteps();
    hikeProvider.resetRoundedUseCal();
    hikeProvider.resetRoundedDistance();
    hikeProvider.reset_route();
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
    // _initPrefs();
  }


  @override
  void dispose() {
    super.dispose();
    // _timer?.cancel();
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        title: Center(
          child: Text(
            '서버 통신 중...',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.red,
            ),
          ),
        ),
        // CircularProgressIndicator 제거된 부분
        content: SizedBox(
            height: 100, child: Center(child: Text('잠시만 기다려 주세요'))),
      );
    }

    final hikeProvider = Provider.of<HikeProvider>(context, listen: true);
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!hikeProvider.isTracking) // 타이머가 작동 중이지 않을 때 Go 버튼만 표시
            IconButton(
              icon: Image.network(
                goIconUrl,
                width: 48,
                height: 48,
              ),
              onPressed: () {
                hikeProvider.toggleTracking();
                hikeProvider.startTimer();
              },
            )
          else // 타이머가 작동 중일 때는 버튼을 업데이트
            Row(
              children: [
                IconButton(
                  icon: Image.network(
                    hikeProvider.isPaused ? playIconUrl : pauseIconUrl,
                    width: 48,
                    height: 48,
                  ),
                  onPressed: () {
                    if (hikeProvider.isPaused) {
                      hikeProvider.startTimer();
                    } else {
                      hikeProvider.pauseTimer();
                    }
                  },
                ),
                if (hikeProvider.isPaused) // 타이머가 멈춘 상태에서만 stop(빨간색 네모) 아이콘을 표시
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



