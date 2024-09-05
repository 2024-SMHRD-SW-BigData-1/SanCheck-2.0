import 'dart:io';
import 'package:flutter/material.dart';
import 'community_post.dart';

class Community extends StatefulWidget {
  @override
  _CommunityState createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  List<Map<String, dynamic>> _posts = []; // 게시물 리스트
  List<TextEditingController> _commentControllers = []; // 각 게시물에 대한 댓글 입력 컨트롤러 리스트
  int _selectedCategory = 0; // 선택된 카테고리 상태

  void _showPostDialog(BuildContext context) async {
    final newPost = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false, // 바깥쪽 클릭 시 닫히지 않게
      builder: (context) => Dialog(
        backgroundColor: Colors.white, // 모달창 배경색을 하얀색으로 설정
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: CommunityPost(category: _selectedCategory,),
      ),
    );

    // 게시물이 추가된 경우 리스트에 추가
    if (newPost != null) {
      setState(() {
        newPost['comments'] = [];
        _posts.insert(0, newPost);
        _commentControllers.insert(0, TextEditingController());
      });
    }
  }


  // 댓글 추가 함수
  void _addComment(int postIndex) {
    // 유효한 인덱스인지 확인
    if (postIndex >= 0 && postIndex < _commentControllers.length) {
      final commentText = _commentControllers[postIndex].text.trim();
      if (commentText.isNotEmpty) {
        setState(() {
          _posts[postIndex]['comments'].add({
            'name': '사용자',
            'comment': commentText,
          });
          _commentControllers[postIndex].clear(); // 입력창 비우기
        });
      }
    }
  }

  // 게시물 삭제 함수
  void _deletePost(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // 배경색 하얀색 설정
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // 둥근 모서리 설정
          ),
          title: Center(
            child: Text(
              '게시물 삭제',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black, // 글자색 검정색 설정
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
                color: Colors.black87, // 글자색 검정색 설정
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 대화상자 닫기
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // 초록색으로 설정
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
                child: Text(
                  '취소',
                  style: TextStyle(color: Colors.white), // 글자색 흰색 설정
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
                  Navigator.of(context).pop(); // 대화상자 닫기
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // 빨간색으로 설정
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
                child: Text(
                  '삭제',
                  style: TextStyle(color: Colors.white), // 글자색 흰색 설정
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // 선택한 카테고리의 게시물만 반환하는 함수
  List<Map<String, dynamic>> _getFilteredPosts() {
    return _posts.where((post) {
      return post['category'] == _selectedCategory;
    }).toList();
  }

  @override
  void dispose() {
    // 모든 댓글 컨트롤러 해제
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
                    // 카테고리 선택 버튼
                    Row(
                      children: [
                        _buildCategoryButton(0),
                        SizedBox(width: 10),
                        _buildCategoryButton(1),
                      ],
                    ),
                    GestureDetector(
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
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _getFilteredPosts().length,
                itemBuilder: (context, index) {
                  final post = _getFilteredPosts()[index];
                  final comments = post['comments'] ?? [];
                  final commentController = (index < _commentControllers.length)
                      ? _commentControllers[index]
                      : TextEditingController(); // 안전하게 접근

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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${post['date']}\n',
                                    style: TextStyle(
                                      color: Color(0xFF1E1E1E),
                                      fontSize: 16,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '👶🏻 등린이 팜하니',
                                    style: TextStyle(
                                      color: Color(0xFF1E1E1E),
                                      fontSize: 16,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deletePost(index), // 삭제 버튼 클릭 시 호출
                            ),
                          ],
                        ),
                        if (post['images'] != null && post['images'].isNotEmpty)
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            height: 150,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: post['images'].map<Widget>((imagePath) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(imagePath),
                                      width: 150,
                                      height: 150,
                                      fit: BoxFit.cover,
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
                        if (post['location'] != null && post['location']!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.location_on, size: 16, color: Colors.grey),
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
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            children: comments.map<Widget>((comment) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundImage: NetworkImage(
                                          'https://via.placeholder.com/32x32'),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            comment['name'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            comment['comment'],
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
                        // 댓글 입력창
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
            ),
          ],
        ),
      ),
    );
  }

  // 카테고리 버튼 생성 함수
  Widget _buildCategoryButton(int category) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedCategory == category ? Colors.green : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        side: BorderSide(color: Colors.green, width: 1),
      ),
      child: Text(
        category==0?'실시간 게시물':'등산기록',
        style: TextStyle(
          color: _selectedCategory == category ? Colors.white : Colors.green,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}