import 'package:flutter/material.dart';
import 'package:sancheck/service/api_service.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
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
        final response = await _apiService.sendMessage(_messages);

        if (response['success']) {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('답변을 생성하는 도중 오류가 발생했습니다.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Scaffold(
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
                reverse: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInitialMessage(),
                    SizedBox(height: 16),
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

  Widget _buildMessage(
      String text, bool isAutoReply, Color bgColor, Color textColor) {
    return Align(
      alignment: isAutoReply ? Alignment.centerLeft : Alignment.centerRight,
      child: Row(
        mainAxisAlignment:
        isAutoReply ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isAutoReply)
            CircleAvatar(
              backgroundColor: Colors.grey[200],
              radius: 16,
              backgroundImage: NetworkImage(
                  'https://img.icons8.com/doodle/96/retro-robot.png'),
            ),
          SizedBox(width: isAutoReply ? 8 : 0),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              margin: EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft:
                  isAutoReply ? Radius.circular(0) : Radius.circular(12),
                  bottomRight:
                  isAutoReply ? Radius.circular(12) : Radius.circular(0),
                ),
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
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialMessage() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[200],
            radius: 16,
            backgroundImage:
            NetworkImage('https://img.icons8.com/doodle/96/retro-robot.png'),
          ),
          SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              margin: EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xFFEFEFEF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(12),
                ),
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
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
