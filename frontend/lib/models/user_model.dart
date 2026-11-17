class UserModel {
  final int id;
  final String username;
  final String? profilePhoto;

  const UserModel({required this.id, required this.username, this.profilePhoto});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id_user'] as int,
      username: json['username'] as String,
      profilePhoto: json['foto_profil'] as String?,
    );
  }

  UserModel copyWith({String? username, String? profilePhoto}) {
    return UserModel(
      id: id,
      username: username ?? this.username,
      profilePhoto: profilePhoto ?? this.profilePhoto,
    );
  }
}