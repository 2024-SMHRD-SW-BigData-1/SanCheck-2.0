import 'dart:io';
import 'package:dio/dio.dart';
import 'package:sancheck/globals.dart';

class FlaskService {
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


  // 플라스크 서버로 정상석 이미지 전송 함수
  Future<bool> sendImageToFlask(File imageFile) async {
    // 요청 데이터 : 사용자가 찍은 이미지, 선택한 산 이름, 선택한 산 idx
    try {
      // 이미지 파일 준비
      FormData formData = FormData.fromMap({
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

      // 서버 응답 성공 여부 확인
      if (res.statusCode == 200) {
        print('Image upload successful');
        return true;
      } else {
        print('Image upload failed: ${res.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return false;
    }
  }


  

}