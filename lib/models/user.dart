class User {
  final String id;
  final String username;
  final String password;
  final String email;
  final String role;
  final String? faceImagePath;
  final List<double>? faceEmbeddings;
  final String? faceName;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.email,
    required this.role,
    this.faceImagePath,
    this.faceEmbeddings,
    this.faceName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      password: json['password'],
      email: json['email'],
      role: json['role'],
      faceImagePath: json['faceImagePath'],
      faceEmbeddings: json['faceEmbeddings'] != null
          ? List<double>.from(json['faceEmbeddings'])
          : null,
      faceName: json['faceName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'email': email,
      'role': role,
      'faceImagePath': faceImagePath,
      'faceEmbeddings': faceEmbeddings,
      'faceName': faceName,
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? password,
    String? email,
    String? role,
    String? faceImagePath,
    List<double>? faceEmbeddings,
    String? faceName,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      email: email ?? this.email,
      role: role ?? this.role,
      faceImagePath: faceImagePath ?? this.faceImagePath,
      faceEmbeddings: faceEmbeddings ?? this.faceEmbeddings,
      faceName: faceName ?? this.faceName,
    );
  }
}
