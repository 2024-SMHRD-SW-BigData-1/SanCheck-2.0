import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../globals.dart';
import 'community_post.dart';

class Community extends StatefulWidget {
  @override
  _CommunityState createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  List<Map<String, dynamic>> _posts = [];
  List<TextEditingController> _commentControllers = [];
  int _selectedCategory = 0;

  // 등산 기록 데이터 (레벨, 닉네임 포함)
  List<Map<String, dynamic>> _hikingRecords = [
    {
      'imageUrl': 'https://via.placeholder.com/300',
      'mountainName': '무등산',
      'date': '2023-08-29',
      'courseName': '무등산 제1코스',
      'time': '2시간',
      'distance': '5.3km',
      'level': 'lv1',
      'nickname': '등산러123',
    },
    {
      'imageUrl': 'https://via.placeholder.com/300',
      'mountainName': '설악산',
      'date': '2023-09-05',
      'courseName': '중급자 코스',
      'time': '3시간',
      'distance': '7.1km',
      'level': 'lv2',
      'nickname': '산타',
    },
    {
      'imageUrl': 'https://via.placeholder.com/300',
      'mountainName': '북한산',
      'date': '2023-09-12',
      'courseName': '고급 코스',
      'time': '1시간 30분',
      'distance': '4.2km',
      'level': 'lv3',
      'nickname': '산정복자',
    },
  ];

  @override
  void initState() {
    super.initState();
    _commentControllers =
        List.generate(_posts.length, (index) => TextEditingController());
  }

  // 게시글 업로드
  void _showPostDialog(BuildContext context) async {
    final newPost = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: CommunityPost(category: _selectedCategory),
      ),
    );

    if (newPost != null) {
      setState(() {
        newPost['comments'] = [];
        _posts.insert(0, newPost);
        _commentControllers.insert(0, TextEditingController());
      });
    }

    Dio dio = Dio();

    String url = "localhost:8000/community/upload";

    dio.post(url, data: {

    });
  }

  void _addComment(int postIndex) {
    if (postIndex >= 0 && postIndex < _commentControllers.length) {
      final commentText = _commentControllers[postIndex].text.trim();
      if (commentText.isNotEmpty) {
        setState(() {
          _posts[postIndex]['comments'].add({
            'name': userModel!.userName, // 사용자 닉네임 추가
            'comment': commentText,
            'level': userModel!.userLevel, // 사용자 레벨 추가
            'iconUrl': getUserLevelIcon(int.parse(userModel!.userLevel)), // 사용자 아이콘 URL 추가
          });
          _commentControllers[postIndex].clear();
        });
      }
    }
  }

