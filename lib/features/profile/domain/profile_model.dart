class ProfileModel {
  final String email;
  final String name;
  final String phone;
  final String department;
  final String designation;
  final String subtitle; // line under the name on the profile card
  final String organization;
  final String avatar; // asset path

  ProfileModel({
    required this.email,
    required this.name,
    required this.phone,
    required this.department,
    required this.designation,
    required this.subtitle,
    required this.organization,
    required this.avatar,
  });
}
