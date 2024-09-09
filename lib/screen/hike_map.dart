import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:location/location.dart';
import 'package:sancheck/globals.dart';

class HikeMap extends StatefulWidget {
  const HikeMap({super.key});

  @override
  State<HikeMap> createState() => _HikeMapState();
}

class _HikeMapState extends State<HikeMap> {
  List<NLatLng> _coords = []; // 등산로 그리기
  NLatLng? _currentPosition;
  NCameraPosition _cameraPosition = const NCameraPosition(
    target: NLatLng(37.5665, 126.978),
    zoom: 10,
    bearing: 0,
    tilt: 0,
  );

  Future<void> _initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    Location location = Location();
    final LocationData currentLocation = await location.getLocation();

    double nx = (currentLocation.latitude!);
    double ny = (currentLocation.longitude!);

    _cameraPosition = NCameraPosition(
      target: NLatLng(nx, ny),
      zoom: 10,
      bearing: 0,
      tilt: 0,
    );

    // 위치 서비스 확인 및 요청
    bool _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    // 위치 권한 확인 및 요청
    PermissionStatus _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    // 경로 정보 set
    if(selectedTrail != null){
      setState(() {
        _coords = selectedTrail!['trail_path'].map<NLatLng>((point) {
          return NLatLng(point['x'], point['y']);
        }).toList();
      });
    }

  }

  // spot을 지도에 추가하는 함수
  Future<void> addSpotsToMap(controller) async {
    if (selectedSpots!.isEmpty || selectedSpots == null) {
      return;
    }
    NOverlayImage image = await NOverlayImage.fromWidget(widget: Icon(Icons.add_alert), size: Size(5.0, 5.0), context: context);
    // 맵 컨트롤러가 준비된 후 마커를 추가하도록 수정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      selectedSpots!.forEach((spot) {
        // mountain은 배열 안의 각 객체(산 정보)를 나타냅니다.
        final marker = NMarker(
          id: spot['spot_idx'].toString(), // 스팟의 고유 ID
          icon: image,
          position: NLatLng(double.parse(spot['spot_latitude']), double.parse(spot['spot_longitude'])), // 마커의 위치 설정
          size: Size(20, 25), // 마커의 크기 설정
          caption: NOverlayCaption(text: spot['spot_name'], textSize: 12.0, color: spot['spot_danger']=='t'?Colors.red:Colors.black),
          isHideCollidedSymbols: true,
        );

        // 마커를 지도에 추가
        controller.addOverlay(marker);
        marker.setOnTapListener((NMarker marker) => {
          print("마커 클릭됨"),
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  Widget build(BuildContext context) {
    return NaverMap(
      forceGesture: true,
      options: NaverMapViewOptions(
        initialCameraPosition: _cameraPosition,
        consumeSymbolTapEvents: false,
        locationButtonEnable: true,
        logoClickEnable: false,
        minZoom: 5, // default is 0
        maxZoom: 18, // default is 21
        extent: const NLatLngBounds(
          southWest: NLatLng(31.43, 122.37),
          northEast: NLatLng(44.35, 132.0),
        ),
      ),
      onMapReady: (controller) {
        print("등산하기 맵 로딩 완료");
        NLocationTrackingMode mode = NLocationTrackingMode.follow;
        controller.setLocationTrackingMode(mode);

        // 경로가 있는 경우 NPathOverlay를 추가
        if (_coords.isNotEmpty && selectedSpots != null) {
          var route = NPathOverlay(
            id: '$selectedTrail["trail_idx"]',
            coords: _coords,
            color: Colors.blue,
            width: 5,
          );
          controller.addOverlay(route);

          addSpotsToMap(controller);

          controller.updateCamera(NCameraUpdate.withParams(
            target: NLatLng(
              double.parse(selectedMountain!['mount_latitude']),
              double.parse(selectedMountain!['mount_longitude']),
            ),
            zoom: 11,
            bearing: 0,
            tilt: 0,
          ));
        }
      },
    );
  }
}
