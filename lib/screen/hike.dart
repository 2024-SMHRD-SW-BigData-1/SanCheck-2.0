import 'dart:async';
import 'dart:convert';
import 'dart:io'; // 추가
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:location/location.dart';
import 'package:pedometer/pedometer.dart';
import 'package:provider/provider.dart';
import 'package:sancheck/globals.dart';
import 'package:sancheck/provider/hike_provider.dart';
import 'package:sancheck/screen/hike_map.dart';
import 'package:sancheck/screen/hike_record.dart';
import 'package:sancheck/screen/login_success.dart';
import 'package:shared_preferences/shared_preferences.dart';  // SharedPreferences 추가
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences 추가
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

  // 위도, 경도, LineString 배열 생성
  List<double> loc_lst_lat = [];
  List<double> loc_lst_lon = [];
  List<double> loc_lst = [];

  // pedometer로 운동 데이터 로딩
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  int _initialSteps = 0;
  int _currentSteps = 0;
  int _stepsOffset = 0;
  double _useCal = 0;
  double rounded_use_cal = 0;

  final _storage = FlutterSecureStorage();

  void onStepCount(StepCount event) {
      _currentSteps = event.steps - _initialSteps - _stepsOffset; // 오프셋을 고려한 걸음 수 계산
      _useCal = _currentSteps * 70.0 * 0.0005;
      rounded_use_cal = double.parse(_useCal.toStringAsFixed(2));
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
    setState(() {
      _stepsOffset = _currentSteps + _stepsOffset; // 오프셋 업데이트
      _currentSteps = 0; // 걸음 수 리셋
    });
  }



  String _selectedItem = '등산하기';
  NLatLng? _currentPosition;
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
  List<NLatLng> _coords = [];

  File? _capturedImage; // 촬영한 사진 저장 변수

  @override
  void initState() {
    super.initState();
    _loadTimerValue(); // 앱 시작 시 저장된 타이머 값 불러오기
    _initialize();
    initPlatformState();
  }



  Future<void> _initialize() async{
    WidgetsFlutterBinding.ensureInitialized();
    Location location = Location();
    final LocationData currentLocation = await location.getLocation();

    double nx = (currentLocation.latitude!);
    double ny = (currentLocation.longitude!);



    _cameraPosition = NCameraPosition(
      target: NLatLng(nx, ny),
      zoom: 10,
      bearing: 0,
      tilt: 0,
    );
  Future<void> _initializeNaverMapSdk() async {
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


    // 경로 정보 set
    setState(() {
      _coords = selectedTrail!['trail_path']!.map<NLatLng>((point) {
        return NLatLng(point['x'], point['y']);
      }).toList();
    });

  }

// spot을 지도에 추가하는 함수
  Future<void> addSpotsToMap(controller) async {
    if (selectedSpots!.isEmpty || selectedSpots==null){
      return;
    }
    NOverlayImage image =  await NOverlayImage.fromWidget(widget: Icon(Icons.add_alert), size: Size(5.0, 5.0), context: context);
    // 맵 컨트롤러가 준비된 후 마커를 추가하도록 수정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      selectedSpots!.forEach((spot) {
        // mountain은 배열 안의 각 객체(산 정보)를 나타냅니다.
        final marker = NMarker(
          id: spot['spot_idx'].toString(), // 스팟의 고유 ID
          icon: image,
          position: NLatLng(double.parse(spot['spot_latitude']),double.parse(spot['spot_longitude'])), // 마커의 위치 설정
          size: Size(20, 25), // 마커의 크기 설정
          caption: NOverlayCaption(text: spot['spot_name'], textSize: 12.0, color: spot['spot_danger']=='t'?Colors.red:Colors.black),
          isHideCollidedSymbols: true,
        );

        // 마커를 지도에 추가
        controller.addOverlay(marker);
        marker.setOnTapListener(
                (NMarker marker)=>{
              print("마커 클릭됨"),
            }
        );
      });
    });
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

  // 위치 발견 후 세팅
  void getLoc() async {
    Location location = Location();
    var loc = await location.getLocation();
    var lat = loc.latitude;
    var lon = loc.longitude;

    setState(() {
      _currentPosition = NLatLng(lat!, lon!);
      _cameraPosition = NCameraPosition(
        target: _currentPosition!,
        zoom: 15,
      );
    });
  }

  void _onNavItemSelected(String value) {
    setState(() {
      _selectedItem = value;
    });
  }

  void _showWeatherModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WeatherModal();
      },
    );
  }


  Location _location = Location();


  // 현재 위치를 리스트에 추가
  void get_route() async{
    // 경로 초기화
    print("경로 저장");

        // 현재 위치 받아오기
        var get_location = await _location.getLocation();
        double? now_lat = get_location.latitude;
        double? now_lon = get_location.longitude;

        // 받아온 위치 리스트에 저장
        if (now_lat != null && now_lon != null){
          loc_lst_lat.add(now_lat);
          loc_lst_lon.add(now_lon);
        }
        print("lat : ${now_lat}");
        print("lon : ${now_lon}");

  }

  void reset_route(){
    loc_lst_lat.clear();
    loc_lst_lon.clear();
  }

  String combinedString = "";

  // 저장된 경로 리스트를 lineString 형태로 전환
  void get_route_lst () {

    for(int i = 0; i < loc_lst_lat.length; i++){
      loc_lst.add(loc_lst_lat[i]);
      loc_lst.add(loc_lst_lon[i]);
    }

    // Linestring 형태로 전환
    combinedString = loc_lst.asMap().entries.map((entry) {
      if(entry.key % 2 == 0){
        return '${loc_lst[entry.key]} ${loc_lst[entry.key + 1]}';
      } else {
        return null;
      }
    }).where((element) => element != null).join(', ');

  }

  // 저장된 lineStiring 형태의 경로를 DB에 업로드
  Future<void> save_route() async {
    get_route_lst();
    Dio dio = Dio();

    if(loc_lst.isEmpty){
      print("Error : Location list is empty");
      return;
    }

    String linestring = "LineString($combinedString)";

    String url = "http://192.168.219.204:8000/mountain/upload";
    print("currentSteps : $_currentSteps");
    String? user = await _storage.read(key: "user");
    Map<String, dynamic> userMap = jsonDecode(user!);
    String? user_id = userMap['user_id'];
    print("user_id : ${user_id}");
    print("lineStirng : $linestring");

    print("trail_idx : $selectedTrail");

    try{
      Response res = await dio.post(url, data: {
        "user_id": user_id,
        "trail_idx" : 1,
        "hiking_date": DateTime.now().toIso8601String(),
        "hiking_steps": _currentSteps,
        "hiking_state": true,
        "hiking_time": "실제 시간",
        "hiking_route": linestring
      });

      print(res.statusCode);
      print(res.realUri);

      getImg();
    } catch (e) {
      print('Error sending request: $e');
    }
  }

  // 저장된 경로를 통해 지도에 이미지로 그려 저장
