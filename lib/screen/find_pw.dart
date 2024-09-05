import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sancheck/screen/find_pw_next.dart';
import 'package:sancheck/service/auth_service.dart';
import 'phone_formatter.dart'; // 전화번호 포맷터 적용

class FindPw extends StatelessWidget {
  FindPw({super.key});

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final AuthService _authService = AuthService(); // AuthService 인스턴스 생성

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5), // 밝고 부드러운 배경색
      appBar: AppBar(
        title: Text(
          '비밀번호 찾기',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // 텍스트 스타일 적용
        ),
        centerTitle: true, // 제목 중앙 정렬
        backgroundColor: Color(0xFFF5F5F5), // 상단바 배경색
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
                    _buildTextField('이메일', '이메일을 입력해 주세요.', _idController),
                    SizedBox(height: 20),
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
                            // 비밀번호 찾기 버튼 클릭 시 동작
                            _handleFindPw(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF4CAF50), // 초록색 버튼
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            '비밀번호 찾기',
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

  Future<void> _handleFindPw(BuildContext context) async {
    String userId = _idController.text;
    String userName = _nameController.text;
    String userPhone = _phoneController.text;

    if (userId.isEmpty || userName.isEmpty || userPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이메일, 이름, 전화번호를 모두 입력해 주세요.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    try {
      final response = await _authService.findPassword(userId, userName, userPhone);
      print(response);
      final bool isSuccessed = response['success'];

      if (isSuccessed) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FindPwNext(userId: userId)),
        );
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar(); // 현재 스낵바 숨기기
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('비밀번호 찾기 실패'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      print('Error occurred: $e');
      ScaffoldMessenger.of(context).hideCurrentSnackBar(); // 현재 스낵바 숨기기
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('비밀번호 찾기 실패'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}
