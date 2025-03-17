class Post {
  final String id;
  final String userId;
  final String caption;
  final String imageUrl;
  final DateTime createdAt;
  final List<dynamic> likes; // Store likes (list of user IDs or objects)
  final List<dynamic> comments ; // Store comments (list of comment objects)

  Post({
    required this.id,
    required this.userId,
    required this.caption,
    required this.imageUrl,
    required this.createdAt,
    required this.likes,
    required this.comments,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? '', 
      userId: json['user_id'] ?? '', 
      caption: json['caption'] ?? '', 
      imageUrl: json['image_url'] != null && json['image_url'].isNotEmpty
          ? json['image_url']
          : 'https://unsplash.com/photos/young-asian-travel-woman-is-enjoying-with-beautiful-place-in-bangkok-thailand-_Fqoswmdmoo',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      likes: json['likes'] != null ? List<dynamic>.from(json['likes']) : [],
      comments: json['comments'] != null ? List<dynamic>.from(json['comments']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'caption': caption,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'likes': likes,
      'comments': comments,
    };
  }
}
