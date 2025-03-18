import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/post_controller.dart';
import '../models/post.dart';
import '../views/comment_page.dart';
import '../elements/post_card.dart';

class HomePage extends StatelessWidget {
  final PostController postController = Get.put(PostController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Social Feed',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: Column(
        children: [
          // "What's on your mind" card
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: GestureDetector(
              onTap: () => _showPostCreationDialog(context),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Color.fromARGB(255, 162, 182, 225),
                    child: Icon(Icons.face_2, color: Colors.white),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        "What's on your mind?",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Posts List
          Expanded(
            child: Obx(() {
              return postController.posts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.article_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            "No posts yet",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Be the first to share something!",
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(vertical: 8),
                      itemCount: postController.posts.length,
                      itemBuilder: (context, index) {
                        final post = postController.posts[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: 16, left: 16, right: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: PostCard(post: post),
                        );
                      },
                    );
            }),
          ),
        ],
      ),
    );
  }

  void _showPostCreationDialog(BuildContext context) {
    final TextEditingController captionController = TextEditingController();
    final PostController postController = Get.find();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.create, color: Colors.green[400]),
            SizedBox(width: 8),
            Text('Create Post'),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: captionController,
              decoration: InputDecoration(
                hintText: "What's on your mind?",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green[400]!, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: 4,
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (captionController.text.isNotEmpty) {
                        Navigator.pop(context);
                        await postController.addPost(captionController.text);
                      } else {
                        Get.snackbar(
                          "Error",
                          "Please enter a caption",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red[100],
                          colorText: Colors.red[800],
                          margin: EdgeInsets.all(16),
                          borderRadius: 12,
                          icon: Icon(Icons.error_outline, color: Colors.red[800]),
                        );
                      }
                    },
                    icon: Icon(Icons.add_photo_alternate),
                    label: Text('Add Photo & Post'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}