import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sancheck/screen/phone_formatter.dart';
import 'package:intl/intl.dart';
import 'package:sancheck/service/auth_service.dart';

Dio dio = Dio();

class JoinPage extends StatefulWidget {
  @override
  _JoinPageState createState() => _JoinPageState();
}

class _JoinPageState extends State<JoinPage> {
  final AuthService _authService = AuthService(); // AuthService instance

  bool _isObscuredPassword = true;
  bool _isObscuredConfirmPassword = true;

  // Input field controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  bool _isAvailableId = false;
  bool _isAvailablePassword = false;
  bool _isNotDuplicatedId = false;
  bool _isFormValid = false;

  String _selectedGender = '남성'; // Initial gender selection

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validatePassword);
    _phoneController.addListener(_validateForm);
    _birthdateController.addListener(_validateForm);
    _idController.addListener(_validateEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _idController.text.isNotEmpty &&
          _nameController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty &&
          _phoneController.text.isNotEmpty &&
          _birthdateController.text.isNotEmpty &&
          _isAvailablePassword &&
          _isAvailableId &&
          _isNotDuplicatedId;
    });
  }

  void _validateEmail() {
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(pattern);
    setState(() {
      _isAvailableId = regex.hasMatch(_idController.text);
      _validateForm();
    });
  }

  void _validatePassword() {
    setState(() {
      _isAvailablePassword = _passwordController.text == _confirmPasswordController.text;
      _validateForm();
    });
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _birthdateController.text = _dateFormat.format(picked);
    }
  }

  Future<void> _checkDuplicate() async {
    final userId = _idController.text;
    if (userId.trim().isEmpty) {
      return;
    }
    if (!_isAvailableId) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일 형식대로 작성해주세요. \n유효한 이메일 형식 : example@example.com')),
      );
      return;
    }
    final isAvailable = await _authService.checkDuplicate(userId);
    setState(() {
      _isNotDuplicatedId = isAvailable;
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isAvailable ? '사용 가능한 아이디입니다.' : '중복된 아이디입니다. 다른 아이디로 설정해주세요.'),
      ),
    );
  }

  Future<void> _submitForm() async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (!_isAvailablePassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호를 일치시켜주세요.')),
      );
      return;
    }
    if (!_isNotDuplicatedId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아이디 중복체크 또는 다른 아이디를 작성해주세요.')),
      );
      return;
    }
    if (!_isAvailableId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일 형식대로 작성해주세요. \n 유효한 이메일 형식 : example@example.com')),
      );
      return;
    }
    if (_isFormValid) {
      try {
        final isSubmitted = await _authService.submitForm(
          userName: _nameController.text,
          userId: _idController.text,
          userPw: _passwordController.text,
          userPhone: _phoneController.text,
          userBirthdate: _birthdateController.text,
          userGender: _selectedGender,
        );
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isSubmitted ? '회원가입 완료' : '회원가입 실패'),
            backgroundColor: isSubmitted ? Colors.lightBlueAccent : Colors.redAccent,
          ),
        );
        if (isSubmitted) {
          Navigator.pop(context);
        }
      } catch (e) {
        print('Error occurred: $e');
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('회원가입 실패'), backgroundColor: Colors.redAccent),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('모든 필드를 올바르게 입력해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          '산책 회원가입',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFF5F5F5),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 5))],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('이름', '이름을 입력해 주세요.', controller: _nameController),
              SizedBox(height: 16),
              _buildTextField('이메일', '이메일을 입력해 주세요.', controller: _idController, isEmail: true),
              SizedBox(height: 16),
              _buildCheckDuplicateButton(),
              SizedBox(height: 16),
              _buildPasswordField('비밀번호', '비밀번호를 입력해 주세요.', true, controller: _passwordController),
              SizedBox(height: 16),
              _buildPasswordField('비밀번호 확인', '비밀번호를 다시 입력해주세요', false, controller: _confirmPasswordController),
              SizedBox(height: 16),
              _buildTextField('전화번호', '전화번호를 입력해 주세요.', controller: _phoneController, isPhoneNumber: true),
              SizedBox(height: 16),
              _buildBirthdateField('생년월일을 입력하세요', _birthdateController),
              SizedBox(height: 16),
              _buildGenderField(),
              SizedBox(height: 20),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBirthdateField(String hint, TextEditingController? controller) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: () => _selectDate(context),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '성별',
          style: TextStyle(color: Color(0xFF1E1E1E), fontSize: 16, fontWeight: FontWeight.w400),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text('남성'),
                value: '남성',
                groupValue: _selectedGender,
                onChanged: (String? value) {
                  setState(() {
                    _selectedGender = value!;
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('여성'),
                value: '여성',
                groupValue: _selectedGender,
                onChanged: (String? value) {
                  setState(() {
                    _selectedGender = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordField(String label, String hint, bool isPassword, {TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Color(0xFF1E1E1E), fontSize: 16, fontWeight: FontWeight.w400),
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
              borderRadius: BorderRadius.circular(12),
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

  Widget _buildTextField(String label, String hint, {TextEditingController? controller, bool isPhoneNumber = false, bool isEmail = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Color(0xFF1E1E1E), fontSize: 16, fontWeight: FontWeight.w400),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          keyboardType: isPhoneNumber
              ? TextInputType.phone
              : isEmail
              ? TextInputType.emailAddress
              : TextInputType.text,
          inputFormatters: isPhoneNumber
              ? [
            PhoneFormatter(),
            LengthLimitingTextInputFormatter(13),
          ]
              : null,
        ),
      ],
    );
  }

  Widget _buildCheckDuplicateButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Align(
        alignment: Alignment.center,
        child: ElevatedButton(
          onPressed: _checkDuplicate,
          child: Text('아이디 중복 확인'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: 300,
          child: ElevatedButton(
            onPressed: _submitForm,
            child: Text('제출'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
