// providers/mountain_provider.dart
import 'package:flutter/material.dart';
import 'package:sancheck/service/mountain_service.dart';
import 'package:sancheck/globals.dart'; // 전역 변수가 있는 파일 import

class MountainProvider extends ChangeNotifier {
  final MountainService _mountainService = MountainService();

  List<dynamic>? _mountain;
  String? _searchText;

  List<dynamic>? get mountain => _mountain;
  String? get searchText => _searchText;

  // favMountains의 getter
  List<dynamic>? get providerFavMountains => favMountains;

  // favMountains 업데이트 시 상태 변화 알림
  void updateFavMountain() {
    notifyListeners(); // 상태 변화 알림
  }

  // 산 검색 메서드
  Future<void> searchMountain(String queryText) async {
    try {
      _searchText = queryText;
      _mountain = await _mountainService.searchMountain(queryText);
      print('응답 값 넘어옴 $_mountain');
      notifyListeners(); // 상태 변화 알림
    } catch (e) {
      print('Error in Provider: $e');
    }
  }


  // 상태 초기화 메서드
  void resetMountain() {
    _mountain = null; // 상태 초기화
    notifyListeners(); // 상태 변화 알림
  }
}
