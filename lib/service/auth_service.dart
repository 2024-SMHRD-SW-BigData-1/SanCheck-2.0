import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sancheck/model/user_model.dart';

class AuthService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // 이메일 중복 여부
  Future<bool> checkDuplicate(String userId) async {
    try {
      final response = await _dio.post(
        'http://192.168.219.200:8000/user/handleEmailCheck',
        data: {'user_id': userId},
      );
      return response.data['success'];
    } catch (e) {
      print('Error occurred during duplicate check: $e');
      return false;
    }
  }
  
  

  // 회원가입 기능
  Future<bool> submitForm({
    required String userName,
    required String userId,
    required String userPw,
    required String userPhone,
    required String userBirthdate,
    required String userGender,
  }) async {
    try {
      final response = await _dio.post(
        'http://192.168.219.200:8000/user/handleJoin',
        data: {
          'user_name': userName,
          'user_id': userId,
          'user_pw': userPw,
          'user_phone': userPhone,
          'user_birthdate': userBirthdate,
          'user_gender': userGender,
        },
      );
      return response.data['success'];
    } catch (e) {
      print('Error occurred during form submission: $e');
      return false;
    }
  }


  //아이디 찾기 요청
  Future<Map<String, dynamic>> findId(String userName, String userPhone) async {
    try {
      final response = await _dio.post(
        'http://192.168.219.200:8000/user/handleFindId',
        data: {
          'user_name': userName,
          'user_phone': userPhone,
        },
      );
      return response.data;
    } catch (e) {
      print('Error occurred during findId request: $e');
      throw e; // 오류를 상위 호출자로 전달
    }
  }

// 비밀번호 찾기 요청
  Future<Map<String, dynamic>> findPassword(String userId, String userName, String userPhone) async {
    try {
      final response = await _dio.post(
        'http://192.168.219.200:8000/user/handleFindPw',
        data: {
          'user_id': userId,
          'user_name': userName,
          'user_phone': userPhone,
        },
      );
      return response.data;
    } catch (e) {
      print('Error occurred during findPassword request: $e');
      throw e; // 오류를 상위 호출자로 전달
    }
  }


  // 비밀번호 변경 요청(비번찾기 후)
  Future<bool> changePassword(String userId, String newPassword) async {
    try {
      final String url = "http://192.168.219.200:8000/user/handleFindPwNext";
      final Response res = await _dio.post(url, data: {
        'user_pw': newPassword,
        'user_id': userId,
      });

      return res.data['success'];
    } catch (e) {
      print('Error occurred during password change: $e');
      return false;
    }
  }




  // 로그인 요청
  Future<UserModel?> login(String userId, String password) async {
    try {
      final String url = "http://192.168.219.200:8000/user/handleLogin";
      final Response res = await _dio.post(url, data: {
        'user_id': userId,
        'user_pw': password,
      });

      if (res.data['success']) {
        var userData = res.data['user_data'];
        String userDataString = json.encode(userData);
        UserModel user = userModelFromJson(userDataString);
        await _storage.write(key: 'user', value: userDataString);
        return user;
      } else {
        return null;
      }
    } catch (e) {
      print('Error occurred during login: $e');
      return null;
    }
  }

  // 이미 로그인 되어있는지 확인
  Future<UserModel?> readLoginInfo() async {
    String? value = await _storage.read(key: 'user');
    if (value != null) {
      return userModelFromJson(value);
    }
    return null;
  }



  // 회원 탈퇴 요청
  Future<bool> deleteUser(String userId, String userPw) async {
    try {
      String url = "http://192.168.219.200:8000/user/handleDeleteId";
      Response res = await _dio.post(url, data: {
        'user_id': userId,
        'user_pw': userPw,
      });

      if (res.data['success']) {
        // 로컬 저장소에서 사용자 데이터 삭제
        await _storage.delete(key: 'user');
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error occurred: $e');
      return false;
    }
  }

  // 로컬 저장소에서 사용자 데이터 읽기
  Future<UserModel?> readUserData() async {
    String? userDataString = await _storage.read(key: 'user');
    if (userDataString != null) {
      Map<String, dynamic> userDataMap = json.decode(userDataString);
      return UserModel.fromJson(userDataMap);
    }
    return null;
  }

// 로그아웃 기능
  Future<void> logout() async {
    await _storage.delete(key: 'user');
  }



}
