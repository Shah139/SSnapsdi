import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snapsdi/controllers/comment_controller.dart';
import '../controllers/post_controller.dart';
import '../controllers/profile_controller.dart';
import '../models/post.dart';
import '../views/comment_page.dart';
import '../views/profile_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../views/user_profile_page.dart';


class PostCard extends StatelessWidget {
  final Post post;
  final PostController postController = Get.find();
  final CommentController commentController = Get.put(CommentController());
  final RxBool isLiked = false.obs;
  final RxInt likesCount = 0.obs;
  // Store post author data
  final Rx<Map<String, dynamic>> postAuthor = Rx<Map<String, dynamic>>({});
  
  final isLoadingAuthor = true.obs;

  PostCard({required this.post}) {
    _fetchLikesCount();
    _fetchPostAuthor();
  }

  Future<void> _fetchLikesCount() async {
    final count = await postController.fetchLikes(post.id);
    likesCount.value = count;
    isLiked.value = await postController.isPostLiked(post.id);
  }

  Future<void> _fetchPostAuthor() async {
    isLoadingAuthor.value = true;
    try {
      // Fetch the profile of the post author
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', post.userId)
          .single();
      
      postAuthor.value = response;
    } catch (e) {
      print('Error fetching post author: $e');
      // Set defaults if we can't fetch the author
      postAuthor.value = {
        'name': 'User',
        'profile_picture': '',
        'id': post.userId
      };
    } finally {
      isLoadingAuthor.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final currentUser = Supabase.instance.client.auth.currentUser;

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
                Obx(() => isLoadingAuthor.value
                  ? CircularProgressIndicator()
                  : Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Navigate to the appropriate profile page
                          if (currentUser != null && postAuthor.value['id'] == currentUser.id) {
                            // It's the current user's post, go to their profile
                            Get.to(() => ProfilePage());
                          } else {
                            // It's another user's post, go to their profile
                            Get.to(() => UserProfilePage(userId: postAuthor.value['id']));
                          }
                        },
                        child: postAuthor.value['profile_picture'] != null && 
                              postAuthor.value['profile_picture'].toString().isNotEmpty
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(
                                postAuthor.value['profile_picture'],
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
                              // Navigate to the appropriate profile page
                              if (currentUser != null && postAuthor.value['id'] == currentUser.id) {
                                // It's the current user's post, go to their profile
                                Get.to(() => ProfilePage());
                              } else {
                                // It's another user's post, go to their profile
                                Get.to(() => UserProfilePage(userId: postAuthor.value['id']));
                              }
                            },
                            child: Text(
                              postAuthor.value['name'] ?? "User",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                )
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