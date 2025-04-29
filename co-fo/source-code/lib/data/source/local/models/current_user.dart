import 'dart:convert';

CurrentUser currentUserFromJson(String str) =>
    CurrentUser.fromJson(json.decode(str));

String currentUserToJson(CurrentUser data) => json.encode(data.toJson());

class CurrentUser {
  final String userId;
  final String userType;
  final String bio;
  final List<String> skills;
  final dynamic avatar;
  final String title;
  final String username;

  CurrentUser({
    required this.userId,
    required this.userType,
    required this.bio,
    required this.skills,
    required this.avatar,
    required this.title,
    required this.username,
  });

  factory CurrentUser.fromJson(Map<String, dynamic> json) => CurrentUser(
    userId: json["user_id"],
    userType: json["user_type"],
    bio: json["bio"],
    skills:
        json['skills'] is String
            ? List<String>.from(jsonDecode(json['skills']))
            : List<String>.from(json['skills']),
    avatar: json["avatar"],
    title: json["title"],
    username: json["username"],
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "user_type": userType,
    "bio": bio,
    "skills": jsonEncode(skills),
    "avatar": avatar,
    "title": title,
    "username": username,
  };
}
