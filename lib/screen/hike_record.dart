import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sancheck/globals.dart';
import 'package:sancheck/provider/hike_provider.dart';

class HikeRecordModal extends StatefulWidget {

  final int currentSteps;
  final double roundedUseCal;

  const HikeRecordModal({
    Key? key,
    required this.currentSteps,
    required this.roundedUseCal
}) : super(key: key);

  @override
  State<HikeRecordModal> createState() => _HikeRecordModalState();
}

class _HikeRecordModalState extends State<HikeRecordModal> {
  @override
  State<HikeRecordModal> createState() => _HikeRecordModalState();

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int hours = minutes ~/ 60;
    final int remainingMinutes = minutes % 60;
    final int remainingSeconds = seconds % 60;

    return '${hours.toString().padLeft(2, '0')}:${remainingMinutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      backgroundColor: Colors.white,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Add this line to adjust the height based on content
              children: [
                Text(
                  '하이킹 기록',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: selectedTrail!=null ? '등산로 : ${selectedTrail!['trail_name']} \n': '등산로 :  선택되지 않음 \n',
                              style: TextStyle(
                                color: Color(0xFF1E1E1E),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                height: 1.5,
                              ),
                            ),
                            TextSpan(
                              text: selectedSpots!=null ? '${selectedSpots![0]['spot_name']} ➡ ${selectedSpots![1]['spot_name']} ➡ ${selectedSpots![2]['spot_name']} ...' : '',
                              style: TextStyle(
                                color: Color(0xFF1E1E1E),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        '운동 정보',
                        style: TextStyle(
                          color: Color(0xFF1E1E1E),
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(Icons.access_time, '전체 시간', _formatTime(context.watch<HikeProvider>().secondNotifier)),
                          SizedBox(height: 16),
                          _buildInfoRow(Icons.directions_walk, '운동 거리', '5.9 km'),
                          SizedBox(height: 16),
                          _buildInfoRow(Icons.directions_run, '걸음수', widget.currentSteps.toString()),
                          SizedBox(height: 16),
                          _buildInfoRow(Icons.local_fire_department, '소모 칼로리', widget.roundedUseCal.toString()),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: IconButton(
              icon: Icon(
                Icons.close,
                size: 24,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.of(context).pop(); // 닫기 버튼 클릭 시 모달 닫기
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Color(0xFF1E1E1E),
            ),
            SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: Color(0xFF1E1E1E),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            color: Color(0xFF1E1E1E),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}