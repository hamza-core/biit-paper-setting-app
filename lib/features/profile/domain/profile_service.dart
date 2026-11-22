import '../data/profile_repository.dart';
import 'notification_model.dart';
import 'profile_model.dart';

// Layer 2 (domain). Rules for the profile and notification screens.
class ProfileService {
  final ProfileRepository _repository = ProfileRepository();

  Future<ProfileModel> getProfile(String email) {
    return _repository.getProfile(email);
  }

  // Throws a message if some field is empty.
  Future<void> saveProfile(ProfileModel profile) async {
    if (profile.name.trim().isEmpty) throw 'Name cannot be empty';
    if (profile.email.trim().isEmpty) throw 'Email cannot be empty';
    await _repository.saveProfile(profile);
  }

  Future<List<NotificationModel>> getNotifications(String role) {
    return _repository.getNotifications(role);
  }

  String profileTitle(String role) {
    if (role == 'hod') return 'HOD Profile';
    if (role == 'director') return 'Director Profile';
    if (role == 'faculty') return 'Faculty Profile';
    return 'Profile';
  }

  String notificationsLabel(String role) {
    if (role == 'faculty' || role == 'director') {
      return 'Notifications & Reminders';
    }
    return 'Notifications';
  }
}
