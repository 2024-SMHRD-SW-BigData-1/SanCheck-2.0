// 마이페이지 > 등산기록 > + 아이콘
import 'package:flutter/material.dart';

class MtMemoModal extends StatefulWidget {
  final Function(String name, DateTime date, String difficulty, String time, String distance) onSubmit;

  MtMemoModal({required this.onSubmit});

  @override
  _MtMemoModalState createState() => _MtMemoModalState();
}

class _MtMemoModalState extends State<MtMemoModal> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();
  String selectedDifficulty = '쉬움';
  String time = '';
  String distance = '';

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
                  '새 코스 추가',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: '산 이름'),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _yearController,
                        decoration: InputDecoration(labelText: '년'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _monthController,
                        decoration: InputDecoration(labelText: '월'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _dayController,
                        decoration: InputDecoration(labelText: '일'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedDifficulty,
                  decoration: InputDecoration(labelText: '난이도'),
                  items: ['쉬움', '보통', '어려움'].map((difficulty) {
                    return DropdownMenuItem(
                      value: difficulty,
                      child: Text(difficulty),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedDifficulty = value!;
                    });
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: '예상 시간'),
                  onChanged: (value) {
                    time = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: '거리 (km)'),
                  onChanged: (value) {
                    distance = value + 'km';
                  },
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_nameController.text.isNotEmpty &&
                          _yearController.text.isNotEmpty &&
                          _monthController.text.isNotEmpty &&
                          _dayController.text.isNotEmpty) {
                        DateTime date = DateTime(
                          int.parse(_yearController.text),
                          int.parse(_monthController.text),
                          int.parse(_dayController.text),
                        );
                        widget.onSubmit(
                          _nameController.text,
                          date,
                          selectedDifficulty,
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