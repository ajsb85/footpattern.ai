class UserModel {
  final String id;
  final String email;
  final String name;
  final int? departement;
  final String employeeId;

  UserModel(
      {required this.id,
      required this.email,
      required this.name,
      this.departement,
      required this.employeeId});

  factory UserModel.fromJson(Map<String, dynamic> data) {
    return UserModel(
        id: data['id'],
        email: data['email'],
        name: data['name'],
        departement: data['departement'],
        employeeId: data['employee_id']);
  }
}
