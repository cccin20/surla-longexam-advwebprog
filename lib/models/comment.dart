class Comment {
  final int id, postId;
  final String body, name;
  Comment.fromJson(Map<String, dynamic> j)
    : id = j['id'] ?? 0,
      postId = j['postId'],
      body = j['body'] ?? '',
      name = j['user']?['fullName'] ?? j['user']?['username'] ?? 'User';
  Map<String, dynamic> toJson() => {
    'id': id,
    'postId': postId,
    'body': body,
    'user': {'fullName': name},
  };
}
