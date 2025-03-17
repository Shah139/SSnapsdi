class Comment {
  final String id;
  final String postId;
  final String userId;
  final String commentText;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.commentText,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      postId: json['post_id'],
      userId: json['user_id'],
      commentText: json['comment_text'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
