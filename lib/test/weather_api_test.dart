// WeatherApiTest.dart
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:sancheck/service/api_service.dart';
import 'package:sancheck/test/grid_conv_test.dart'; // GPS를 grid로 변환하는 함수

class WeatherApiTest extends StatefulWidget {
  const WeatherApiTest({super.key});

  @override
  State<WeatherApiTest> createState() => _WeatherApiTestState();
}

class _WeatherApiTestState extends State<WeatherApiTest> {
  final Location location = Location();
  final ApiService apiService = ApiService(); // ApiService 인스턴스 생성
  bool _isPermissionGranted = false;
  Map<String, List<dynamic>> _weatherData = {}; // 카테고리별 데이터를 저장할 변수

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Data'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () async {
                  await _fetchWeatherData();
                },
                child: Text('날씨 데이터 가져오기'),
              ),
              ..._weatherData.entries.map((entry) {
                String category = entry.key;
                List<dynamic> data = entry.value;
                return _buildCategorySection(category, data);
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(String title, List<dynamic> data) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          ...data.map((item) => Padding(

            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              'Date : ${item['fcstDate']} - Time: ${item['fcstTime']} - Value: ${item['fcstValue']}',
              style: TextStyle(fontSize: 16),
            ),
          )).toList(),
        ],
      ),
    );
  }

  Future<void> _checkPermissions() async {
    PermissionStatus permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
      if (permission != PermissionStatus.granted) {
        setState(() {
          _weatherData = {};
        });
        return;
      }
    }
    setState(() {
      _isPermissionGranted = true;
    });
  }

  Future<void> _fetchWeatherData() async {
    if (!_isPermissionGranted) {
      setState(() {
        _weatherData = {'Error': ['위치 권한이 필요합니다.']};
      });
      return;
    }

    try {
      final LocationData currentLocation = await location.getLocation();
      if (currentLocation.latitude == null || currentLocation.longitude == null) {
        setState(() {
          _weatherData = {'Error': ['위치 정보를 가져올 수 없습니다.']};
        });
        return;
      }

      // 위도와 경도를 grid로 변환
      double nx = (currentLocation.latitude!);
      double ny = (currentLocation.longitude!);

      var gpsToGridData = ConvGridGps.gpsToGRID(nx, ny);

      var gridX = gpsToGridData['x'];
      var gridY = gpsToGridData['y'];
      print('위도, 경도 grid : $gridX $gridY');

      // ApiService를 통해 날씨 데이터 가져오기
      Map<String, List<dynamic>> fetchedData = await apiService.fetchWeatherData(gridX, gridY);

      setState(() {
        _weatherData = fetchedData;
      });
    } catch (e) {
      print('Error occurred22: $e');
      setState(() {
        _weatherData = {'Error': ['날씨 데이터 불러오기 실패']};
      });
    }
  }
}
