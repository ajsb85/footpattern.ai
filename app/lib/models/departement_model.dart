class DepartmentModel {
  final int id;
  final String title;

  DepartmentModel({required this.id, required this.title});

  factory DepartmentModel.fromJson(Map<String, dynamic> data) {
    return DepartmentModel(id: data['id'], title: data['title']);
  }
}
