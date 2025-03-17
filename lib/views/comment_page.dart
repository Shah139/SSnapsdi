import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/post_controller.dart';

class CommentPage extends StatefulWidget {
  final String postId;
  CommentPage({required this.postId});

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final PostController postController = Get.find();
  final TextEditingController commentController = TextEditingController();
  RxList<Map<String, dynamic>> comments = <Map<String, dynamic>>[].obs;

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  Future<void> fetchComments() async {
    final fetchedComments = await postController.fetchComments(widget.postId);
    comments.assignAll(fetchedComments);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Comments")),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (comments.isEmpty) {
                return Center(child: Text("No comments yet"));
              }
              return ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return ListTile(
                    title: Text(comment['content']),
                    subtitle: Text("User: ${comment['user_id']}"),
                  );
                },
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: InputDecoration(labelText: "Write a comment..."),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () async {
                    if (commentController.text.isNotEmpty) {
                      await postController.addComment(widget.postId, commentController.text);
                      commentController.clear();
                      fetchComments();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
