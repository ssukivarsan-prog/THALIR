class TeacherProfile {
  final String id;
  final String name;
  final String email;
  final String schoolName;
  final List<String> subjects;
  final List<String> assignedClasses;
  String activeClass;

  TeacherProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.schoolName,
    required this.subjects,
    required this.assignedClasses,
    required this.activeClass,
  });
}
