import 'package:dio/dio.dart';

class TrailService{
  final Dio dio = Dio();

  // 등산로 가져오기
  Future<List<dynamic>> selectTrailByMountName(String mountName) async {
    try {
      String url = "http://192.168.219.200:8000/trail/selectTrailByMountName";
      Response res = await dio.get(url, queryParameters: {
        'mountName': mountName,
      });

      print('Request URL: ${res.realUri}');
      print('Status Code: ${res.statusCode}');
      //print('Response Data: ${res.data}');

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

  // 레벨 별 등산로 가져오기
  Future<List<dynamic>> selectTrailByTrailLevel(String trailLevel) async{
    try {
      String url = "http://192.168.219.200:8000/trail/selectTrailByTrailLevel";
      Response res = await dio.get(url, queryParameters: {
        'trailLevel': trailLevel,
      });

      print('Request URL: ${res.realUri}');
      print('Status Code: ${res.statusCode}');
      //print('Response Data: ${res.data}');

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

  // 레벨 별 등산로 가져오기
  Future<Map<String,dynamic>> selectTrailByTrailIdx(int trailIdx) async{
    try {
      String url = "http://192.168.219.200:8000/trail/selectTrailByTrailIdx";
      Response res = await dio.get(url, queryParameters: {
        'trailIdx': trailIdx,
      });

      print('Request URL: ${res.realUri}');
      print('Status Code: ${res.statusCode}');
      //print('Response Data: ${res.data}');

      if (res.data['success']) {
        return res.data['trail']; // 성공 시 데이터 리스트 반환
      } else {
        throw Exception('검색 실패');
      }
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('서버 요청 실패');
    }
  }

  // 스팟 가져오기
  Future<List<dynamic>> selectSpotsByTrailId(int trailIdx) async{
    try {
      String url = "http://192.168.219.200:8000/trail/selectSpotsByTrailId";
      Response res = await dio.get(url, queryParameters: {
        'trailIdx': trailIdx,
      });

      //print('Request URL: ${res.realUri}');
      //print('Status Code: ${res.statusCode}');
     // print('Response Data: ${res.data}');

      return res.data['spots']; // 성공 시 데이터 리스트 반환

      // if (res.data['success']) {
      //   return res.data['spots']; // 성공 시 데이터 리스트 반환
      // } else {
      //   throw Exception('검색 실패');
      // }
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('서버 요청 실패');
    }

  }

  // 모든 등산로 가져오기
  Future<List<dynamic>> fetchAllTrails() async {
    try {
      String url = "http://192.168.219.200:8000/trail/selectAllTrails";
      Response res = await dio.get(url);

      print('Request URL: ${res.realUri}');
      print('Status Code: ${res.statusCode}');

      if (res.statusCode == 200 && res.data != null) {
        return res.data['trails'];
      } else {
        throw Exception('등산로 데이터를 불러오는 데 실패했습니다.');
      }
    } catch (e) {
      print("Error loading all mountains: $e");
      throw Exception('서버 요청 실패');
    }
  }
}