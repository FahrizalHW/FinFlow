class UserModel {
  final int id;
  final String username;
  final String password;
  final String? profilePhoto;

  const UserModel({
    required this.id,
    required this.username,
    required this.password,
    this.profilePhoto,
  });

  UserModel copyWith({
    int? id,
    String? username,
    String? password,
    String? profilePhoto,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      profilePhoto: profilePhoto ?? this.profilePhoto,
    );
  }
}

