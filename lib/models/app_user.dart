class AppUser {
  final String userId;
  final String role; // "teacher" | "headmaster" | "municipal_leader"
  final String schoolId;
  final String? municipalityId;
  final String name;
  final String email;
  final String? classAssigned;

  AppUser({
    required this.userId,
    required this.role,
    required this.schoolId,
    this.municipalityId,
    required this.name,
    required this.email,
    this.classAssigned,
  });

  bool get isHeadmaster => role == 'headmaster';
  bool get isTeacher => role == 'teacher';
  bool get isMunicipalLeader => role == 'municipal_leader';

  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    return AppUser(
      userId: id,
      role: map['role'] ?? 'headmaster',
      schoolId: map['schoolId'] ?? '',
      municipalityId: map['municipalityId'],
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      classAssigned: map['classAssigned'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'schoolId': schoolId,
      'municipalityId': municipalityId,
      'name': name,
      'email': email,
      'classAssigned': classAssigned,
    };
  }
}
