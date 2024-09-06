import 'package:dio/dio.dart';

class ApiService {
  final Dio dio = Dio();

  // GPT 메시지 전송 메서드
  Future<Map<String, dynamic>> sendMessage(List<Map<String, dynamic>> messages) async {
    try {
      String url = "http://192.168.219.200:8000/gpt/gptTest";
      Response res = await dio.get(
        url,
        queryParameters: {
          'contents': messages,
        },
      );

      print('Request URL: ${res.realUri}');
      print('Status Code: ${res.statusCode}');
      // print('Response Data: ${res.data}');

      // 요청 결과를 반환
      return {
        'success': res.data['success'],
        'data': res.data['data'],
      };
    } catch (e) {
      print('Error occurred: $e');
      // 예외가 발생한 경우 에러 메시지를 반환
      throw Exception('서버 요청 실패: $e');
    }
  }


  // 날씨 api 통신
  Future<Map<String, List<dynamic>>> fetchWeatherData(var gridX, var gridY) async {
    print('날씨 api 통신');
    try {
      String url = "http://192.168.219.200:8000/weather/weatherForecast";
      Response res = await dio.get(url, queryParameters: {
        'nx': gridX,
        'ny': gridY,
      });

      print('Request URL: ${res.realUri}');
      print('Status Code: ${res.statusCode}');
      // print('Response Data: ${res.data}');

      bool isSuccessed = res.data['success'];
      var jsonData = res.data['data'];


      // JSON 데이터를 Dart Map으로 변환
      Map<String, dynamic> data = jsonData;

      // 각 카테고리별로 데이터 추출
      final Map<String, List<dynamic>> categoryData = {
        'POP': data['POP'] ?? [],
        'PTY': data['PTY'] ?? [],
        'PCP': data['PCP'] ?? [],
        'REH': data['REH'] ?? [],
        'SNO': data['SNO'] ?? [],
        'SKY': data['SKY'] ?? [],
        'TMP': data['TMP'] ?? [],
        'TMN': data['TMN'] ?? [],
        'TMX': data['TMX'] ?? [],
        'WSD': data['WSD'] ?? [],
        // 필요한 다른 카테고리 추가
      };

      // 성공 여부에 따른 결과 반환
      if (isSuccessed) {
        return categoryData;
      } else {
        return {'Error': ['날씨 데이터 불러오기 실패']};
      }
    } catch (e) {
      print('Error occurred: $e');
      return {'Error': ['날씨 데이터 불러오기 실패']};
    }
  }
  
  
  
}
