import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/comment.dart';

class CommentController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  var comments = <Comment>[].obs;

  Future<void> fetchComments(String postId) async {
    final response = await _supabase
        .from('comments')
        .select()
        .eq('post_id', postId)
        .order('created_at', ascending: false);

    comments.value = response.map((c) => Comment.fromJson(c)).toList();
  }

  Future<void> addComment(String postId, String text) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase.from('comments').insert({
      'post_id': postId,
      'user_id': user.id,
      'comment_text': text,
    });

    fetchComments(postId);
  }
  
}
