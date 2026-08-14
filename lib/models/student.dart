class Student {
  final String studentId;
  final String schoolId;
  final String classId; // e.g. "Grade 10-A"
  final String name;
  final String rollNumber;
  final String gender;
  final String fatherName;
  final String motherName;
  final String guardianContact;

  Student({
    required this.studentId,
    required this.schoolId,
    required this.classId,
    required this.name,
    required this.rollNumber,
    required this.gender,
    required this.fatherName,
    required this.motherName,
    required this.guardianContact,
  });

  factory Student.fromMap(Map<String, dynamic> map, String id) {
    String classVal = map['classId']?.toString() ??
        map['class']?.toString() ??
        map['grade']?.toString() ??
        map['standard']?.toString() ??
        map['section']?.toString() ??
        'Grade 10-A';
    if (map['division'] != null && !classVal.contains('-')) {
      classVal = "$classVal-${map['division']}";
    }

    String studentName = map['studentName']?.toString() ??
        map['name']?.toString() ??
        map['fullName']?.toString() ??
        map['displayName']?.toString() ??
        'Student';

    String roll = map['rollNo']?.toString() ??
        map['rollNumber']?.toString() ??
        map['roll_no']?.toString() ??
        map['roll']?.toString() ??
        id;

    String contact = map['guardianContact']?.toString() ??
        map['phone']?.toString() ??
        map['contact']?.toString() ??
        map['parentContact']?.toString() ??
        map['mobile']?.toString() ??
        '';

    String father = map['fatherName']?.toString() ??
        map['father']?.toString() ??
        map['father_name']?.toString() ??
        'N/A';

    String mother = map['motherName']?.toString() ??
        map['mother']?.toString() ??
        map['mother_name']?.toString() ??
        'N/A';

    return Student(
      studentId: id,
      schoolId: map['schoolId']?.toString() ?? map['school']?.toString() ?? 'school-greenwood-01',
      classId: classVal,
      name: studentName,
      rollNumber: roll,
      gender: map['gender']?.toString() ?? 'Other',
      fatherName: father,
      motherName: mother,
      guardianContact: contact,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'id': studentId,
      'schoolId': schoolId,
      'classId': classId,
      'class': classId,
      'grade': classId,
      'standard': classId,
      'name': name,
      'studentName': name,
      'fullName': name,
      'rollNumber': rollNumber,
      'rollNo': rollNumber,
      'roll_no': rollNumber,
      'gender': gender,
      'fatherName': fatherName,
      'father': fatherName,
      'father_name': fatherName,
      'motherName': motherName,
      'mother': motherName,
      'mother_name': motherName,
      'guardianContact': guardianContact,
      'phone': guardianContact,
      'parentContact': guardianContact,
      'contact': guardianContact,
    };
  }
}
