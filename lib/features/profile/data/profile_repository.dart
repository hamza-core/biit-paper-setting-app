import '../domain/notification_model.dart';
import '../domain/profile_model.dart';

// Layer 3 (data). Profiles and notifications come from lists for now.
// Later these methods will call the API.
class ProfileRepository {
  static final List<ProfileModel> _profiles = [
    ProfileModel(
      email: 'datacell@biit.edu.pk',
      name: 'Khalid Mehmood',
      phone: '+92 300 1234567',
      department: 'BIIT Administration',
      designation: 'Assistant Director Administration',
      subtitle: 'Assistant Director Administration',
      organization: 'BIIT Administration',
      avatar: 'assets/images/avatar_datacell.png',
    ),
    ProfileModel(
      email: 'faculty@biit.edu.pk',
      name: 'Mr. Amir Rasheed',
      phone: '+92 300 1234567',
      department: 'CS',
      designation: 'Assistant Professor',
      subtitle: 'Faculty · CS Department',
      organization: 'BIIT',
      avatar: 'assets/images/avatar_faculty.png',
    ),
    ProfileModel(
      email: 'director@biit.edu.pk',
      name: 'Director',
      phone: '+92 300 1234567',
      department: 'BIIT',
      designation: 'Director',
      subtitle: 'Director',
      organization: 'BIIT',
      avatar: 'assets/images/avatar_director.jpg',
    ),
    ProfileModel(
      email: 'hod@biit.edu.pk',
      name: 'Dr. Munir',
      phone: '+92 300 1234567',
      department: 'HOD BSCS',
      designation: 'Assistant Director',
      subtitle: 'Deputy Director BIIT',
      organization: 'HOD BSCS',
      avatar: 'assets/images/avatar_hod.jpg',
    ),
  ];

  final List<NotificationModel> _facultyNotifications = [
    NotificationModel(
      title: 'Assigned Paper',
      lines: [
        'Fall 2026 · Final',
        'Compiler Construction (CS-301)',
        'Mr. Amir Rasheed',
        'Deadline: 20 Oct 2026',
      ],
      time: 'New',
      isToday: true,
      isUnread: true,
    ),
    NotificationModel(
      title: 'Role Handover Ending',
      lines: ['Administrative'],
      time: 'Oct 23',
      isToday: false,
      isUnread: false,
    ),
  ];

  final List<NotificationModel> _otherNotifications = [
    NotificationModel(
      title: 'New Paper Submitted',
      lines: ['Compiler Construction · CC-401'],
      time: '2h ago',
      isToday: true,
      isUnread: true,
    ),
    NotificationModel(
      title: 'Role Handover Ending',
      lines: ['Administrative'],
      time: 'Oct 23',
      isToday: false,
      isUnread: false,
    ),
  ];

  Future<ProfileModel> getProfile(String email) async {
    await Future.delayed(const Duration(milliseconds: 300));
    for (int i = 0; i < _profiles.length; i++) {
      if (_profiles[i].email == email) {
        return _profiles[i];
      }
    }
    throw 'Profile not found';
  }

  Future<void> saveProfile(ProfileModel profile) async {
    await Future.delayed(const Duration(milliseconds: 300));
    for (int i = 0; i < _profiles.length; i++) {
      if (_profiles[i].email == profile.email) {
        _profiles[i] = profile;
      }
    }
  }

  Future<List<NotificationModel>> getNotifications(String role) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (role == 'faculty') {
      return _facultyNotifications;
    }
    return _otherNotifications;
  }
}
