import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:sancheck/service/api_service.dart';
import 'package:sancheck/test/grid_conv_test.dart';

class WeatherModal extends StatefulWidget {

  @override
  State<WeatherModal> createState() => _WeatherModalState();
}

class _WeatherModalState extends State<WeatherModal> {
  final ApiService apiService = ApiService(); // ApiService 인스턴스 생성
  bool _isPermissionGranted = false;
  Map<String, List<dynamic>> _weatherData = {}; // 카테고리별 데이터를 저장할 변수
  final Location location = Location();
  bool _isLoading = true; // 로딩 상태를 관리하는 변수

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchWeatherData(); // 날씨 가져오기
  }


  Future<void> _checkPermissions() async {
    PermissionStatus permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
      if (permission != PermissionStatus.granted) {
        setState(() {
          _weatherData = {};
          _isLoading = false; // 로딩 상태 해제
        });
        return;
      }
    }
    setState(() {
      _isPermissionGranted = true;
    });
  }

  Future<void> _fetchWeatherData() async {
    await _checkPermissions(); // 위치 권한 여부 체크

    if (!_isPermissionGranted) {
      setState(() {
        _weatherData = {'Error': ['위치 권한이 필요합니다.']};
        _isLoading = false; // 로딩 상태 해제
      });
      return;
    }

    try {
      final LocationData currentLocation = await location.getLocation();
      if (currentLocation.latitude == null || currentLocation.longitude == null) {
        setState(() {
          _weatherData = {'Error': ['위치 정보를 가져올 수 없습니다.']};
          _isLoading = false; // 로딩 상태 해제
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
        _isLoading = false; // 로딩 상태 해제
      });
    } catch (e) {
      print('Error occurred22: $e');
      setState(() {
        _weatherData = {'Error': ['날씨 데이터 불러오기 실패']};
        _isLoading = false; // 로딩 상태 해제
      });
    }
  }


  @override
  Widget build(BuildContext context) {

    // 현재 날짜 및 시간 가져오기
    DateTime now = DateTime.now();

    // 분을 00으로 고정한 새로운 DateTime 객체 생성
    DateTime modifiedNow = DateTime(now.year, now.month, now.day, now.hour, 0);

    // 날짜 및 시간 포맷 설정 (예: '2024/09/03 14:00')
    String formattedDate = DateFormat('yyyy/MM/dd HH:mm').format(modifiedNow);

    // 로딩 상태일 때 로딩 인디케이터 표시

    // WeatherData를 사용해 각 항목을 매핑
    final weatherDataMap = {
      '습도': {
        'iconUrl': 'https://img.icons8.com/ios-filled/100/hygrometer.png',
        'value': _getValue('REH', '습도', '%')
      },
      '일 최저 기온 (˚C)': {
        'iconUrl': 'https://img.icons8.com/color/96/cold.png',
        'value': _getValue('TMN', '일 최저 기온', '˚C')
      },
      '일 최고 기온 (˚C)': {
        'iconUrl': 'https://img.icons8.com/color/96/hot.png',
        'value': _getValue('TMX', '일 최고 기온', '˚C')
      },
      '1시간 기온 (˚C)': {
        'iconUrl': 'https://img.icons8.com/ios-filled/100/thermometer.png',
        'value': _getValue('TMP', '1시간 기온', '˚C')
      },
      '풍속 (m/s)': {
        'iconUrl': 'https://img.icons8.com/ios-filled/100/wind.png',
        'value': _getValue('WSD', '풍속', 'm/s')
      },
      '강수 확률': {
        'iconUrl': 'https://img.icons8.com/ios/50/rainy-weather.png',
        'value': _getValue('POP', '강수 확률', '%')
      },
      '강수 형태': {
        'iconUrl': 'https://img.icons8.com/ios-filled/100/umbrella.png',
        'value': _getValue('PTY', '강수 형태', '')
      },
      '1시간 강수량 (mm)': {
        'iconUrl': 'https://img.icons8.com/ios-filled/100/rain.png',
        'value': _getValue('PCP', '1시간 강수량', '')
      },
      '1시간 신적설 (cm)': {
        'iconUrl': 'https://img.icons8.com/ios-filled/100/snow.png',
        'value': _getValue('SNO', '1시간 신적설', '')
      },
      '하늘 상태': {
        'iconUrl': 'https://img.icons8.com/ios-filled/100/cloud.png',
        'value': _getValue('SKY', '하늘 상태', '')
      },
    };



    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          alignment: WrapAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '날씨 정보',
                  style: TextStyle(
                    color: Color(0xFF1E1E1E),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  color: Colors.black54,
                ),
              ],
            ),
            // 로딩 중일 때 로딩 인디케이터 표시
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(),
              ),

            // 로딩이 끝난 후 데이터 표시
            // weatherDataMap을 사용해 동적으로 정보를 생성
            if (!_isLoading)
              Text(
                formattedDate,
                style: TextStyle(
                  color: Color(0xFF1E1E1E),
                  fontSize: 8,
                ),
              ),
            if (!_isLoading)
            const SizedBox(height: 24),
            if (!_isLoading)
              ...weatherDataMap.entries.map((entry) {
                final iconUrl = entry.value['iconUrl'] as String;
                final value = entry.value['value'] as String;
                return _buildWeatherInfo(
                  iconUrl: iconUrl,
                  title: entry.key,
                  value: value,
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  // weatherData에서 값을 가져오는 함수
  String _getValue(String key, String defaultTitle, String unit) {
    final data = _weatherData[key];
    if (data != null && data.isNotEmpty) {
      return '${data[0]['fcstValue']} $unit';
    }
    return '데이터 없음';
  }

  Widget _buildWeatherInfo({
    required String iconUrl,
    required String title,
    required String value,
  })
  {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            iconUrl,
            width: 24,
            height: 24,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.error, color: Colors.red); // 대체 아이콘
            },
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Color(0xFF1E1E1E),
                fontSize: 12,
                fontWeight: FontWeight.bold, // 볼드체로 설정
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Color(0xFF1E1E1E),
              fontSize: 12,
              fontWeight: FontWeight.bold, // 볼드체로 설정
            ),
          ),
        ],
      ),
    );
  }
}
