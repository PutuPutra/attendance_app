class User {
  final String id;
  final String username;
  final String password;
  final String email;
  final String role;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      password: json['password'],
      email: json['email'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'email': email,
      'role': role,
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? password,
    String? email,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }
}
