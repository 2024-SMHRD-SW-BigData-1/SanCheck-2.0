import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';


class NaverMapTest extends StatelessWidget {
  const NaverMapTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NaverMap(
        options: const NaverMapViewOptions(
          locationButtonEnable: true,
          minZoom: 5, // default is 0
          extent: const NLatLngBounds(
            southWest: NLatLng(31.43, 122.37),
            northEast: NLatLng(44.35, 132.0),
          ),
        ),
        onMapReady: (controller) {
          print("네이버 맵 로딩됨!");
        },
      ),
    );;
  }
}

