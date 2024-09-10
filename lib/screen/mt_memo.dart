import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'mt_memo_modal.dart';

class MtMemo extends StatefulWidget {
  final String mountainName;

  MtMemo({required this.mountainName});

  @override
  _MtMemoState createState() => _MtMemoState();
}

class _MtMemoState extends State<MtMemo> {
  List<bool> _isExpandedList = [];
  List<Map<String, String?>> courseDetails = [
    {'name': '무등산', 'date': '2023-08-29'},
    {'name': '설악산', 'date': '2023-09-05'},
    {'name': '북한산', 'date': '2023-09-12'},
  ];
  List<Map<String, dynamic>> subCourses = [
    {
      'description': '세부 코스 설명이 여기에 나옵니다.',
      'imageUrl': 'https://via.placeholder.com/90',
      'difficulty': '쉬움\n',
      'time': '1시간\n',
      'distance': '2.5km',
    },
    {
      'description': '세부 코스 설명이 여기에 나옵니다.',
      'imageUrl': '',
      'difficulty': '보통\n',
      'time': '2시간\n',
      'distance': '3.0km',
    }
  ];

  @override
  void initState() {
    super.initState();
    _isExpandedList = List.generate(courseDetails.length, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('나의 등산 기록',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Color(0xFFF5F5F5),
      ),
      backgroundColor: Color(0xFFF5F5F5),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: ListView.separated(
          itemCount: courseDetails.length,
          separatorBuilder: (context, index) => SizedBox(height: 16),
          itemBuilder: (context, index) {
            String name = courseDetails[index]['name'] ?? '알 수 없는 산';
            String date = courseDetails[index]['date'] ?? '날짜 없음';
            return GestureDetector(
              onLongPress: () => _showDeleteConfirmation(context, index),
              child: Column(
                children: [
                  _buildCourseButton(
                    '📍 $name',
                    subtitle: date,
                    trailingIcon: _isExpandedList[index]
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    onPressed: () {
                      setState(() {
                        _isExpandedList[index] = !_isExpandedList[index];
                      });
                    },
                  ),
                  AnimatedSize(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _isExpandedList[index]
                        ? _buildSubCourseItem(
                        subCourses[index % subCourses.length], screenWidth)
                        : SizedBox(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: ClipOval(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            splashColor: Colors.grey.withOpacity(0.2),
            onTap: () => _showAddCourseModal(context),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Image.network(
                  'https://img.icons8.com/color/96/add--v1.png',
                  width: 32,
                  height: 32,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 코스 버튼 생성 위젯
  Widget _buildCourseButton(String title,
      {required String subtitle,
        IconData? trailingIcon,
        VoidCallback? onPressed}) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.92,
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.white),
          padding: MaterialStateProperty.all(
            EdgeInsets.symmetric(
              vertical: screenWidth * 0.04,
              horizontal: screenWidth * 0.06,
            ),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          overlayColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)) {
                return Color(0x3F000000);
              }
              return null;
            },
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (trailingIcon != null)
              Icon(
                trailingIcon,
                color: Colors.black,
              ),
          ],
        ),
      ),
    );
  }

  // 세부 코스 항목 생성 위젯
  Widget _buildSubCourseItem(Map<String, dynamic> subCourse, double screenWidth) {
    return Container(
      width: screenWidth * 0.92,
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subCourse['imageUrl'] != null &&
              subCourse['imageUrl'].isNotEmpty &&
              Uri.tryParse(subCourse['imageUrl']) != null)
            Container(
              margin: EdgeInsets.only(bottom: 8),
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(subCourse['imageUrl']),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {
                    print('Error loading image: $exception');
                  },
                ),
              ),
            )
          else
            SizedBox(
                height: 50,
                child: Center(child: Text('저장된 등산 기록 이미지가 없습니다.'))),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '🚩 코스명: ',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                TextSpan(
                  text: subCourse['difficulty'],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '⏱ 시간: ',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                TextSpan(
                  text: subCourse['time'],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '🏃‍♂️ 거리: ',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                TextSpan(
                  text: subCourse['distance'],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 삭제 확인 팝업 호출
  void _showDeleteConfirmation(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '삭제하시겠습니까?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '선택한 등산 기록을 삭제하시겠습니까?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      ),
                      child: Text(
                        '취소',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          courseDetails.removeAt(index);
                          _isExpandedList.removeAt(index);
                        });
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      ),
                      child: Text(
                        '삭제',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 이미지 팝업 위젯 호출
  void _showImagePopup(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 16,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  ),
                  child: Text(
                    '닫기',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 코스 추가 모달 호출
  void _showAddCourseModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: MtMemoModal(
            onSubmit: (name, date, difficulty, time, distance) {
              setState(() {
                String formattedDate = DateFormat('yyyy-MM-dd').format(date);
                courseDetails.add({
                  'name': name,
                  'date': formattedDate,
                });
                _isExpandedList.add(false);
              });
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }
}
