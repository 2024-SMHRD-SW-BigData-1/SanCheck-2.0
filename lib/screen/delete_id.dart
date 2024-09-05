import 'package:flutter/material.dart';
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
      backgroundColor: Color(0xFFF2F2F7), // iOS 스타일 배경색
      appBar: AppBar(
        backgroundColor: Color(0xFFF2F2F7),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          '회원탈퇴',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputSection(),
            SizedBox(height: 20),
            _buildDeleteButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
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
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputField('아이디', '아이디를 입력해 주세요.', _idController),
          Divider(height: 30, color: Colors.grey.shade300),
          _buildInputField('비밀번호', '비밀번호를 입력해 주세요.', _pwController, isPassword: true),
          Divider(height: 30, color: Colors.grey.shade300),
          _buildInputField('비밀번호 확인', '비밀번호를 다시 입력해 주세요.', _pwConfirmController, isPassword: true),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => handleDeleteId(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: Text(
        '회원탈퇴',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
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

  Widget _buildInputField(String label, String hintText, TextEditingController controller, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
