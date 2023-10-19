class EmployeeModel {
  final String id;
  final String name;
  final String email;
  final String numero;
  final bool admin;
  // int? department;
  EmployeeModel(
      {required this.id,
      required this.name,
      required this.email,
      required this.numero,
      required this.admin
      // this.department,
      });

  // GraphQL serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'numero': numero,
      'Admin': admin

      // 'department': department,
    };
  }

  // Factory method to deserialize data from GraphQL
  factory EmployeeModel.fromJson(Map<String, dynamic> data) {
    return EmployeeModel(
        id: data['id'],
        name: data['name'],
        email: data['email'],
        numero: data['numero'],
        admin: data['Admin']
        // department:
        //     data['department'],
        );
  }
}
