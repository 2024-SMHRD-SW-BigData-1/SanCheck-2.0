import 'package:flutter/material.dart';
import 'package:sancheck/globals.dart';
import 'package:sancheck/screen/login_success.dart';
import 'package:sancheck/service/mountain_service.dart';
import 'package:sancheck/service/trail_service.dart';
import 'hike.dart'; // Hike 클래스를 import

class LevelMt extends StatefulWidget {
  final String level;

  LevelMt({required this.level});

  @override
  _LevelMtState createState() => _LevelMtState();
}

class _LevelMtState extends State<LevelMt> {
  final TrailService _trailService = TrailService();
  final MountainService _mountainService = MountainService();
  List<bool> _isOpenList = [];
  List<dynamic> _trails = [];
  List<List<dynamic>> _spots = [];
  bool _isLoading = true;

  Future<void> _selectTrail() async {
    try {
      List<dynamic> trails = await _trailService.selectTrailByTrailLevel(widget.level);
      if(trails.isEmpty){
        return;
      } else {
        setState(() {
          _trails = trails;
          _isOpenList = List.generate(_trails.length, (index) => false);
        });

        print(_trails);

        await _selectSpot();

      }
    } catch (e) {
      print("Error fetching all mountains: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectSpot() async {
    try {
      List<List<dynamic>> allSpots = [];
      for (var trail in _trails) {
        int trailIdx = trail['trail_idx'];
        List<dynamic> spots = await _trailService.selectSpotsByTrailId(trailIdx);
        allSpots.add(spots);
      }
      if(allSpots.isEmpty){
        _isLoading = false;
        return;
      } else {
        setState(() {
          _spots = allSpots;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching spots: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }



  @override
  void initState() {
    super.initState();
    _selectTrail();
  }

  @override
  Widget build(BuildContext context) {
    if(_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${widget.level} 코스 리스트'),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }


    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('${widget.level} 코스 리스트'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          children: [
            SizedBox(height: 20),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 10),
            itemCount: _trails.length,
            separatorBuilder: (context, index) => SizedBox(height: 16),
            itemBuilder: (context, index) {
              // mount_name을 표시할지 여부를 결정
              bool showMountName = index == 0 || _trails[index]['mount_name'] != _trails[index - 1]['mount_name'];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // mount_name이 첫 번째 항목이거나 이전과 다를 때만 표시
                  if (showMountName)
                    Padding(
                      padding: EdgeInsets.only(bottom: 12, top: 18),
                      child: Text(
                        '📍${_trails[index]['mount_name']}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  _buildStyledButton(
                    '코스 ${index + 1} 상세 보기',
                    trailingIcon: _isOpenList[index]
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    courseInfo: _trails[index],
                    onPressed: () {
                      setState(() {
                        _isOpenList[index] = !_isOpenList[index];
                      });
                    },
                    hasRouteButton: true, // 길찾기 버튼이 있는지 여부
                    trail: _trails[index],
                    spots: _spots[index],
                  ),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    height: _isOpenList[index] ? _spots[index].length * 120.0 : 0,
                    child: _isOpenList[index]
                        ? ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _spots[index].length,
                      itemBuilder: (context, subIndex) {
                        return _buildSubCourseItem(_spots[index][subIndex]);
                      },
                    )
                        : SizedBox(),
                  ),
                ],
              );
            },
          ),
        ),
        ],
        ),
      ),
    );
  }

  Widget _buildStyledButton(String text,
      {IconData? trailingIcon,
        Map<String, dynamic>? courseInfo,
        VoidCallback? onTrailingIconPressed,
        VoidCallback? onPressed,
        bool hasRouteButton = false,
        Map<String, dynamic>? trail,
        List<dynamic>? spots
      }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.92,
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.white),
          padding: MaterialStateProperty.all(
            EdgeInsets.symmetric(
              vertical: screenWidth * 0.04,
              horizontal: screenWidth * 0.06,
            ),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          overlayColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)) {
                return Color(0x3F000000);
              }
              return null;
            },
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  if (courseInfo != null) ...[
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '🚩 ${courseInfo['trail_level'] ?? ''}',
                            style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                color: Colors.black),
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '🏃‍♂️ ${courseInfo['trail_distance'] ?? ''}',
                            style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                color: Colors.black),
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (hasRouteButton)
              Padding(
                padding: EdgeInsets.only(left: 10),
                
                // 길찾기 버튼 기능
                child: ElevatedButton(
                    onPressed:  () {
                      selectedMountain = allMountains!.firstWhere(
                            (element) => element['mount_name'] == trail!['mount_name'],
                        orElse: () => null, // 조건에 맞는 값이 없을 경우 null 반환
                      );
                      selectedTrail = trail;
                      selectedSpots = spots;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginSuccess(selectedIndex: 0),
                        ),
                            (Route<dynamic> route) => false,
                      );
                    },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  child: Text(
                    '길찾기',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubCourseItem(Map<String, dynamic> subCourse) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      width: screenWidth * 0.9,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () =>
                _showImagePopup(context, 'https://via.placeholder.com/400'),
            child: Container(
              width: 90,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12)),
                image: DecorationImage(
                  image: NetworkImage('https://via.placeholder.com/90'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '세부 코스 ${subCourse['spot_idx']}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    subCourse['spot_name'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePopup(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    '닫기',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
