import 'package:flutter/services.dart';

String formatPhoneNumber(String input) {
  input = input.replaceAll(RegExp(r'\D'), ''); // 숫자가 아닌 글자는 지우기
  if (input.length >= 4 && input.length < 7) {  // 길이가 4에서 6 사이인 경우 3번째에 하이픈 붙이기
    return '${input.substring(0, 3)}-${input.substring(3)}';
  } else if (input.length >= 7) { // 길이가 7이상인 경우, 3번째, 7번째에 하이픈 붙이기
    return '${input.substring(0, 3)}-${input.substring(3, 7)}-${input.substring(7)}';
  }
  return input;
}

class PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // 입력된 값의 길이에 따라 하이픈을 추가
    if (oldValue.text.length > newValue.text.length) { // 백스페이스가 눌렸는지 확인하는 조건
      return newValue;
    }

    if (newValue.text.length > 1) { // 입력됐을 경우, formatPhoneNumber() 실행하기
      String formatted = formatPhoneNumber(newValue.text);
      return newValue.copyWith(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length)
      );
    }

    return newValue;
  }
}
