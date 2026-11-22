import '../domain/user_model.dart';

// Layer 3 (data). For now the users come from a list.
// Later this file will call the API instead.
class AuthRepository {
  final List<Map<String, String>> _users = [
    {
      'name': 'Khalid Mehmood',
      'email': 'datacell@biit.edu.pk',
      'password': '123456',
      'role': 'datacell',
    },
    {
      'name': 'Mr. Amir Rasheed',
      'email': 'faculty@biit.edu.pk',
      'password': '123456',
      'role': 'faculty',
    },
    {
      'name': 'Director',
      'email': 'director@biit.edu.pk',
      'password': '123456',
      'role': 'director',
    },
    {
      'name': 'Dr. Munir Ahmad',
      'email': 'hod@biit.edu.pk',
      'password': '123456',
      'role': 'hod',
    },
  ];

  Future<UserModel?> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    for (int i = 0; i < _users.length; i++) {
      Map<String, String> u = _users[i];
      if (u['email'] == email && u['password'] == password) {
        return UserModel(
          name: u['name']!,
          email: u['email']!,
          role: u['role']!,
          token: 'dummy-token-${u['role']}',
        );
      }
    }
    return null;
  }
}
