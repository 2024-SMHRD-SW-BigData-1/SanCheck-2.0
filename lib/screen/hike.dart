import 'dart:async';
import 'dart:io'; // 추가
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:location/location.dart';
import 'package:sancheck/globals.dart';
import 'package:sancheck/screen/hike_record.dart';
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
  static const goIconUrl = 'https://img.icons8.com/ios-glyphs/90/40C057/go.png';
  static const pauseIconUrl = 'https://img.icons8.com/ios-filled/100/40C057/circled-pause.png';
  static const playIconUrl = 'https://img.icons8.com/ios-glyphs/90/40C057/circled-play.png';
  static const stopIconUrl = 'https://img.icons8.com/ios-filled/100/FA5252/stop-circled.png';
  static const weatherIconUrl = 'https://img.icons8.com/fluency/96/weather.png';
  static const clockIconUrl = 'https://img.icons8.com/color/96/clock-pokemon.png';

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
  }

  Future<void> _initialize() async {
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
    await _loadTimerValue(); // 앱 시작 시 저장된 타이머 값 불러오기

    // 경로 정보 set
    setState(() {
      _coords = selectedTrail!['trail_path']!.map<NLatLng>((point) {
        return NLatLng(point['x'], point['y']);
      }).toList();
    });
  }

  // spot을 지도에 추가하는 함수
  Future<void> addSpotsToMap(controller) async {
    if (selectedSpots!.isEmpty || selectedSpots == null) {
      return;
    }
    NOverlayImage image = await NOverlayImage.fromWidget(widget: Icon(Icons.add_alert), size: Size(5.0, 5.0), context: context);
    // 맵 컨트롤러가 준비된 후 마커를 추가하도록 수정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      selectedSpots!.forEach((spot) {
        // mountain은 배열 안의 각 객체(산 정보)를 나타냅니다.
        final marker = NMarker(
          id: spot['spot_idx'].toString(), // 스팟의 고유 ID
          icon: image,
          position: NLatLng(double.parse(spot['spot_latitude']), double.parse(spot['spot_longitude'])), // 마커의 위치 설정
          size: Size(20, 25), // 마커의 크기 설정
          caption: NOverlayCaption(text: spot['spot_name'], textSize: 12.0, color: spot['spot_danger']=='t'?Colors.red:Colors.black),
          isHideCollidedSymbols: true,
        );

        // 마커를 지도에 추가
        controller.addOverlay(marker);
        marker.setOnTapListener((NMarker marker) => {
          print("마커 클릭됨"),
        });
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

  void _showWeatherModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WeatherModal();
      },
    );
  }

  // 이미지 촬영 함수 수정
  Future<void> _captureImage() async {
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

  Future<void> _showHikeRecodeModal() async {
    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5), // 모달 밖 배경 어둡게 설정
      builder: (BuildContext context) {
        return HikeRecordModal();
        // return Dialog(
        //   backgroundColor: Colors.white, // 모달의 배경을 하얗게 설정
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(20.0),
        //   ),
        //   child: HikeRecordModal(), // 기존의 HikeRecordModal 위젯
        // );
      },
    );
  }

  void _showMedalModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MedalModal(
          medalImageUrl: 'https://example.com/medal.png', // 실제 메달 이미지 URL로 교체
        );
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
      _saveTimerValue(_secondsNotifier.value); // 타이머 값 저장
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
  }

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
              '사진 촬영을 하시겠습니까?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
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
                      _showHikeRecodeModal(); // 등산 기록 모달 호출
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
                      _captureImage(); // 카메라 촬영 호출
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
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: HikeRecordModal(),
        );
      },
    ).then((_) {
      // 등산 기록 모달이 닫힌 후 등산하기 페이지로 돌아옴
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // 등산하기 페이지로 이동
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => Hike(), // 등산하기 페이지로 돌아가기
          ),
        );
      }
    });
  }


  void _resetTimer() {
    _pauseTimer();
    setState(() {
      _isTracking = false;
      _isPaused = false;
      _secondsNotifier.value = 0;
      _saveTimerValue(0); // 타이머 값 초기화 후 저장
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
              backgroundColor: Colors.white, // AppBar 전체 배경을 흰색으로 설정
              elevation: 0, // 그림자 제거
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectedTrail != null && !_isTracking)
                    Text(
                      '선택된 등산로: ${selectedTrail!['trail_name']} ',
                      style: TextStyle(fontSize: 16),
                    ),
                  if (selectedTrail == null && !_isTracking)
                    Text(
                      '선택된 등산로: 없음 ',
                      style: TextStyle(fontSize: 16),
                    ),
                  if (selectedTrail == null && _isTracking)
                    Row(
                      children: [
                        Text(
                          '경과 시간: ',
                          style: TextStyle(fontSize: 16, color: Colors.black), // 텍스트 색상 설정
                        ),
                        ValueListenableBuilder<int>(
                          valueListenable: _secondsNotifier,
                          builder: (context, seconds, child) {
                            return Text(
                              _formatTime(seconds),
                              style: TextStyle(fontSize: 16, color: Colors.black), // 텍스트 색상 설정
                            );
                          },
                        ),
                      ],
                    ),
                  if (selectedTrail != null && _isTracking)
                    Column(
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
                ],
              ),
              foregroundColor: Colors.black,
              actions: selectedTrail != null && !_isTracking
                  ? [
                IconButton(
                  icon: Icon(Icons.dangerous),
                  onPressed: () {
                    setState(() {
                      selectedTrail = null;
                      selectedMountain = null;
                      selectedSpots = null;
                      _coords = [];
                    });
                  },
                ),
              ]
                  : [],
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
                    maxZoom: 18, // default is 21
                    extent: const NLatLngBounds(
                      southWest: NLatLng(31.43, 122.37),
                      northEast: NLatLng(44.35, 132.0),
                    ),
                  ),
                  onMapReady: (controller) {
                    print("등산하기 맵 로딩 완료");
                    NLocationTrackingMode mode = NLocationTrackingMode.follow;
                    controller.setLocationTrackingMode(mode);

                    // 경로가 있는 경우 NPathOverlay를 추가
                    if (_coords.isNotEmpty && selectedSpots != null) {
                      var route = NPathOverlay(
                        id: '$selectedTrail["trail_idx"]',
                        coords: _coords,
                        color: Colors.blue,
                        width: 5,
                      );
                      controller.addOverlay(route);

                      addSpotsToMap(controller);

                      controller.updateCamera(NCameraUpdate.withParams(
                        target: NLatLng(
                          double.parse(selectedMountain!['mount_latitude']),
                          double.parse(selectedMountain!['mount_longitude']),
                        ),
                        zoom: 11,
                        bearing: 0,
                        tilt: 0,
                      ));
                    }
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
                                  setState(() {
                                    _isPaused = false;
                                    _startTimer();
                                  });
                                } else {
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

class MapWidget extends StatelessWidget {
  final NCameraPosition cameraPosition;
  final NLatLng? currentPosition;

  const MapWidget({required this.cameraPosition, this.currentPosition});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // 지도 로딩 전 배경을 흰색으로 설정
      child: NaverMap(
        options: NaverMapViewOptions(
          initialCameraPosition: cameraPosition,
          consumeSymbolTapEvents: false,
        ),
        onMapReady: (controller) {
          NLocationTrackingMode mode = NLocationTrackingMode.follow;
          controller.setLocationTrackingMode(mode);
          if (currentPosition != null) {
            var marker = NMarker(
              id: "currentLoc",
              position: currentPosition!,
            );
            controller.addOverlay(marker);
          }
        },
      ),
    );
  }
}
