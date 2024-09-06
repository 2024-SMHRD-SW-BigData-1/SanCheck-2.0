import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:location/location.dart';
import 'package:pedometer/pedometer.dart';
import 'package:provider/provider.dart';
import 'package:sancheck/globals.dart';
import 'package:sancheck/provider/mountain_provider.dart';
import 'package:sancheck/screen/home_mt_detail.dart';
import 'package:sancheck/screen/loading_page.dart';
import 'package:sancheck/service/mountain_service.dart';

Dio dio = Dio();

class GpxNavigation extends StatefulWidget {


  const GpxNavigation({super.key});

  @override
  GpxNavigationState createState() => GpxNavigationState();
}

class GpxNavigationState extends State<GpxNavigation> {

  // secureStorage, Location package
  final _storage = FlutterSecureStorage();
  final Location _location = Location();

  NCameraPosition _cameraPosition = const NCameraPosition(
    target: NLatLng(37.5665, 126.978), // 서울 시청
    zoom: 10,
    bearing: 0,
    tilt: 0,
  );
  Location location = Location();

  // 네이버 맵 초기화
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    final LocationData currentLocation = await location.getLocation();

    double nx = (currentLocation.latitude!);
    double ny = (currentLocation.longitude!);

    _cameraPosition = NCameraPosition(
      target: NLatLng(nx, ny),
      zoom: 10,
      bearing: 0,
      tilt: 0,
    );

    // 네이버 앱 인증
    await NaverMapSdk.instance.initialize(
      clientId: '119m2j9zpj',
      onAuthFailed: (ex) {
        print("********* 네이버맵 인증오류 : $ex *********");
      },
    );

    // 위치 서비스 확인 및 요청
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    // 위치 권한 확인 및 요청
    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  // Naver Map SDK 초기화
  Future<void> _initializeNaverMapSdk() async {
    await NaverMapSdk.instance.initialize(clientId: '119m2j9zpj');
  }


  // 마커를 지도에 추가하는 함수
  void addMarkersToMap(controller) {
    if (allMountains!.isEmpty || allMountains==null){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>LoadingPage()));
    }

    // 맵 컨트롤러가 준비된 후 마커를 추가하도록 수정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      allMountains!.forEach((mountain) {

        // mountain은 배열 안의 각 객체(산 정보)를 나타냅니다.
        final marker = NMarker(
          id: mountain['mount_idx'].toString(), // 마커의 고유 ID
          position: NLatLng(double.parse(mountain['mount_latitude']),double.parse(mountain['mount_longitude'])), // 마커의 위치 설정
          size: Size(20, 25), // 마커의 크기 설정
          caption: NOverlayCaption(text: mountain['mount_name']),
          subCaption: NOverlayCaption(text: mountain['mount_detail'] ?? '', color: Colors.grey),
          isHideCollidedSymbols: true,

        );

        //final onMarkerInfoWindow = NInfoWindow.onMarker(id: marker.info.id, text: mountain['mount_name']);

        // 마커를 지도에 추가
        controller.addOverlay(marker);
        marker.setOnTapListener(
            (NMarker marker)=>{
              print("마커 클릭됨"),
              Navigator.push(context, MaterialPageRoute(builder: (_)=>HomeMtDetail(mountainName: mountain['mount_name'])))
              //marker.openInfoWindow(onMarkerInfoWindow),
            }
        );
      });
    });
  }


  // 검색된 산 마커를 지도에 추가하는 함수
  void addSearchMarkerToMap(controller, mountainProvider) {
    // 맵 컨트롤러가 준비된 후 마커를 추가하도록 수정
    WidgetsBinding.instance.addPostFrameCallback((_) {
        // provider에 저장된 산 가져오기.
      mountainProvider.mountain.forEach((mountain) {
        final marker = NMarker(
          id: mountain['mount_idx'].toString(), // 마커의 고유 ID
          position:
          NLatLng(double.parse(mountain['mount_latitude']),double.parse(mountain['mount_longitude'])), // 마커의 위치 설정
          size: Size(20, 25), // 마커의 크기 설정
          caption: NOverlayCaption(text: mountain['mount_name']),
          subCaption: NOverlayCaption(text: mountain['mount_detail'] ?? '', color: Colors.grey),
          isHideCollidedSymbols: true,
        );

        // 마커를 지도에 추가
        controller.addOverlay(marker);
        marker.setOnTapListener(
                (NMarker marker)=>{
              print("마커 클릭됨"),
              Navigator.push(context, MaterialPageRoute(builder: (_)=>HomeMtDetail(mountainName: mountain!['mount_name'])))
            });
      });
    });
  }





  @override
  Widget build(BuildContext context) {

    // Provider로부터 상태를 가져옴
    final mountainProvider = Provider.of<MountainProvider>(context);

    return FutureBuilder<void>(
      future: _initializeNaverMapSdk(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else {
          return Scaffold(
            body: NaverMap(
              forceGesture: true,
              options: NaverMapViewOptions(
                initialCameraPosition: _cameraPosition,
                consumeSymbolTapEvents: false,
                locationButtonEnable: true,
                logoClickEnable: false,
                minZoom: 5,
                maxZoom: 17,
                extent: const NLatLngBounds(
                  southWest: NLatLng(31.43, 122.37),
                  northEast: NLatLng(44.35, 132.0),
                ),
              ),
              onMapReady: (controller) {
                print("홈페이지 맵 로딩 완료");

                // 위치 추적 모드 설정
                NLocationTrackingMode mode = NLocationTrackingMode.follow;
                controller.setLocationTrackingMode(mode);

                // 데이터가 준비된 후에 마커를 추가하는 방법으로 이동

                // 상태에 따라 로직 수행
                if (mountainProvider.mountain != null) {
                  // 검색된 산이 있을 때 실행할 로직
                  print("검색된 산: ${mountainProvider.mountain}");
                  addSearchMarkerToMap(controller, mountainProvider);

                  // 입력창이 비어있을 때 -> 모든 산 불러옴 -> 현재 위치로 카메라 이동
                  if (mountainProvider.searchText == null || mountainProvider.searchText!.trim().isEmpty) {

                  }else{
                    controller.updateCamera(NCameraUpdate.withParams(
                      target: NLatLng(double.parse(mountainProvider.mountain![0]['mount_latitude']),double.parse(mountainProvider.mountain![0]['mount_longitude'])),
                      bearing: 0,
                      zoom: 10,
                    ));
                  }



                } else {
                  // 검색된 산이 없거나 검색 실패 시 실행할 로직
                  addMarkersToMap(controller);
                  // print("검색된 산이 없습니다.");
                }
              },
            ),
          );
        }
      },
    );
  }
}
