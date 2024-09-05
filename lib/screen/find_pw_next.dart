import 'package:flutter/material.dart';
import 'package:sancheck/service/auth_service.dart';
import 'package:sancheck/screen/login_page.dart';

class FindPwNext extends StatefulWidget {
  const FindPwNext({super.key, required this.userId});
  final String userId;

  @override
  _FindPwNextState createState() => _FindPwNextState();
}

class _FindPwNextState extends State<FindPwNext> {
  bool _isObscuredPassword = true;
  bool _isObscuredConfirmPassword = true;

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // 비밀번호 입력 필드 위젯
  Widget _buildPasswordField(String label, String hint, bool isPassword, TextEditingController controller) {
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
          obscureText: isPassword ? _isObscuredPassword : _isObscuredConfirmPassword,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixIcon: IconButton(
              icon: Icon(
                isPassword
                    ? (_isObscuredPassword ? Icons.visibility_off : Icons.visibility)
                    : (_isObscuredConfirmPassword ? Icons.visibility_off : Icons.visibility),
                color: Color(0xFF1E1E1E),
              ),
              onPressed: () {
                setState(() {
                  if (isPassword) {
                    _isObscuredPassword = !_isObscuredPassword;
                  } else {
                    _isObscuredConfirmPassword = !_isObscuredConfirmPassword;
                  }
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  void handleFindPwNext(context, String userId) async {
    String userPw = _passwordController.text;
    String userConfirmPw = _confirmPasswordController.text;

    if (userPw.isEmpty || userConfirmPw.isEmpty) {
      return;
    }

    if (userPw != userConfirmPw) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('비밀번호를 일치시켜주세요.')));
      return;
    }

    final authService = AuthService();
    final bool isSuccessed = await authService.changePassword(userId, userPw);

    if (isSuccessed) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('비밀번호 변경 성공', style: TextStyle(color: Colors.black,)), backgroundColor: Colors.lightBlueAccent,));
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()), // 이동할 페이지
            (Route<dynamic> route) => false, // 모든 이전 화면을 제거
      );
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar(); // 현재 스낵바 숨기기
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('비밀번호 변경 실패'), backgroundColor: Colors.redAccent,));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: Text('비밀번호 찾기'),
        backgroundColor: Color(0xFFFFF5DA),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Color(0xFFD9D9D9)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPasswordField('새 비밀번호', '비밀번호를 입력해 주세요.', true, _passwordController),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  _buildPasswordField('비밀번호 확인', '비밀번호를 다시 입력해 주세요', false, _confirmPasswordController),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // 비밀번호 변경하기 버튼 클릭 시 동작
                          handleFindPwNext(context, widget.userId);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF6DA462),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          '비밀번호 변경하기',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
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
    );
  }
}
