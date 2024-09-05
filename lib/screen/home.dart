import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sancheck/globals.dart';
import '../provider/mountain_provider.dart';
import 'gpx_navigation.dart'; // GpxNavigation 클래스를 포함한 파일을 import
import 'home_mt_detail.dart'; // Import the detail page
import 'level_mt.dart'; // 난이도별 코스 상세 페이지 import

Dio dio = Dio();

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // TextController를 dispose
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final mountainProvider = Provider.of<MountainProvider>(context); // Provider 접근

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Image.network(
                        'https://img.icons8.com/pastel-glyph/64/location--v3.png',
                        width: screenWidth * 0.06,
                        height: screenHeight * 0.03,
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: '산 검색하기',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Image.network(
                          'https://img.icons8.com/metro/52/search.png',
                          width: screenWidth * 0.06,
                          height: screenHeight * 0.03,
                        ),
                        onPressed: () => _search(mountainProvider),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),
                Container(
                  height: screenHeight * 0.4,
                  child: GpxNavigation(),
                ),
                SizedBox(height: screenHeight * 0.005),
                ExpandableButtonList(
                  title: '인기있는 산',
                  items: [{'mount_idx':105}, {'mount_idx':38}, {'mount_idx':17},],
                  buttonColor: Colors.blue,
                  iconUrl:
                  'https://img.icons8.com/3d-fluency/94/fire-element--v2.png',
                  isNavigable: true,
                  showStarIcon: true, // 별 아이콘 표시 설정
                  navigateToPage: (selectedItem) => HomeMtDetail(
                    mountainName: selectedItem,
                  ),
                ),
                SizedBox(height: screenHeight * 0.005),
                ExpandableButtonList(
                  title: "관심있는 산",
                  items: favMountains!,
                  buttonColor: Colors.green,
                  iconUrl:
                  'https://img.icons8.com/emoji/96/sparkling-heart.png',
                  isNavigable: true,
                  showStarIcon: true,
                  navigateToPage: (selectedItem) => HomeMtDetail(
                    mountainName: selectedItem,
                  ),
                ),
                SizedBox(height: screenHeight * 0.005),
                ExpandableButtonList(
                  title: "난이도별 코스",
                  items: ["쉬움", "보통", "어려움"],
                  buttonColor: Colors.orange,
                  iconUrl: 'https://img.icons8.com/color/96/sparkling.png',
                  isNavigable: true,
                  showStarIcon: false, // 별 아이콘 숨기기
                  navigateToPage: (selectedItem) => LevelMt(level: selectedItem),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _search(MountainProvider mountainProvider) async {
    String queryText = _searchController.text;

    try {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      await mountainProvider.searchMountain(queryText); // 검색 실행
      if (mountainProvider.mountain == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('검색된 산이 없습니다.'), backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('검색 실패'), backgroundColor: Colors.redAccent));
    }
  }
}

class ExpandableButtonList extends StatefulWidget {
  final String title;
  final List<dynamic> items;
  final Color buttonColor;
  final String? iconUrl;
  final bool isNavigable;
  final bool showStarIcon; // 별 아이콘 표시 여부 플래그 추가
  final Widget Function(String)? navigateToPage;

  ExpandableButtonList({
    required this.title,
    required this.items,
    this.buttonColor = Colors.blue,
    this.iconUrl,
    this.isNavigable = true,
    this.showStarIcon = true, // 기본값으로 별 아이콘을 표시하도록 설정
    this.navigateToPage,
  });

  @override
  _ExpandableButtonListState createState() => _ExpandableButtonListState();
}

class _ExpandableButtonListState extends State<ExpandableButtonList> {
  bool _isExpanded = false;
  Set<String> favoriteItems = {};
  List<dynamic> commonItems = [];


  void searchCommonItems(){
    // 겹치는 mount_idx를 가진 객체를 찾는 코드
    commonItems = favMountains!.where((favItem) {
      return widget.items.any((item) => item['mount_idx'] == favItem['mount_idx']);
    }).toList();
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 누르면 isExpanded 토글 됨
          _buildStyledButton(widget.title, iconUrl: widget.iconUrl, onPressed: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          }),

          // isExpanded가 true일 때 생기는 리스트뷰
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: _isExpanded ? 200 : 0,

            // 상위 위젯에서 items 가져와서 ListView로 빌드
            child: ListView.builder(
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: screenWidth * 0.01),
                  child: _buildStyledButton(
                    widget.items[index],

                    // 버튼 클릭 시 해당 페이지로 이동
                    onPressed: () {
                      if (widget.isNavigable && widget.navigateToPage != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                widget.navigateToPage!(widget.items[index]),
                          ),
                        );
                      }
                    },

                    // 별 표시 여부
                    // showStarIcon이 true && 클릭한 아이템이 관심있는 산 목록에 있을 경우 : 채워진 별
                    trailingIcon: widget.showStarIcon && commonItems.isNotEmpty
                        ? Icons.star
                    // 반대일 경우 : 비워진 별
                        : widget.showStarIcon
                        ? Icons.star_border
                    // 둘 중 하나라도 아닌 경우 : null
                        : null, // 별 아이콘 표시 여부 조건 추가
                    
                    // 별 클릭 콜백
                    onTrailingIconPressed: () {
                      setState(() {
                        if (favoriteItems.contains(widget.items[index])) {
                          favoriteItems.remove(widget.items[index]);
                        } else {
                          favoriteItems.add(widget.items[index]);
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyledButton(String text,
      {String? iconUrl,
        required VoidCallback onPressed,
        IconData? trailingIcon,
        VoidCallback? onTrailingIconPressed}) {
    final screenWidth = MediaQuery.of(context).size.width;

    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.white),
        padding: MaterialStateProperty.all(
            EdgeInsets.symmetric(
                vertical: screenWidth * 0.04, horizontal: screenWidth * 0.06)),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (iconUrl != null) ...[
                Image.network(iconUrl,
                    width: screenWidth * 0.06, height: screenWidth * 0.06),
                SizedBox(width: screenWidth * 0.02),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          if (trailingIcon != null)
            IconButton(
              icon: Icon(trailingIcon, color: Colors.yellow[700]),
              onPressed: onTrailingIconPressed,
            ),
        ],
      ),
    );
  }
}
