import 'package:dio/dio.dart';

class MountainService {
  final Dio dio = Dio();

  // 산 검색 API 요청 메서드
  Future<List<dynamic>> searchMountain(String queryText) async {
    try {
      String url = "http://192.168.219.200:8000/mountain/searchMountain";
      Response res = await dio.get(url, queryParameters: {
        'queryText': queryText,
      });

      print('Request URL: ${res.realUri}');
      print('Status Code: ${res.statusCode}');
      print('Response Data: ${res.data}');

      if (res.data['success']) {
        return res.data['mountain']; // 성공 시 데이터 리스트 반환
      } else {
        throw Exception('검색 실패');
      }
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('서버 요청 실패');
    }
  }

  // 모든 산 데이터를 가져오는 메서드
  Future<List<dynamic>> fetchAllMountains() async {
    try {
      String url = "http://192.168.219.200:8000/mountain/selectAllMountain";
      Response res = await dio.get(url);

      if (res.statusCode == 200 && res.data != null) {
        return res.data['mountains'];
      } else {
        throw Exception('산 데이터를 불러오는 데 실패했습니다.');
      }
    } catch (e) {
      print("Error loading all mountains: $e");
      throw Exception('서버 요청 실패');
    }
  }

  // 관심있는 산 검색
  Future<void> searchFavMountain() async {
    try {
      String url = "http://192.168.219.200:8000/mountain/searchFavMountain";
      Response res = await dio.get(url, queryParameters: {

      });

      print('Request URL: ${res.realUri}');
      print('Status Code: ${res.statusCode}');
      print('Response Data: ${res.data}');

      if (res.data['success']) {
        return res.data['mountain']; // 성공 시 데이터 리스트 반환
      } else {
        throw Exception('검색 실패');
      }
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('서버 요청 실패');
    }
  }

  // 관심있는 산 추가
  Future<void> addFavMountain() async {
    try {
      String url = "http://192.168.219.200:8000/mountain/addFavMountain";
      Response res = await dio.get(url, queryParameters: {

      });

      print('Request URL: ${res.realUri}');
      print('Status Code: ${res.statusCode}');
      print('Response Data: ${res.data}');

      if (res.data['success']) {
        return res.data['mountain']; // 성공 시 데이터 리스트 반환
      } else {
        throw Exception('검색 실패');
      }
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('서버 요청 실패');
    }
  }

  // 관심있는 산 제거
  Future<void> removeFavMountain() async {
    try {
      String url = "http://192.168.219.200:8000/mountain/removeFavMountain";
      Response res = await dio.get(url, queryParameters: {

      });

      print('Request URL: ${res.realUri}');
      print('Status Code: ${res.statusCode}');
      print('Response Data: ${res.data}');

      if (res.data['success']) {
        return res.data['mountain']; // 성공 시 데이터 리스트 반환
      } else {
        throw Exception('검색 실패');
      }
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('서버 요청 실패');
    }
  }



}
