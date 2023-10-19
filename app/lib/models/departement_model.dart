class DepartmentModel {
  final int id;
  final String title;

  DepartmentModel({required this.id, required this.title});

  // GraphQL serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
    };
  }

  // Factory method to deserialize data from GraphQL
  factory DepartmentModel.fromJson(Map<String, dynamic> data) {
    return DepartmentModel(
      id: data['id'],
      title: data['title'],
    );
  }
}
