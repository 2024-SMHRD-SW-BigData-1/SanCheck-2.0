import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sancheck/provider/mountain_provider.dart';
import 'package:sancheck/screen/loading_page.dart';
import 'package:sancheck/test/weather_api_test.dart';
//import 'package:sancheck/screen/login_page.dart';
//import 'package:sancheck/test/chatgpt_api_test.dart';
// import 'package:sancheck/test/trail_import_test.dart';
//import 'package:sancheck/test/weather_api_test.dart';


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MountainProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoadingPage(),
    );
  }
}





