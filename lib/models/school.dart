class School {
  final String schoolId;
  final String name;
  final String municipalityId;
  final String municipalityName;
  final String address;
  final String contactInfo;

  School({
    required this.schoolId,
    required this.name,
    required this.municipalityId,
    this.municipalityName = "Chennai Municipal Corporation",
    required this.address,
    required this.contactInfo,
  });

  factory School.fromMap(Map<String, dynamic> map, String id) {
    return School(
      schoolId: id,
      name: map['name']?.toString() ?? map['schoolName']?.toString() ?? map['school']?.toString() ?? 'St. Xavier Model School',
      municipalityId: map['municipalityId']?.toString() ?? 'muni-chennai-corp',
      municipalityName: map['municipalityName']?.toString() ?? 'Chennai Municipal Corporation',
      address: map['address']?.toString() ?? '104 Cathedral Road, Zone 5, Chennai',
      contactInfo: map['contactInfo']?.toString() ?? '+91 44 2827 0011 | office@stxavier.edu.in',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'schoolId': schoolId,
      'id': schoolId,
      'name': name,
      'schoolName': name,
      'municipalityId': municipalityId,
      'municipalityName': municipalityName,
      'address': address,
      'contactInfo': contactInfo,
    };
  }
}