// 사용자 레벨에 따른 아이콘 URL을 반환하는 함수
  String getUserLevelIcon(int userLevel) {
    final List<String> levelIcons = [
      'https://img.icons8.com/external-yogi-aprelliyanto-flat-yogi-aprelliyanto/64/external-eggs-basket-spring-season-yogi-aprelliyanto-flat-yogi-aprelliyanto.png',
      'https://img.icons8.com/external-justicon-flat-justicon/64/external-chicken-easter-day-justicon-flat-justicon-1.png',
      'https://img.icons8.com/external-justicon-flat-justicon/64/external-chicken-easter-day-justicon-flat-justicon.png',
      'https://img.icons8.com/external-vitaliy-gorbachev-flat-vitaly-gorbachev/58/external-chicken-easter-vitaliy-gorbachev-flat-vitaly-gorbachev.png',
      'https://img.icons8.com/flat-round/64/crown--v1.png',
    ];
    return levelIcons[(userLevel - 1).clamp(0, levelIcons.length - 1)];
  }


  void _deletePost(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Center(
            child: Text(
              '게시물 삭제',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              '정말로 이 게시물을 삭제하시겠습니까?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
                child: Text(
                  '취소',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _posts.removeAt(index);
                    _commentControllers.removeAt(index);
                  });
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
                child: Text(
                  '삭제',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> _getFilteredPosts() {
    return _posts.where((post) {
      return post['category'] == _selectedCategory;
    }).toList();
  }

  @override
  void dispose() {
    for (var controller in _commentControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFFF5F5F5),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildCategoryButton(0),
                        SizedBox(width: 10),
                        _buildCategoryButton(1),
                      ],
                    ),
                    GestureDetector(    // 게시물 추가 버튼
                      onTap: () => _showPostDialog(context),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Image.network(
                          'https://img.icons8.com/color/96/add--v1.png',
                          width: 32,
                          height: 32,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_selectedCategory == 0)
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _getFilteredPosts().length,
                  itemBuilder: (context, index) {
                    final post = _getFilteredPosts()[index];
                    final comments = post['comments'] ?? [];
                    final commentController = (index < _commentControllers.length)
                        ? _commentControllers[index]
                        : TextEditingController();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Color(0xFFD9D9D9)),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x3F000000),
                            blurRadius: 4,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildUserProfile(
                            userLevel: int.parse(post['userLevel'] ?? '1'),
                            nickname: post['nickname'] ?? '닉네임 없음',
                          ),
                          if (post['images'] != null &&
                              post['images'].isNotEmpty)
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              height: 150,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children:
                                post['images'].map<Widget>((imagePath) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: GestureDetector(
                                        onTap: () =>
                                            _showImagePopup(context, imagePath),
                                        child: Image.file(
                                          File(imagePath),
                                          width: 150,
                                          height: 150,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          Text(
                            post['content'] ?? '',
                            style: TextStyle(
                              color: Color(0xFF1E1E1E),
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          if (post['location'] != null &&
                              post['location']!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                children: [
                                  Icon(Icons.location_on,
                                      size: 16, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Text(
                                    post['location'],
                                    style: TextStyle(
                                      color: Color(0xFF1E1E1E),
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // 댓글 목록 추가
                          // 댓글 렌더링 부분 (커뮤니티 코드 수정)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              children: comments.map<Widget>((comment) {
                                // comment 데이터가 제대로 들어오는지 디버그를 위해 확인
                                print('Comment Data: ${comment.toString()}');

                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // 레벨과 아이콘이 존재하는 경우에만 렌더링
                                      if (comment['level'] != null && comment['iconUrl'] != null)
                                        Padding(
                                          padding: const EdgeInsets.only(right: 8.0),
                                          child: Row(
                                            children: [
                                              // 아이콘을 보여줌
                                              Image.network(
                                                comment['iconUrl'],
                                                width: 20, // 아이콘 크기 설정
                                                height: 20,
                                                errorBuilder: (context, error, stackTrace) {
                                                  // 아이콘 로드에 실패했을 때
                                                  return Icon(Icons.error, color: Colors.red, size: 20);
                                                },
                                              ),
                                              SizedBox(width: 4), // 아이콘과 텍스트 사이 간격
                                              // 레벨을 텍스트로 표시
                                              Text(
                                                'Lv.${comment['level']}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      // 사용자 이름과 댓글 내용을 보여줌
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              comment['name'] ?? '익명', // 닉네임 표시
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              comment['comment'] ?? '', // 댓글 내용 표시
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: commentController,
                                    decoration: InputDecoration(
                                      hintText: '댓글을 입력하세요...',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Colors.grey.shade300),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Colors.grey.shade300),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Colors.green), // 초록색 테두리
                                      ),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    ),
                                  ),

                                ),
                                IconButton(
                                  icon: Icon(Icons.send, color: Colors.green),
                                  onPressed: () => _addComment(index),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            else
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _hikingRecords.length,
                  itemBuilder: (context, index) {
                    final record = _hikingRecords[index];
                    return _buildHikingRecordCard(record);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(int category) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
        _selectedCategory == category ? Colors.green : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        side: BorderSide(color: Colors.green, width: 1),
      ),
      child: Text(
        category == 0 ? '실시간 게시물' : '등산기록',
        style: TextStyle(
          color: _selectedCategory == category ? Colors.white : Colors.green,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // 등산 기록 카드
  Widget _buildHikingRecordCard(Map<String, dynamic> record) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _showImagePopup(context, record['imageUrl']),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  record['imageUrl'] ?? 'https://via.placeholder.com/300',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📍${record['mountainName'] ?? '알 수 없는 산'}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  record['date'] ?? '날짜 없음',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '🚩 ${record['courseName'] ?? '코스명 없음'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '🕒 ${record['time'] ?? '시간 없음'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '🏃‍♂️ ${record['distance'] ?? '거리 없음'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      record['level'] ?? '레벨 없음',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      '@${record['nickname'] ?? '닉네임 없음'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 이미지 확대 팝업 함수
  void _showImagePopup(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 16,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  ),
                  child: Text(
                    '닫기',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 커뮤니티 페이지 전용 사용자 프로필 빌드 함수
  Widget _buildUserProfile({required int userLevel, required String nickname}) {
    final double iconSize = 20.0; // 아이콘 크기
    final double textSize = 14.0; // 텍스트 크기

    // 레벨에 따른 아이콘 URL
    final List<String> levelIcons = [
      'https://img.icons8.com/external-yogi-aprelliyanto-flat-yogi-aprelliyanto/64/external-eggs-basket-spring-season-yogi-aprelliyanto-flat-yogi-aprelliyanto.png',
      'https://img.icons8.com/external-justicon-flat-justicon/64/external-chicken-easter-day-justicon-flat-justicon-1.png',
      'https://img.icons8.com/external-justicon-flat-justicon/64/external-chicken-easter-day-justicon-flat-justicon.png',
      'https://img.icons8.com/external-vitaliy-gorbachev-flat-vitaly-gorbachev/58/external-chicken-easter-vitaliy-gorbachev-flat-vitaly-gorbachev.png',
      'https://img.icons8.com/flat-round/64/crown--v1.png',
    ];

    // 현재 사용자의 레벨에 맞는 아이콘 URL 선택
    String iconUrl = levelIcons[(userLevel - 1).clamp(0, levelIcons.length - 1)];

    return Row(
      children: [
        Image.network(
          iconUrl,
          width: iconSize,
          height: iconSize,
        ),
        SizedBox(width: 8),
        Text(
          'Lv.$userLevel $nickname',
          style: TextStyle(
            fontSize: textSize,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