void getImg() async{
    Dio dio = Dio();
    String? user_name = await _storage.read(key: "user");
    String url = "http://192.168.219.167:5050/drawMap";

    try{
      Response res = await dio.get(url, queryParameters: {
        "user_id" : user_name
      });
    }catch (e){
      print("Error sending request: $e");
    }
}

  // 데이터 업로드 기점으로 설정
  Future<void> _captureImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _capturedImage = File(pickedFile.path);
      });

      // 조건 체크 후 메달 모달 띄우기
      bool conditionMet = _capturedImage != null; // 실제 조건 체크 로직으로 교체
      if (conditionMet) {
        _showMedalModal();
      }
    }
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
    ).then((_) {
      // HikeRecordModal이 닫힌 후 카메라 촬영 기능 실행
      _captureImage();
    });
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
    int cnt = 0;
    // Provider에서 HikeProvider 인스턴스를 가져옵니다.
    final hikeProvider = context.read<HikeProvider>();

    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      cnt++;
      print(cnt);
      _secondsNotifier.value++;
      hikeProvider.updateSecondNotifier(_secondsNotifier.value);
      _saveTimerValue(_secondsNotifier.value); // 타이머 값 저장
      if(cnt % 2 == 0){
        get_route();
      }
    });
  }

  // 타이머 일시정지
  void _pauseTimer() {
    _timer?.cancel();
  }

  // 저장된 타이머 불러오기
  Future<void> _loadTimerValue() async {
    int savedSeconds = _prefs!.getInt('timer_value') ?? 0;
    _secondsNotifier.value = savedSeconds;
  }

  // 타이머 종료 메서드
  void _confirmStop() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // 모달창 배경색을 하얀색으로 설정
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0), // 둥근 모서리 설정
          ),
          title: Center(
            child: Text(
              '등산을 그만할까요?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20, // 글씨 크기 2p 키움
              ),
            ),
          ),
          content: Text(
            '진행 중인 등산을 중단하고\n기록을 저장하시겠습니까?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18), // 글씨 크기 2p 키움
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 100, // 버튼의 동일한 너비 설정
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12), // 버튼의 높이 조정
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // 모달창 닫기
                    },
                    child: Text(
                      '아니오',
                      style: TextStyle(color: Colors.white, fontSize: 16), // 글씨 크기 2p 키움
                    ),
                  ),
                ),
                SizedBox(
                  width: 100, // 버튼의 동일한 너비 설정
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12), // 버튼의 높이 조정
                    ),
                    onPressed: () async{
                      await _resetTimer();
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
                      style: TextStyle(color: Colors.white, fontSize: 16), // 글씨 크기 2p 키움
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
  Future<void> _captureImage() async async{
    await save_route();
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    // 사진이 찍혔을 때
    // 해야되는 것  1) 운동 기록 플라스크에 보내서 이미지로 저장  2) 사용자가 찍은 사진 플라스크에 보내서 yolo로 분석 후 분석 된 산 가져오기
    if (pickedFile != null) {
      setState(() {
        _capturedImage = File(pickedFile.path);
      });

      // 조건 체크 후 메달 모달 띄우기
      bool conditionMet = _capturedImage != null; // 실제 조건 체크 로직으로 교체
      if (conditionMet) {
        _showMedalModal(); // 메달 모달을 띄우고
      } else {
        _showHikeRecodeModal(); // 조건을 만족하지 않으면 등산 기록 모달로 이동
      }
    } else {
      _showHikeRecodeModal(); // 사진을 찍지 않았을 경우에도 등산 기록 모달로 이동
    }
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
        _resetTimer();
        Navigator.pop(context); // 등산하기 페이지로 이동
      } else {
        _resetTimer();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LoginSuccess(selectedIndex: 0), // 등산하기 페이지로 돌아가기
          ),
        );
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