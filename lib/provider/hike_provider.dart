import 'package:flutter/material.dart';

class HikeProvider with ChangeNotifier {
  bool _isTracking = false;
  int _secondNotifier = 0;

  bool get isTracking => _isTracking;
  int get secondNotifier => _secondNotifier;

  void toggleTracking() {
    _isTracking = !_isTracking;
    notifyListeners();
  }

  void updateSecondNotifier(int seconds) {
    _secondNotifier = seconds;
    notifyListeners();
  }

  void resetTracking() {
    _isTracking = false; // 상태 초기화
    notifyListeners(); // 상태 변화 알림
  }

  void resetSecond() {
    _secondNotifier = 0; // 상태 초기화
    notifyListeners(); // 상태 변화 알림
  }


}