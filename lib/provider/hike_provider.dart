import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

Location _location = Location();

class HikeProvider with ChangeNotifier {
  Timer? _timer;
  bool _isTracking = false;
  bool _isPaused = true;
  int _secondNotifier = 0;
  int _currentSteps = 0;
  double _roundedUseCal = 0.0;
  double _roundedDistance = 0.00;
  List<double> _loc_lst_lat = [];
  List<double> _loc_lst_lon = [];
  List<double> _loc_lst = [];
  String _combinedString = "";

  bool get isTracking => _isTracking;
  bool get isPaused => _isPaused;
  int get secondNotifier => _secondNotifier;
  int get currentSteps => _currentSteps;
  double get roundedUseCal => _roundedUseCal;
  double get roundedDistance => _roundedDistance;
  List<double> get loc_lst_lat => _loc_lst_lat;
  List<double> get loc_lst_lon => _loc_lst_lon;
  List<double> get loc_lst => _loc_lst;
  String get combinedString => _combinedString;


  // 현재 위치를 리스트에 추가
  void _get_route() async{
    // 경로 초기화
    print("경로 저장");

    // 현재 위치 받아오기
    var get_location = await _location.getLocation();
    double? now_lat = get_location.latitude;
    double? now_lon = get_location.longitude;

    // 받아온 위치 리스트에 저장
    if (now_lat != null && now_lon != null){
      _loc_lst_lat.add(now_lat);
      _loc_lst_lon.add(now_lon);
      notifyListeners();
    }
    print("lat : ${now_lat}");
    print("lon : ${now_lon}");
    print("loc_lst_lat : $_loc_lst_lat, loc_lst_lon : $_loc_lst_lon");
  }

  // 저장된 경로 리스트를 lineString 형태로 전환
  Future<void> get_route_lst () async {

    for(int i = 0; i < _loc_lst_lat.length; i++){
      _loc_lst.add(_loc_lst_lat[i]);
      _loc_lst.add(_loc_lst_lon[i]);
    }

    // Linestring 형태로 전환
    _combinedString = _loc_lst.asMap().entries.map((entry) {
      if(entry.key % 2 == 0){
        return '${_loc_lst[entry.key]} ${_loc_lst[entry.key + 1]}';
      } else {
        return null;
      }
    }).where((element) => element != null).join(', ');

  }

  // 타이머 시작
  void startTimer() {
    if (_timer == null || !_timer!.isActive) {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        _secondNotifier++;
        if(_secondNotifier % 2 == 0){
          _get_route();
        }
        notifyListeners();
      });
      _isPaused = false;
      notifyListeners();
    }
  }

  // 타이머 일시정지
  void pauseTimer() {
    if (_timer != null && _timer!.isActive) {
      _timer?.cancel();
      _isPaused = true;
      notifyListeners();
    }
  }

  // 타이머 초기화
  void resetTimer() {
    _timer?.cancel();
    _timer = null;
    _secondNotifier = 0;
    _isPaused = true;
    notifyListeners();
  }


  void toggleTracking() {
    _isTracking = !_isTracking;
    notifyListeners();
  }

  void togglePaused() {
    _isPaused = !_isPaused;
    notifyListeners();
  }

  void updateSecondNotifier(int seconds) {
    _secondNotifier = seconds;
    notifyListeners();
  }

  void updateCurrentSteps(int steps){
    _currentSteps = steps;
    notifyListeners();
  }

  void updateRoundedUseCal (double cal) {
    _roundedUseCal = cal;
    notifyListeners();
  }

  void updateRoundedDistance (double dist) {
    _roundedDistance = dist;
    notifyListeners();
  }



  void resetTracking() {
    _isTracking = false; // 상태 초기화
    notifyListeners(); // 상태 변화 알림
  }

  void resetPaused() {
    _isPaused = true; // 상태 초기화
    notifyListeners(); // 상태 변화 알림
  }

  void resetSecond() {
    _secondNotifier = 0; // 상태 초기화
    notifyListeners(); // 상태 변화 알림
  }

  void resetCurrentSteps(){
    _currentSteps = 0; // 상태 초기화
    notifyListeners(); // 상태 변화 알림
  }

  void resetRoundedUseCal() {
    _roundedUseCal = 0.0; // 상태 초기화
    notifyListeners(); // 상태 변화 알림
  }

  void resetRoundedDistance() {
    _roundedDistance = 0.00; // 상태 초기화
    notifyListeners(); // 상태 변화 알림
  }

  void reset_route(){
    _loc_lst_lat = [];
    _loc_lst_lon = [];
    _loc_lst = [];
    _combinedString = "";
    notifyListeners();
  }

}