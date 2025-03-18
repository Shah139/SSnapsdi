import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/post.dart';

class ProfileController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();
  var profile = {}.obs;
  var userPosts = <Post>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      await fetchProfile(user.id);
      await fetchUserPosts(user.id);
    }
  }

  Future<void> fetchProfile(String userId) async {
    isLoading.value = true;
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      profile.value = response;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load profile: $e');
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> fetchUserPosts(String userId) async {
    isLoading.value = true;
    try {
      final response = await _supabase
          .from('posts')
          .select('*, likes(id), comments(id)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      userPosts.assignAll(response.map<Post>((p) => Post.fromJson(p)).toList());
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch user posts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> uploadProfileImage() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;

    final String filePath = 'profiles/${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final File file = File(image.path);
    
    try {
      isLoading.value = true;
      await _supabase.storage.from('profiles').upload(
        filePath,
        file,
        fileOptions: const FileOptions(contentType: 'image/jpeg'),
      );
      return _supabase.storage.from('profiles').getPublicUrl(filePath);
    } catch (e) {
      Get.snackbar("Error", "Image upload failed: $e");
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleFollow(String userId) async {
  final user = _supabase.auth.currentUser;
  if (user == null) return;

  final existingFollow = await _supabase
      .from('follows')
      .select()
      .eq('follower_id', user.id)
      .eq('following_id', userId)
      .maybeSingle();

  if (existingFollow == null) {
    await _supabase.from('follows').insert({
      'follower_id': user.id,
      'following_id': userId,
    });
  } else {
    await _supabase.from('follows').delete().eq('id', existingFollow['id']);
  }
}

Future<bool> isFollowing(String userId) async {
  final user = _supabase.auth.currentUser;
  if (user == null) return false;

  final response = await _supabase
      .from('follows')
      .select()
      .eq('follower_id', user.id)
      .eq('following_id', userId)
      .maybeSingle();

  return response != null;
}



  Future<void> updateProfile(String name, String bio, String imageUrl) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      isLoading.value = true;
      await _supabase.from('profiles').upsert({
        'id': user.id,
        'name': name,
        'bio': bio,
        'profile_picture': imageUrl,
      });

      await fetchProfile(user.id);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e');
    } finally {
      isLoading.value = false;
    }
  }
}