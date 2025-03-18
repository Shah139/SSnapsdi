import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snapsdi/controllers/comment_controller.dart';
import '../controllers/post_controller.dart';
import '../controllers/profile_controller.dart';
import '../models/post.dart';
import '../views/comment_page.dart';
import '../views/profile_page.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final PostController postController = Get.find();
  final CommentController commentController = Get.put(CommentController());
  final ProfileController profileController = Get.put(ProfileController());
  final RxBool isLiked = false.obs;
  final RxInt likesCount = 0.obs;

  PostCard({required this.post}) {
    _fetchLikesCount();
  }

  Future<void> _fetchLikesCount() async {
    final count = await postController.fetchLikes(post.id);
    likesCount.value = count;
    isLiked.value = await postController.isPostLiked(post.id);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!, width: 0.5),
          bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Obx(() => Row(
  children: [
    GestureDetector(
      onTap: () => Get.to(() => ProfilePage()),
      child: profileController.profile['profile_picture'] != null && 
             profileController.profile['profile_picture'].toString().isNotEmpty
        ? CircleAvatar(
            backgroundImage: NetworkImage(
              profileController.profile['profile_picture'],
            ),
            radius: 20,
          )
        : CircleAvatar(
            backgroundColor: Colors.grey[400],
            child: Icon(Icons.person, color: Colors.white),
            radius: 20,
          ),
    ),
    SizedBox(width: 4),
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton(
          onPressed: () {
            Get.to(() => ProfilePage());
          },
          child: Text(
            profileController.profile['name'] ?? "user",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
      ],
    ),
  ],
))
              ],
            ),
          ),

          if (post.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              child: Text(post.caption),
            ),

          Container(
            width: width,
            height: width,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(post.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Obx(() => Text("${likesCount.value} Likes", style: TextStyle(color: Colors.grey[700]))),
                    SizedBox(width: 16),
                   // Text("${post.comments.length} Comments", style: TextStyle(color: Colors.grey[700])),
                  ],
                ),
              ],
            ),
          ),

          Divider(height: 0.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Obx(() => TextButton.icon(
                    onPressed: () async {
                      await postController.likePost(post.id);
                      _fetchLikesCount();
                    },
                    icon: Icon(
                      isLiked.value ? Icons.favorite : Icons.favorite_border,
                      color: isLiked.value ? Colors.red : Colors.grey[700],
                    ),
                    label: Text("Like", style: TextStyle(color: isLiked.value ? Colors.red : Colors.grey[700])),
                  )),
              TextButton.icon(
                onPressed: () {
                  Get.to(() => CommentPage(postId: post.id));
                },
                icon: Icon(Icons.comment_outlined, color: Colors.grey[700]),
                label: Text("Comments", style: TextStyle(color: Colors.grey[700])),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
