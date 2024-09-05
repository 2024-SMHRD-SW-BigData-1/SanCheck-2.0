import 'package:dio/dio.dart';

class TrailService{
  final Dio dio = Dio();

  // 등산로 가져오기
  Future<List<dynamic>> selectTrail(String mountName) async {
    try {
      String url = "http://192.168.219.200:8000/trail/selectTrail";
      Response res = await dio.get(url, queryParameters: {
        'mountName': mountName,
      });

      print('Request URL: ${res.realUri}');
      print('Status Code: ${res.statusCode}');
      print('Response Data: ${res.data}');

      if (res.data['success']) {
        return res.data['trails']; // 성공 시 데이터 리스트 반환
      } else {
        throw Exception('검색 실패');
      }
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('서버 요청 실패');
    }
  }
}