import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sancheck/globals.dart';
import 'package:sancheck/provider/mountain_provider.dart';
import 'package:sancheck/screen/login_success.dart';
import 'package:sancheck/service/auth_service.dart';
import 'package:sancheck/service/mountain_service.dart';
import 'package:sancheck/service/trail_service.dart';

class HomeMtDetail extends StatefulWidget {
  final String mountainName;

  HomeMtDetail({required this.mountainName});

  @override
  _HomeMtDetailState createState() => _HomeMtDetailState();
}

class _HomeMtDetailState extends State<HomeMtDetail> {
  final TrailService _trailService = TrailService();
  final MountainService _mountainService = MountainService();
  List<bool> _isOpenList = [];
  List<dynamic> _trails = [];
  List<List<dynamic>> _spots = [];
  bool _isLoading = true;
  Map<String, dynamic>? _mountain;
  int? _mountIdx;
  bool _containsMountIdx=false;


  Future<void> _selectTrail() async {
    try {
      List<dynamic> trails = await _trailService.selectTrailByMountName(widget.mountainName);
      if(trails.isEmpty){
        return;
      } else {
        setState(() {
          _trails = trails;
          _isOpenList = List.generate(_trails.length, (index) => false);
        });

        await _selectSpot();
        await _initializeData(); // 데이터를 초기화하는 메서드 호출

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
        });
      }
    } catch (e) {
      print("Error fetching spots: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 데이터를 초기화하는 메서드
  Future<void> _initializeData() async{
    // mount_name을 통해 해당 맵을 가져옴
    _mountain = allMountains?.firstWhere(
          (mountain) => mountain['mount_name'] == widget.mountainName,
      orElse: () => null, // 조건에 맞는 항목이 없을 경우 null 반환
    );

    // mount_idx를 가져옴
    _mountIdx = _mountain != null ? _mountain!['mount_idx'] as int? : null;

    // 추가적인 초기화 작업이 필요하다면 여기서 수행
    print('Selected Mountain: $_mountain');
    print('Mount Index: $_mountIdx');

    // _mountIdx가 리스트에 있는지 확인
    setState(() {
      _containsMountIdx = favMountains!.any((item) => item['mount_idx'] == _mountIdx);
      _isLoading = false;
    });
  }


  @override
  void initState() {
    super.initState();
    //_isOpenList = List.generate(courseDetails.length, (index) => false);
    _selectTrail();
  }


  @override
  Widget build(BuildContext context) {
    final mountainProvider = Provider.of<MountainProvider>(context); // Provider 접근

    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    if(_isLoading) {
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
            _buildStyledButton(
              widget.mountainName,
              trailingIcon: _containsMountIdx
                  ? Icons.star
                  : Icons.star_border,
              
              // 별 버튼 클릭
              onTrailingIconPressed: () async {

                  if (_containsMountIdx) { //favMt에서 제거
                    setState(() {
                      favMountains!.removeWhere((item) => item['mount_idx'] == _mountIdx);
                    });
                    await _removeFavMountain(_mountIdx!, userModel!.userId);
                    mountainProvider.updateFavMountain();

                  } else { // favMt에 추가
                    setState(() {
                      favMountains!.add({'mount_idx': _mountIdx, 'user_id': userModel!.userId});
                    });
                    await _addFavMountain(_mountIdx!, userModel!.userId);
                    mountainProvider.updateFavMountain();
                  }
                  // _containsMountIdx를 상태에 맞게 업데이트
                  setState(() {
                    _containsMountIdx = !_containsMountIdx;
                  });



              },
              ),
            SizedBox(height: 20),
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
                        courseInfo: _trails[index],
                        onPressed: () {
                          setState(() {
                            _isOpenList[index] = !_isOpenList[index];
                          });
                        },
                        hasRouteButton: true,
                        trail: _trails[index], // 선택된 등산로 가져가기
                        spots: _spots[index],
                      ),
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

  Widget _buildStyledButton(
      String text, {
        IconData? trailingIcon,
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
            // Expanded를 사용해 텍스트가 버튼과 겹치지 않도록 함
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
                    Text(
                      '🚩 ${courseInfo['trail_name'] ?? ''}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.visible,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '🏃‍♂️ ${courseInfo['trail_distance'] ?? ''}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ],
              ),
            ),
            if (hasRouteButton)
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: ElevatedButton(
                  onPressed: () {
                    // 길찾기 관련 변수 설정
                    var selectedTrailIdx = trainIdx;
                    var selectedTrailPath = trailPath;

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
            if (trailingIcon != null)
              IconButton(
                icon: Icon(
                  trailingIcon,
                  color: trailingIcon == Icons.star || trailingIcon == Icons.star_border
                      ? Colors.orange
                      : Colors.black, // 별 아이콘만 노란색으로 설정, 나머지는 기본 색상
                ),
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
            onTap: () => _showImagePopup(context, 'https://via.placeholder.com/400'),
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
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
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

  Future<void> _addFavMountain(int mountIdx, String userId)async {
    await _mountainService.addFavMountain(mountIdx, userId);
  }

  Future<void> _removeFavMountain(int mountIdx, String userId)async {
    await _mountainService.removeFavMountain(mountIdx, userId);
  }


}
