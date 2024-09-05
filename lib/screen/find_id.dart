import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'phone_formatter.dart'; // 새로운 파일에서 클래스를 가져오는 경우
import 'package:sancheck/service/auth_service.dart';

Dio dio = Dio();

class FindId extends StatefulWidget {
  FindId({super.key});

  @override
  _FindIdState createState() => _FindIdState();
}

class _FindIdState extends State<FindId> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final AuthService _authService = AuthService(); // AuthService 인스턴스 생성

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5), // 밝고 부드러운 배경색
      appBar: AppBar(
        title: Text(
          '아이디 찾기',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // 텍스트 스타일 적용
        ),
        centerTitle: true, // 제목 중앙 정렬
        backgroundColor: Color(0xFFF5F5F5), // LoginSuccess의 상단바 배경색과 동일
        elevation: 0, // 그림자 제거
        iconTheme: IconThemeData(color: Colors.black), // 아이콘 색상 설정
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField('이름', '이름을 입력해 주세요.', _nameController),
                    SizedBox(height: 20),
                    _buildTextField('전화번호', '전화번호를 입력해 주세요.', _phoneController),
                    SizedBox(height: 24),
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // 아이디 찾기 버튼 클릭 시 동작
                            _handleFindId(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF4CAF50), // iOS Health 앱 느낌의 초록색
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            '아이디 찾기',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Color(0xFF1E1E1E),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Color(0xFF9E9E9E)),
            filled: true,
            fillColor: Color(0xFFF5F5F5),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          keyboardType: label == '전화번호' ? TextInputType.phone : TextInputType.text,
          inputFormatters: label == '전화번호'
              ? [
            PhoneFormatter(), // 전화번호 포맷터 적용
            LengthLimitingTextInputFormatter(13), // 하이픈 포함 최대 길이
          ]
              : null,
        ),
      ],
    );
  }

  // 아이디 찾기 성공 다이얼로그
  void _showIdDialog(BuildContext context, List<String> userIds, String userName) {
    if (!mounted) return; // mounted 상태를 확인하여 안전하게 조상을 참조합니다.
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          '아이디 찾기 성공',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: userIds.map((id) => Text("$userName님의 아이디는 '$id' 입니다.")).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('확인', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  // 아이디 찾기
  Future<void> _handleFindId(BuildContext context) async {
    String userName = _nameController.text;
    String userPhone = _phoneController.text;

    if (userName.isEmpty || userPhone.isEmpty) {
      if (mounted) { // mounted 상태를 확인하여 안전하게 조상을 참조합니다.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이름과 전화번호를 입력해 주세요.'), backgroundColor: Colors.redAccent),
        );
      }
      return;
    }

    try {
      final response = await _authService.findId(userName, userPhone);
      final bool isSuccessed = response['success'];
      final List<dynamic> listData = response['user_id'];
      final List<String> userIds = listData.map((item) => item['user_id'] as String).toList();

      if (isSuccessed) {
        _showIdDialog(context, userIds, userName);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar(); // 현재 스낵바 숨기기
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('아이디 찾기 실패'), backgroundColor: Colors.redAccent),
          );
        }
      }
    } catch (e) {
      print('Error occurred: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar(); // 현재 스낵바 숨기기
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('아이디 찾기 실패'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }
}
