// A logged in user. Role is one of: datacell, faculty, director, hod.
class UserModel {
  final String name;
  final String email;
  final String role;
  final String token;

  UserModel({
    required this.name,
    required this.email,
    required this.role,
    required this.token,
  });
}
