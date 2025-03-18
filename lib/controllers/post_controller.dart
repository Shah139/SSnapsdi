import 'package:get/get.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post.dart';
import 'package:image_picker/image_picker.dart';

class PostController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  var posts = <Post>[].obs;
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    fetchPosts();

    _supabase.from('posts').stream(primaryKey: ['id']).listen((List<Map<String, dynamic>> event) {
      // Sort by created_at in descending order (newest first)
      event.sort((a, b) => DateTime.parse(b['created_at']).compareTo(DateTime.parse(a['created_at'])));
      posts.value = event.map((post) => Post.fromJson(post)).toList();
    });
  }

  // Function to refresh posts
  Future<void> refreshPosts() async {
    await fetchPosts();

  }

  Future<void> fetchPosts() async {
    try {
      final response = await _supabase
          .from('posts')
          .select('*, likes(id), comments(id)')
          .order('created_at', ascending: false);  // Explicitly order by created_at descending

      posts.assignAll(response.map<Post>((p) => Post.fromJson(p)).toList());
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch posts: $e");
    }
  }

  Future<String?> uploadImage() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;

    final String filePath = 'posts/${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final File file = File(image.path);
    
    try {
      await _supabase.storage.from('posts').upload(
        filePath,
        file,
        fileOptions: const FileOptions(contentType: 'image/jpeg'),
      );
      return _supabase.storage.from('posts').getPublicUrl(filePath);
    } catch (e) {
      Get.snackbar("Error", "Image upload failed: $e");
      return null;
    }
  }

  Future<void> addPost(String caption) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final String? imageUrl = await uploadImage();
      if (imageUrl == null) return;

      final response = await _supabase.from('posts').insert({
        'user_id': user.id,
        'caption': caption,
        'image_url': imageUrl,
        'created_at': DateTime.now().toIso8601String(),
      }).select().maybeSingle();

      if (response != null) {
        posts.insert(0, Post.fromJson(response));  // Insert at the beginning of the list
        await fetchPosts();  // Refresh the posts to ensure correct order
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to add post: $e");
    }
  }

  Future<int> fetchLikes(String postId) async {
    final response = await _supabase
        .from('likes')
        .select()
        .eq('post_id', postId);
    return response.length;
  }

  Future<void> likePost(String postId) async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      final existingLike = await _supabase
          .from('likes')
          .select()
          .eq('post_id', postId)
          .eq('user_id', user.id)
          .maybeSingle();

      if (existingLike == null) {
        await _supabase.from('likes').insert({'post_id': postId, 'user_id': user.id});
      } else {
        await _supabase.from('likes').delete().eq('id', existingLike['id']);
      }
    }
  }

  Future<bool> isPostLiked(String postId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    final existingLike = await _supabase
      .from('likes')
      .select()
      .eq('post_id', postId)
      .eq('user_id', user.id)
      .maybeSingle();

    return existingLike != null;
  }

  //all the comment functions
  Future<void> addComment(String postId, String content) async {
    final user = _supabase.auth.currentUser;
    if (user != null && content.trim().isNotEmpty) {
      await _supabase.from('comments').insert({
        'post_id': postId,
        'user_id': user.id,
        'content': content,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<List<Map<String, dynamic>>> fetchComments(String postId) async {
    final response = await _supabase
        .from('comments')
        .select('*')
        .eq('post_id', postId)
        .order('created_at', ascending: true);
    return response;
  }
}