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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Social Feed'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // "What's on your mind" button
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            child: GestureDetector(
              onTap: () => _showPostCreationDialog(context),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.green[400],
                    child: Icon(Icons.travel_explore_outlined, color: Colors.white),
                  ),
                  SizedBox(width: 12),
                  Text(
                    "What's on your mind?",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
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
                  ? Center(child: Text("No posts yet"))
                  : ListView.builder(
                      itemCount: postController.posts.length,
                      itemBuilder: (context, index) {
                        final post = postController.posts[index];
                        return PostCard(post: post);
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
        title: Text('Create Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: captionController,
              decoration: InputDecoration(
                hintText: "What's on your mind?",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                if (captionController.text.isNotEmpty) {
                  Navigator.pop(context);
                  await postController.addPost(captionController.text);
                } else {
                  Get.snackbar(
                    "Error",
                    "Please enter a caption",
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              icon: Icon(Icons.add_photo_alternate),
              label: Text('Add Photo & Post'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
