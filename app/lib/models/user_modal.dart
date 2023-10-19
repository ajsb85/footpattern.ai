class UserModel {
  final String id;
  final String email;
  final String name;
  final int? department; // Renamed from 'departement'
  final String employeeId;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.department, // Renamed from 'departement'
    required this.employeeId,
  });

  // GraphQL serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'department': department, // Renamed from 'departement'
      'employee_id': employeeId,
    };
  }

  // Factory method to deserialize data from GraphQL
  factory UserModel.fromJson(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'],
      email: data['email'],
      name: data['name'],
      department: data['department'], // Renamed from 'departement'
      employeeId: data['employee_id'],
    );
  }
}
