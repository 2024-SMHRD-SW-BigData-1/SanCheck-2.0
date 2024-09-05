import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MtMemoModal extends StatefulWidget {
  final Function(String name, DateTime date, String difficulty, String time,
      String distance) onSubmit;

  MtMemoModal({required this.onSubmit});

  @override
  _MtMemoModalState createState() => _MtMemoModalState();
}

class _MtMemoModalState extends State<MtMemoModal> {
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _difficultyController = TextEditingController();
  String time = '';
  String distance = '';
  String? _selectedMountain; // 선택한 산 이름 변수
  final List<String> _mountains = [
    '북한산',
    '무등산',
    '내장산',
    '지리산',
    '한라산',
    '태백산',
    '소백산',
    '치악산',
    '설악산',
    '금강산',
    '오대산',
    '팔공산'
  ]; // 임시 산 목록

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white, // 모달창의 배경색을 흰색으로 설정
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '새 기록 추가',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                // 년, 월, 일 입력 필드
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _yearController,
                        decoration: InputDecoration(
                          labelText: '년',
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.green), // 초록색 밑줄
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly, // 숫자만 입력 가능
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _monthController,
                        decoration: InputDecoration(
                          labelText: '월',
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.green), // 초록색 밑줄
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly, // 숫자만 입력 가능
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _dayController,
                        decoration: InputDecoration(
                          labelText: '일',
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.green), // 초록색 밑줄
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly, // 숫자만 입력 가능
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                // 산 이름 선택 드롭다운
                DropdownButtonFormField<String>(
                  value: _selectedMountain,
                  decoration: InputDecoration(
                    labelText: '산 이름 선택',
                    labelStyle: TextStyle(color: Colors.black),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green), // 초록색 밑줄
                    ),
                  ),
                  dropdownColor: Colors.white,
                  items: _mountains.map((String mountain) {
                    return DropdownMenuItem<String>(
                      value: mountain,
                      child: Text(
                        mountain,
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMountain = value;
                    });
                  },
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(height: 10),
                // 코스명 텍스트 입력 필드
                TextField(
                  controller: _difficultyController,
                  decoration: InputDecoration(
                    labelText: '코스명',
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green), // 초록색 밑줄
                    ),
                  ),
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: '등산 시간',
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green), // 초록색 밑줄
                    ),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,1}$')), // 소수점 한 자리까지만 입력 가능
                  ],
                  onChanged: (value) {
                    time = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: '거리 (km)',
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green), // 초록색 밑줄
                    ),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,1}$')), // 소수점 한 자리까지만 입력 가능
                  ],
                  onChanged: (value) {
                    distance = value + 'km';
                  },
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_selectedMountain != null &&
                          _yearController.text.isNotEmpty &&
                          _monthController.text.isNotEmpty &&
                          _dayController.text.isNotEmpty) {
                        DateTime date = DateTime(
                          int.parse(_yearController.text),
                          int.parse(_monthController.text),
                          int.parse(_dayController.text),
                        );
                        widget.onSubmit(
                          _selectedMountain!,
                          date,
                          _difficultyController.text,
                          time,
                          distance,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '추가',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: 0,
              top: 0,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context); // 모달 창 닫기
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
