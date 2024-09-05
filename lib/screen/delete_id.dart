import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sancheck/model/user_model.dart';
import 'package:sancheck/screen/login_page.dart';
import 'package:sancheck/service/auth_service.dart';

class DeleteId extends StatelessWidget {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _pwConfirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5), // 배경색 설정
      appBar: AppBar(
        title: Text('회원탈퇴'),
        backgroundColor: Color(0xFFFFF5DA),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Color(0xFFD9D9D9)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '회원탈퇴',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 24),
              _buildInputField('아이디', '아이디를 입력해 주세요.', _idController),
              SizedBox(height: 16),
              _buildInputField('비밀번호', '비밀번호를 입력해 주세요.', _pwController),
              SizedBox(height: 16),
              _buildInputField('비밀번호 확인', '비밀번호를 다시 입력해 주세요.', _pwConfirmController),
              Spacer(), // 버튼을 화면 하단으로 밀어줍니다.
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    handleDeleteId(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE35154), // 버튼 배경색
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    '회원탈퇴',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 회원 탈퇴 기능 처리
  void handleDeleteId(BuildContext context) async {
    String userId = _idController.text;
    String userPw = _pwController.text;
    String confirmPw = _pwConfirmController.text;

    ScaffoldMessenger.of(context).hideCurrentSnackBar(); // 현재 스낵바 숨기기
    if ([userId, userPw, confirmPw].any((element) => element.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('모든 필드를 정확히 작성해주세요.')));
      return;
    }

    if (userPw != confirmPw) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('비밀번호를 일치시켜주세요.')));
      return;
    }

    // AuthService 인스턴스 생성
    final AuthService _authService = AuthService();

    // 로컬 저장소에서 사용자 데이터 읽기
    UserModel? user = await _authService.readUserData();

    if (user != null && userId == user.userId) {
      // 회원 탈퇴 요청
      bool isSuccess = await _authService.deleteUser(userId, userPw);

      if (isSuccess) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
              (Route<dynamic> route) => false, // 모든 이전 화면을 제거
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('회원탈퇴 실패'), backgroundColor: Colors.redAccent));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('입력한 아이디가 현재 로그인된 아이디와 다릅니다.'), backgroundColor: Colors.redAccent));
    }
  }

  Widget _buildInputField(String label, String hintText, TextEditingController controller) {
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
            hintText: hintText,
            hintStyle: TextStyle(color: Color(0xFF9E9E9E)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFFD9D9D9)),
            ),
          ),
        ),
      ],
    );
  }
}
