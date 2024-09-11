import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sancheck/model/user_model.dart';
import 'package:sancheck/screen/find_id.dart';
import 'package:sancheck/screen/find_pw.dart';
import 'package:sancheck/screen/join_page.dart';
import 'package:sancheck/screen/loading_page.dart';
import 'package:sancheck/screen/login_success.dart';
import 'package:sancheck/service/auth_service.dart';
import 'package:sancheck/globals.dart';
import 'package:sancheck/service/mountain_service.dart';

Dio dio = Dio();
final storage = FlutterSecureStorage(); // Singleton pattern for global usage

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService(); // Create instance of AuthService
  bool _isObscuredPassword = true; // Password visibility toggle
  final MountainService _mountainService = MountainService(); // MountainService 인스턴스 생성

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F8F8), // Set background color to a soft white
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    SizedBox(height: 50),
                    Text(
                      '환영합니다!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildTextField(
                      controller: _idController,
                      labelText: '아이디',
                      hintText: '아이디를 입력하세요',
                      icon: Icons.person,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: _passwordController,
                      labelText: '비밀번호',
                      hintText: '비밀번호를 입력하세요',
                      icon: Icons.lock,
                      obscureText: _isObscuredPassword,
                      isPasswordField: true, // Indicate if this is a password field
                    ),
                    SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          handleLogin(context); // Handle login logic
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // Set rounded corners
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          '로그인',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTextButton('아이디 찾기', FindId()),
                        _buildTextButton('비밀번호 찾기', FindPw()),
                        _buildTextButton('회원가입', JoinPage()),
                      ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    bool isPasswordField = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: isPasswordField
              ? IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _isObscuredPassword = !_isObscuredPassword;
              });
            },
          )
              : null,
        ),
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildTextButton(String text, Widget page) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Text(
        text,
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
    );
  }

  void handleLogin(BuildContext context) async {
    String userId = _idController.text;
    String userPw = _passwordController.text;

    if (userId.isEmpty || userPw.isEmpty) {
      return;
    }

    try {
      UserModel? user = await _authService.login(userId, userPw);

      if (user != null) {
        String userDataString = json.encode(user.toJson());
        await storage.write(key: 'user', value: userDataString);
        userModel =  await _authService.readLoginInfo();

        // await _selectAllMountain();
        // await _selectFavMountain(userModel!.userId);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoadingPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('아이디 또는 비밀번호가 일치하지 않습니다.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      print('Error occurred: $e');
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('로그인 도중 오류 발생'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

}
