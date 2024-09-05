import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

Dio dio = Dio();

class ChatgptApiTest extends StatefulWidget {
  const ChatgptApiTest({super.key});

  @override
  State<ChatgptApiTest> createState() => _ChatgptApiTestState();
}

class _ChatgptApiTestState extends State<ChatgptApiTest> {

  final _gptController = TextEditingController();
  String _resText = '응답 없음';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatgpt Api 연결'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                TextField(
                  controller: _gptController,
                ),
                ElevatedButton(onPressed: _submitText , child: Text('전송')),
                _buildResponseSection(_resText)
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildResponseSection (String resText) {
    return Text(resText);
  }


  void _submitText() async{

    String gptText = _gptController.text;
    if(gptText.isEmpty){
      return;
    }

    print('ddddd $gptText');
    try{

      // 서버 통신
      String url = "http://172.28.112.1:8000/gpt/gptTest";
      Response res = await dio.get(url,
          queryParameters: {
            'message' : gptText
          }
      );
      // 요청이 완료된 후에만 출력
      print('Request URL: ${res.realUri}');
      print('Status Code: ${res.statusCode}');
      print('Response Data: ${res.data}');
      print(res.data['data']);

      bool isSuccessed = res.data['success'];


      if(isSuccessed){ // 요청 성공 시
        setState(() {
          _resText = res.data['data'];
        });
      }else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('요청 실패') , backgroundColor: Colors.redAccent,));
      }
    }catch(e){
      print('Error occurred: $e');
      ScaffoldMessenger.of(context).hideCurrentSnackBar(); // 현재 스낵바 숨기기
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('요처ㅗㅇ 실패') , backgroundColor: Colors.redAccent,));
    }

  }
}
