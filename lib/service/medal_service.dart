import 'package:dio/dio.dart';
import 'package:sancheck/globals.dart';

class MedalService {
  final Dio dio = Dio();

  // 모든 메달 데이터를 가져오는 메서드
  Future<List<dynamic>> fetchAllMedals() async {
    print('메달 가져오기');
    try {
      String url = "http://192.168.219.200:8000/medal/selectAllMedals";
      Response res = await dio.get(
          url,
        queryParameters: {'userId' : userModel!.userId}
      );

      print('Request URL: ${res.realUri}');
      print('Status Code: ${res.statusCode}');

      if (res.statusCode == 200 && res.data != null) {
        return res.data['medals'];
      } else {
        throw Exception('산 데이터를 불러오는 데 실패했습니다.');
      }
    } catch (e) {
      print("Error loading all mountains: $e");
      throw Exception('서버 요청 실패');
    }
  }


}