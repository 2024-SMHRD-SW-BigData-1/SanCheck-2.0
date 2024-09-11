import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sancheck/globals.dart';

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
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Expanded(
              child: Center(
                child: Container(
                  width: screenWidth * 0.9,
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
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.8, // 항목의 비율 조정
                    ),
                    itemCount: allMedals?.length ?? 0,
                    itemBuilder: (context, index) {

                      final medal = allMedals?[index];
                      // 이미지 경로 꺼내오기
                      String rawImagePath = medal['stamp_img'];
                      // 백슬래시를 슬래시로 변환
                      String correctedImagePath = rawImagePath.replaceAll('\\', '/');
                      // 서버 URL과 결합하여 최종 이미지 URL 생성
                      String imageUrl = 'http://192.168.219.200:8000/medal/$correctedImagePath';

                      // 문자열을 DateTime 객체로 변환
                      DateTime dateTime = DateTime.parse(medal['stamp_date']);
                      // 원하는 형식으로 변환
                      String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

                      return GestureDetector(
                        onTap: () => _showImagePopup(context, '${imageUrl}'),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                imageUrl,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 8),
                            Flexible(
                              child: Text(
                                medal['stamp_name']!,
                                style: TextStyle(
                                    fontSize: 14, // 텍스트 크기 조정
                                    fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis, // 텍스트 오버플로우 방지
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              formattedDate,
                              style: TextStyle(fontSize: 12, color: Colors.grey),
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
