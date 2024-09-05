import 'package:flutter/material.dart';
import 'package:sancheck/globals.dart';
import 'package:sancheck/screen/login_success.dart';
import 'package:sancheck/service/trail_service.dart';

class HomeMtDetail extends StatefulWidget {
  final String mountainName;

  HomeMtDetail({required this.mountainName});

  @override
  _HomeMtDetailState createState() => _HomeMtDetailState();
}

class _HomeMtDetailState extends State<HomeMtDetail> {
  TrailService _trailService = TrailService();
  Set<String> favoriteItems = {};
  List<bool> _isOpenList = [];
  List<dynamic> _trails = [];
  List<List<dynamic>> _spots = [];
  bool _isLoading = true;

  // final List<Map<String, String>> courseDetails = [
  //   {'difficulty': '쉬움', 'time': '1시간', 'distance': '2.5km'},
  //   {'difficulty': '보통', 'time': '1시간 30분', 'distance': '3.0km'},
  //   {'difficulty': '어려움', 'time': '2시간', 'distance': '4.5km'},
  //   {'difficulty': '쉬움', 'time': '45분', 'distance': '1.5km'},
  //   {'difficulty': '보통', 'time': '2시간 30분', 'distance': '5.0km'},
  // ];

  // final List<List<String>> subCourses = [
  //   ['1', '2', '3', '4', '5'],
  //   ['1', '2', '3'],
  //   ['1', '2', '3', '4'],
  //   ['1', '2'],
  //   ['1', '2', '3', '4', '5', '6']
  // ];

  @override
  void initState() {
    super.initState();
    //_isOpenList = List.generate(courseDetails.length, (index) => false);
    _selectTrail();
  }

  Future<void> _selectTrail() async {
    try {
      List<dynamic> trails = await _trailService.selectTrail(widget.mountainName);

      if(trails.isEmpty){
        return;
      }else{
        setState(() {
          _trails = trails;
        });

        await _selectSpot();

        _isOpenList = List.generate(_trails.length, (index) => false);


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
      // 스팟 리스트를 저장할 리스트 생성
      List<List<dynamic>> allSpots = [];

      // 각 등산로에 대해 스팟 데이터를 가져옴
      for (var trail in _trails) {
        int trailIdx = trail['trail_idx']; // 각 등산로의 ID를 가져옴
        List<dynamic> spots = await _trailService.selectSpotsByTrailId(trailIdx);

        // 가져온 스팟 리스트를 추가
        allSpots.add(spots);
      }

      // 가져온 스팟 리스트 출력 (테스트용)
      print(allSpots);

      if(allSpots.isEmpty){
        return;
      }else{
        setState(() {
          _spots = allSpots;
          _isLoading = false;
        });
      }
      // 필요에 따라 상태에 추가


    } catch (e) {
      print("Error fetching spots: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }




  @override
  Widget build(BuildContext context) {

    if(_isLoading){
      return Scaffold(
        appBar: AppBar(
          title: Text('${widget.mountainName} 코스 리스트'),
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

    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('${widget.mountainName} 코스 리스트'),
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
            
            // 산 이름, 별 버튼
            _buildStyledButton(
              widget.mountainName,
              trailingIcon: favoriteItems.contains(widget.mountainName)
                  ? Icons.star
                  : Icons.star_border,
              onTrailingIconPressed: () {
                setState(() {
                  if (favoriteItems.contains(widget.mountainName)) {
                    favoriteItems.remove(widget.mountainName);
                  } else {
                    favoriteItems.add(widget.mountainName);
                  }
                });
              },
            ),
            SizedBox(height: 20),
            
            // 코스 나열(세부코스 아님)
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 10),
                itemCount: _trails.length,
                separatorBuilder: (context, index) => SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      _buildStyledButton(
                        '코스 ${index + 1}',
                        trailingIcon: _isOpenList[index]
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        // Map<> 구조
                        courseInfo: _trails[index],
                        // 클릭 시 _isOpenList 토글
                        onPressed: () {
                          setState(() {
                            _isOpenList[index] = !_isOpenList[index];
                          });
                        },
                        hasRouteButton: true, // 길찾기 버튼이 있는지 여부
                        trail: _trails[index], // 선택된 등산로 가져가기
                        spots: _spots[index],
                      ),


                      // 세부코스(spot)
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        height: _isOpenList[index]
                            ? _spots[index].length * 120.0
                            : 0,
                        child: _isOpenList[index]
                            ? ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _spots[index].length,
                          itemBuilder: (context, subIndex) {
                            return _buildSubCourseItem(
                                _spots[index][subIndex]);
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
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return Container(
      width: screenWidth * 0.92,
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.white),
          padding: WidgetStateProperty.all(
            EdgeInsets.symmetric(
              vertical: screenWidth * 0.04,
              horizontal: screenWidth * 0.06,
            ),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
              if (states.contains(WidgetState.pressed)) {
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
                        Text(
                          '🚩 ${courseInfo['trail_name'] ?? ''}',
                          style: TextStyle(fontSize: screenWidth * 0.04,
                              color: Colors.black),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '🏃‍♂️ ${courseInfo['trail_distance'] ?? ''}',
                          style: TextStyle(fontSize: screenWidth * 0.04,
                              color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // 길찾기 버튼
            if (hasRouteButton)
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: ElevatedButton(
                  
                  // 길찾기 버튼 클릭 콜백
                  onPressed:  () async{
                    selectedMountain = allMountains!.firstWhere(
                          (element) => element['mount_name'] == widget.mountainName,
                      orElse: () => null, // 조건에 맞는 값이 없을 경우 null 반환
                    );
                    selectedSpots = spots;
                    selectedTrail = trail;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginSuccess(selectedIndex: 0),
                      ),
                          (Route<dynamic> route) => false, // 모든 이전 화면을 제거
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
            if (trailingIcon != null)
              IconButton(
                icon: Icon(trailingIcon, color: Colors.black),
                onPressed: onTrailingIconPressed,
                constraints: BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
          ],
        ),
      ),
    );
  }







  Widget _buildSubCourseItem(Map<String, dynamic> subCourse) {
    // print('서브코스 $subCourse');
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

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
                _showImagePopup(context,
                    'https://via.placeholder.com/400'),
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
                padding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 16),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // 초록색으로 변경
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