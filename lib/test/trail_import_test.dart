import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TrailImportTest extends StatefulWidget {
  const TrailImportTest({super.key});

  @override
  State<TrailImportTest> createState() => _TrailImportTestState();
}

class _TrailImportTestState extends State<TrailImportTest> {
  List<LatLng> _trailCoordinates = [];

  @override
  void initState() {
    super.initState();
    _fetchTrailData();
  }

  Future<void> _fetchTrailData() async {
    try {
      final dio = Dio();
      String url = "http://192.168.219.200:8000/mountain/trailTest";
      final response = await dio.get(url);

      print('aaaaaaaa $response.data');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        if (data.isNotEmpty) {
          final trail = data[0];
          final path = trail['path'] as String;
          final coordinates = _parseLineString(path);
          setState(() {
            _trailCoordinates = coordinates;
          });
        }
      } else {
        throw Exception('Failed to load trail data');
      }
    } catch (e) {
      print('Error fetching trail data: $e');
    }
  }

  List<LatLng> _parseLineString(String lineString) {
    final coordinates = lineString
        .replaceAll('LINESTRING(', '')
        .replaceAll(')', '')
        .split(',')
        .map((coord) {
      final parts = coord.split(' ');
      return LatLng(double.parse(parts[1]), double.parse(parts[0]));
    }).toList();
    return coordinates;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trail Map'),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(37.8, 127.9), // 초기 위치
          initialZoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: _trailCoordinates,
                strokeWidth: 10.0,
                color: Colors.purpleAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}