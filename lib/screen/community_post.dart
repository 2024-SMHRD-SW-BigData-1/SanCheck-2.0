import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class CommunityPost extends StatefulWidget {
  final int category;

  CommunityPost({required this.category});

  @override
  _CommunityPostState createState() => _CommunityPostState();
}

class _CommunityPostState extends State<CommunityPost> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  // 이미지 선택 함수
  Future<void> _pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null && images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  // 게시물 업로드 함수
  void _postContent() {
    // 게시물 데이터를 전달하고 팝업 닫기
    final post = {
      'date': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      'content': _contentController.text,
      'images': _selectedImages.map((img) => img.path).toList(),
      'location': _locationController.text,
      'category': widget.category, // 카테고리 기본값 설정
    };
    Navigator.pop(context, post); // Community 페이지로 데이터 전달
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '새 게시물 작성하기',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context); // 팝업 닫기
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            // 선택한 이미지들 표시
            if (_selectedImages.isNotEmpty)
              Container(
                margin: EdgeInsets.only(bottom: 16),
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(_selectedImages[index].path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 5,
                            right: 5,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImages.removeAt(index);
                                });
                              },
                              child: Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            TextField(
              controller: _contentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '문구 입력...',
                border: InputBorder.none,
              ),
              style: TextStyle(fontSize: 16),
            ),
            Divider(),
            // 위치 선택
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: '위치 추가...',
                prefixIcon: Icon(Icons.location_on, color: Colors.grey),
                border: InputBorder.none,
              ),
              style: TextStyle(fontSize: 16),
            ),
            Divider(),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImages,
                  icon: Icon(Icons.photo, color: Colors.black),
                  label: Text(
                    '이미지 추가',
                    style: TextStyle(color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ).copyWith(
                    overlayColor:
                    MaterialStateProperty.all<Color>(Colors.grey.shade300),
                  ),
                ),
                ElevatedButton(
                  onPressed: _isUploading ? null : _postContent, // 게시 버튼
                  child: _isUploading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('게시', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isUploading ? Colors.grey : Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}