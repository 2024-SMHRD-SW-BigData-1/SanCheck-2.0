import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:sancheck/globals.dart';

class HikingService {
  final Dio dio = Dio();

  // Future<void> flaskTest() async {
  //   try{
  //     final response = await dio.post(
  //             'http://192.168.219.200:5050/drawMap', // Flask 서버의 업로드 URL로 변경
  //           );
  //     print(response);
  //   }catch(e){
  //     print('Error uploading image: $e');
  //   }
  // }


  // 플라스크 서버로 정상석 이미지 전송, 스탬프 제작 함수
  Future<Map<String, dynamic>> sendImageToFlask(File imageFile) async {
    // 요청 데이터 : 사용자가 찍은 이미지, 선택한 산 이름, 선택한 산 idx
    try {
      // 이미지 파일 준비
      FormData formData = FormData.fromMap({
        'userId' : userModel!.userId,
        'image': await MultipartFile.fromFile(imageFile.path, filename: 'uploaded_image.jpg'),
        'mountName' : selectedMountain?['mount_name'],
        'mountIdx' : selectedMountain?['mount_idx'],
      });

      // Flask 서버의 엔드포인트로 요청 보내기
      final res = await dio.post(
        'http://192.168.219.200:5050/sendImageToFlask', // Flask 서버의 업로드 URL로 변경
        data: formData,
      );

      print('Request URL: ${res.realUri}');
      print('Status Code: ${res.statusCode}');
      print('Status Code: $res');

      // JSON 파싱
      Map<String, dynamic> parsedJson = res.data; // res.data는 이미 Map 형태일 수 있음

      // 이미지 경로 꺼내오기
      String rawImagePath = parsedJson['dallE_generated_image_path'];

      // 백슬래시를 슬래시로 변환
      String correctedImagePath = rawImagePath.replaceAll('\\', '/');

      // 서버 URL과 결합하여 최종 이미지 URL 생성
      String imageUrl = 'http://192.168.219.200:8000/medal/$correctedImagePath';

      // 서버 응답 성공 여부 확인
      if (res.statusCode == 200) {
        print('Image upload successful');
        return {'success' : true, 'url' : imageUrl};
      } else {
        print('Image upload failed: ${res.statusCode}');
        return {'success' : false};
      }
    } catch (e) {
      print('Error uploading image: $e');
      return {'success' : false};
    }
  }


  // 등산기록 가져오기 함수
  Future<List<dynamic>> fetchAllHikingResults() async {
    try {
      String url = "http://192.168.219.200:8000/hiking/selectAllHikingResults";
      Response res = await dio.get(
        url,
        queryParameters: {
          'userId' : userModel!.userId
        }
      );

      print('Request URL: ${res.realUri}');
      print('Status Code: ${res.statusCode}');
      print(res.data);

      if (res.statusCode == 200 && res.data != null) {
        return res.data['hikings'];
      } else {
        throw Exception('산 데이터를 불러오는 데 실패했습니다.');
      }
    } catch (e) {
      print("Error loading all mountains: $e");
      throw Exception('서버 요청 실패');
    }
  }
  

}