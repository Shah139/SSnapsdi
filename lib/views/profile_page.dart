import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../models/post.dart';

class ProfilePage extends StatelessWidget {
  final ProfileController profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _showEditProfileDialog(context),
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Implement logout functionality here
              // Supabase.instance.client.auth.signOut();
              // Get.offAll(() => LoginPage());
            },
          ),
        ],
      ),
      body: Obx(() {
        if (profileController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        
        return RefreshIndicator(
          onRefresh: () => profileController.loadUserData(),
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
                          profileController.profile['profile_picture'] ?? 
                          "https://via.placeholder.com/150"),
                        radius: 50,
                      ),
                      SizedBox(height: 16),
                      Text(
                        profileController.profile['name'] ?? "No Name",
                        style: TextStyle(
                          fontSize: 24, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        profileController.profile['bio'] ?? "No Bio",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatColumn(profileController.userPosts.length.toString(), "Posts"),
                          _buildStatColumn("0", "Followers"),
                          _buildStatColumn("0", "Following"),
                        ],
                      ),
                      SizedBox(height: 16),
                      Divider(),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            "My Posts",
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
              profileController.userPosts.isEmpty ?
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
                    final Post post = profileController.userPosts[index];
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
                  childCount: profileController.userPosts.length,
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
void _showEditProfileDialog(BuildContext context) {
  final nameController = TextEditingController(
    text: profileController.profile['name']?.toString() ?? ''
  );
  final bioController = TextEditingController(
    text: profileController.profile['bio']?.toString() ?? ''
  );
  
  // Create an RxString correctly
  final profileImageUrl = RxString(profileController.profile['profile_picture']?.toString() ?? '');

  Get.dialog(
    AlertDialog(
      title: Text('Edit Profile'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() => CircleAvatar(
              radius: 40,
              backgroundImage: profileImageUrl.value.isNotEmpty
                  ? NetworkImage(profileImageUrl.value)
                  : null,
              child: profileImageUrl.value.isEmpty
                  ? Icon(Icons.person, size: 40)
                  : null,
            )),
            SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: bioController,
              decoration: InputDecoration(labelText: 'Bio'),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('Update Profile Picture'),
              onPressed: () async {
                // Call the new upload method and update the local URL if successful
                final newImageUrl = await profileController.uploadProfileImage();
                if (newImageUrl != null) {
                  profileImageUrl.value = newImageUrl;
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Get.back(),
        ),
        TextButton(
          child: Text('Save'),
          onPressed: () {
            profileController.updateProfile(
              nameController.text,
              bioController.text,
              profileImageUrl.value,
            );
            Get.back();
          },
        ),
      ],
    ),
  );
}
  

  void _showPostDetail(BuildContext context, Post post) {
    Get.to(() => PostDetailPage(post: post));
  }
}

// You'll need to create this page or use an existing one
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