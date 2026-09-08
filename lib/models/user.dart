class User {
  final int id;
  final String username, firstName, lastName, email, image;
  User.fromJson(Map<String, dynamic> j)
    : id = j['id'],
      username = j['username'] ?? '',
      firstName = j['firstName'] ?? '',
      lastName = j['lastName'] ?? '',
      email = j['email'] ?? '',
      image = j['image'] ?? '';
  String get name => '$firstName $lastName'.trim();
  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'image': image,
  };
}
