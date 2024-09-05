import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';  // 필요 시 Provider 사용
import 'package:sancheck/service/api_service.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  final ApiService _apiService = ApiService(); // ApiService 인스턴스 생성

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  // 메시지 전송 메서드
  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      print(_controller.text);
      setState(() {
        _isLoading = true; // 로딩 시작

        _messages.add({
          'text': _controller.text,
          'isAutoReply': false,
          'color': Color(0xFF87B85C),
          'textColor': Colors.white,
          'role': 'user',
        });
        _controller.clear();
      });

      try {
        // ApiService를 사용해 메시지를 서버로 전송
        final response = await _apiService.sendMessage(_messages);

        if (response['success']) {
          // 요청 성공 시 자동 응답 처리
          _sendAutoReply(response['data']);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('답변을 생성하는 도중 오류가 발생했습니다.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } catch (e) {
        print('Error occurred: $e');
        ScaffoldMessenger.of(context).hideCurrentSnackBar(); // 현재 스낵바 숨기기
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('답변을 생성하는 도중 오류가 발생했습니다.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false; // 로딩 끝
        });
      }
    }
  }

  // 자동 응답 메시지 추가 메서드
  void _sendAutoReply(String resText) {
    setState(() {
      _messages.add({
        'text': resText,
        'isAutoReply': true,
        'color': Colors.white,
        'textColor': Colors.black,
        'role': 'assistant',
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Page'),
        backgroundColor: Colors.grey[200],
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInitialMessage(),
                  SizedBox(height: 16),
                  // 메시지 리스트 출력
                  ..._messages.map((message) => _buildMessage(
                    message['text'],
                    message['isAutoReply'],
                    message['color'],
                    message['textColor'],
                  )),
                  if (_isLoading)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: Offset(0, -2),
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: !_isLoading,
              decoration: InputDecoration(
                hintText: _isLoading ? '답변을 생성중입니다...' : '메시지를 입력하세요...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.send, color: Color(0xFF87B85C)),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(String text, bool isAutoReply, Color bgColor, Color textColor) {
    return Align(
      alignment: isAutoReply ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Color(0xFFD0D0D0)),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
            height: 1.2,
            letterSpacing: 0.25,
          ),
        ),
      ),
    );
  }

  Widget _buildInitialMessage() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.network(
          'https://img.icons8.com/doodle/96/retro-robot.png',
          width: 24,
          height: 24,
        ),
        SizedBox(width: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.symmetric(vertical: 4),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: Color(0xFFEFEFEF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Color(0xFFD0D0D0)),
            ),
            child: Text(
              '무엇이든 물어보세요',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                height: 1.2,
                letterSpacing: 0.25,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
