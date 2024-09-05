import 'package:flutter/material.dart';
import 'login_page.dart'; // login_page.dart 파일을 import

class MyMedal extends StatelessWidget {
  final List<Map<String, String>> medals = [
    {
      'imageUrl': 'https://via.placeholder.com/150',
      'name': '북한산',
      'date': '2024-09-02'
    },
    {
      'imageUrl': 'https://via.placeholder.com/150',
      'name': '설악산',
      'date': '2024-09-10'
    },
    {
      'imageUrl': 'https://via.placeholder.com/150',
      'name': '무등산',
      'date': '2024-09-18'
    },
    // 더 많은 메달을 여기에 추가할 수 있습니다.
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width; // 화면의 너비 가져오기

    return Scaffold(
      appBar: AppBar(
        title: Text('나의 수집 메달',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Color(0xFFF5F5F5),
      ),
      backgroundColor: Color(0xFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // 세로 방향 정렬 설정
          children: [
            SizedBox(height: 10),
            // 네모 상자 추가
            Expanded(
              child: Center(
                child: Container(
                  width: screenWidth * 0.9, // 화면 너비의 90%로 설정
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: EdgeInsets.all(12),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 한 줄에 2개의 항목을 표시
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: medals.length,
                    itemBuilder: (context, index) {
                      final medal = medals[index];
                      return GestureDetector(
                        onTap: () => _showImagePopup(context, medal['imageUrl']!),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                medal['imageUrl']!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              medal['name']!,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              medal['date']!,
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 이미지 확대 팝업 위젯
  void _showImagePopup(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
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
            ],
          ),
        );
      },
    );
  }
}
