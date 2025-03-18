import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/profile_controller.dart';
import '../models/post.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;
  
  const UserProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final ProfileController profileController = Get.put(ProfileController());
  final RxBool isLoading = true.obs;
  final Rx<Map<String, dynamic>> userData = Rx<Map<String, dynamic>>({});
  final RxList<Post> userPosts = <Post>[].obs;
  final RxBool isFollowing = false.obs;
  
  @override
  void initState() {
    super.initState();
    loadUserData();
  }
  
  Future<void> loadUserData() async {
    isLoading.value = true;
    try {
      // Fetch user profile
      final profileResponse = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', widget.userId)
          .single();
      
      userData.value = profileResponse;
      
      // Fetch user posts
      final postsResponse = await Supabase.instance.client
          .from('posts')
          .select('*, likes(id), comments(id)')
          .eq('user_id', widget.userId)
          .order('created_at', ascending: false);
      
      userPosts.assignAll(postsResponse.map<Post>((p) => Post.fromJson(p)).toList());
      
      // Check if current user is following this profile
      isFollowing.value = await profileController.isFollowing(widget.userId);
      
    } catch (e) {
      Get.snackbar('Error', 'Failed to load user data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: Obx(() {
        if (isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        
        return RefreshIndicator(
          onRefresh: () => loadUserData(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          userData.value['profile_picture'] ?? 
                          "https://via.placeholder.com/150"),
                        radius: 50,
                      ),
                      SizedBox(height: 16),
                      Text(
                        userData.value['name'] ?? "No Name",
                        style: TextStyle(
                          fontSize: 24, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          await profileController.toggleFollow(widget.userId);
                          isFollowing.value = await profileController.isFollowing(widget.userId);
                        },
                        child: Obx(() => Text(isFollowing.value ? "Unfollow" : "Follow")),
                      ),
                      SizedBox(height: 8),
                      Text(
                        userData.value['bio'] ?? "No Bio",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatColumn(userPosts.length.toString(), "Posts"),
                        ],
                      ),
                      SizedBox(height: 16),
                      Divider(),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            "Posts",
                            style: TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Grid of user posts
              userPosts.isEmpty ?
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Text(
                      "No posts yet",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ),
              ) :
              SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final Post post = userPosts[index];
                    return GestureDetector(
                      onTap: () => _showPostDetail(context, post),
                      child: Hero(
                        tag: 'post-${post.id}',
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(post.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: userPosts.length,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatColumn(String count, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  void _showPostDetail(BuildContext context, Post post) {
    Get.to(() => PostDetailPage(post: post));
  }
}

// Make sure this class exists in your project
class PostDetailPage extends StatelessWidget {
  final Post post;
  
  const PostDetailPage({Key? key, required this.post}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Post')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'post-${post.id}',
              child: Image.network(
                post.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.caption,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.favorite, color: Colors.red),
                      SizedBox(width: 4),
                      Text('${post.likes.length} likes'),
                      SizedBox(width: 16),
                      Icon(Icons.comment, color: Colors.blue),
                      SizedBox(width: 4),
                      Text('${post.comments.length} comments'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}