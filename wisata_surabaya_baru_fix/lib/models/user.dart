class User {
  final int id;
  final String username;
  final String email;
  final String? password; // Optional, only for register/update
  final String createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.password,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      password: json['password'],
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'created_at': createdAt,
    };
  }
}