import 'dart:io';
import 'package:dio/dio.dart';

class FlaskService {
  final Dio dio = Dio();

  Future<void> flaskTest() async {
    try{
      final response = await dio.get(
              'http://192.168.219.200:5050/', // Flask 서버의 업로드 URL로 변경
            );
    }catch(e){
      print('Error uploading image: $e');
    }
  }

  // 플라스크 서버로 이미지 전송 함수
  // Future<bool> _sendImageToFlask(File imageFile) async {
  //   try {
  //     // 이미지 파일 준비
  //     FormData formData = FormData.fromMap({
  //       'image': await MultipartFile.fromFile(imageFile.path, filename: 'uploaded_image.jpg'),
  //     });
  //
  //     // Flask 서버의 엔드포인트로 요청 보내기
  //     final response = await dio.post(
  //       'http://192.168.219.200:5050/', // Flask 서버의 업로드 URL로 변경
  //       data: formData,
  //     );
  //
  //     // 서버 응답 성공 여부 확인
  //     if (response.statusCode == 200) {
  //       print('Image upload successful');
  //       return true;
  //     } else {
  //       print('Image upload failed: ${response.statusCode}');
  //       return false;
  //     }
  //   } catch (e) {
  //     print('Error uploading image: $e');
  //     return false;
  //   }
  // }

}