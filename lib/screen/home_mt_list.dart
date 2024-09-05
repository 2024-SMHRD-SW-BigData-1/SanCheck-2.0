import 'package:flutter/material.dart';
import 'home_mt_detail.dart'; // HomeMtDetail 페이지를 import

class HomeMtList extends StatefulWidget {
  final String number;
  final String mountainName;

  HomeMtList({required this.number, required this.mountainName});

  @override
  _HomeMtListState createState() => _HomeMtListState();
}

class _HomeMtListState extends State<HomeMtList> {
  bool _isPressed = false;

  void _handlePress() async {
    setState(() {
      _isPressed = true;
    });

    // 100ms 후에 색상 변경을 원래 상태로 되돌리기
    await Future.delayed(Duration(milliseconds: 100));

    // 페이지 전환
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return HomeMtDetail(mountainName: widget.mountainName);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );

    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _handlePress,
      style: TextButton.styleFrom(
        foregroundColor: Colors.black, padding: EdgeInsets.all(16),
        backgroundColor: _isPressed ? Colors.grey[300] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Color(0xFFD9D9D9)),
        ), // Text color
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  widget.number,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 16),
                Text(
                  widget.mountainName,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Image.network(
                'https://img.icons8.com/ios-filled/100/d0d0d0/forward--v1.png',
                width: 24,
                height: 24,
              ),
              SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '산/코스 자세히 보기',
                  style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.6)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
