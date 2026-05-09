class AdminModel {
  final String id;
  final String name;
  final String email;
  final String employeeId;
  final String department;
  final String photoUrl;
  final DateTime? createdAt;

  const AdminModel({
    required this.id,
    required this.name,
    required this.email,
    required this.employeeId,
    required this.department,
    required this.photoUrl,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'employeeId': employeeId,
      'department': department,
      'photoUrl': photoUrl,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory AdminModel.fromMap(Map<String, dynamic> map) {
    return AdminModel(
      id: map['_id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      employeeId: map['employeeId'] ?? '',
      department: map['department'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
    );
  }
}
