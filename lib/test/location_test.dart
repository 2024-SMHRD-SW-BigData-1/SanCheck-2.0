import 'dart:math'; // 무작위 색상 생성을 위한 import
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:xml/xml.dart' as xml;


class GpxNavigation extends StatefulWidget {
  @override
  _GpxNavigationState createState() => _GpxNavigationState();
}

class _GpxNavigationState extends State<GpxNavigation> {
  final MapController _mapController = MapController();
  LocationData? _currentLocation;
  List<List<LatLng>> _gpxRoutes = [];
  Location _location = Location();

  @override
  void initState() {
    super.initState();
    _loadGpxData();
    _startLocationTracking();
  }

  void _loadGpxData() async {
    String gpxData = await DefaultAssetBundle.of(context).loadString('assets/111100101.gpx');
    final document = xml.XmlDocument.parse(gpxData);

    final routes = <List<LatLng>>[];
    for (var trk in document.findAllElements('trk')) {
      final segments = <LatLng>[];
      for (var trkseg in trk.findElements('trkseg')) {
        final points = trkseg.findElements('trkpt').map((element) {
          final lat = double.parse(element.getAttribute('lat')!);
          final lon = double.parse(element.getAttribute('lon')!);
          return LatLng(lat, lon);
        }).toList();
        if (points.isNotEmpty) {
          segments.addAll(points);
        }
      }
      if (segments.isNotEmpty) {
        routes.add(segments);
      }
    }

    setState(() {
      _gpxRoutes = routes;

      // GPX 데이터를 잘 불러왔는지 확인
      print("GPX Routes: $_gpxRoutes");

      // 지도의 중심을 GPX 경로의 첫 번째 지점으로 설정
      if (_gpxRoutes.isNotEmpty && _gpxRoutes[0].isNotEmpty) {
        _mapController.move(_gpxRoutes[0][0], 15.0);
      }
    });
  }

  void _startLocationTracking() {
    _location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        _currentLocation = currentLocation;
        _mapController.move(LatLng(currentLocation.latitude!, currentLocation.longitude!), 15.0);
      });
    });
  }

  Color _generateRandomColor() {
    final random = Random();
    return Color.fromARGB(
      255, // Alpha (opacity)
      random.nextInt(256), // Red
      random.nextInt(256), // Green
      random.nextInt(256), // Blue
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GPX Navigation'),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
            initialCenter: const LatLng(37.5, 127.0),
            initialZoom: 5.0
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          PolylineLayer(
            polylines: _gpxRoutes.asMap().entries.map((entry) {
              final index = entry.key;
              final route = entry.value;
              return Polyline(
                points: route,
                strokeWidth: 4.0,
                color: _generateRandomColor(), // 무작위 색상 생성
              );
            }).toList(),
          ),
          if (_currentLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  width: 40.0,
                  height: 40.0,
                  point: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
                  child: Icon(Icons.navigation, color: Colors.red),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
