import 'dart:math';

import 'package:employee_flutter/constants/constants.dart';
import 'package:employee_flutter/models/departement_model.dart';
import 'package:employee_flutter/models/employee_model.dart';

import 'package:employee_flutter/models/user_modal.dart';
import 'package:employee_flutter/utils/utilis.dart';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DbService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  UserModel? userModel;
  List<DepartmentModel> allDepartments = [];
  List<EmployeeModel> allEmployees = [];
  int? employeeDepartment;
  late GraphQLClient client;

  DbService() {
    // Initialize the GraphQLClient here
    final HttpLink httpLink = HttpLink(
      'https://xjusozytdfhffhmijmdx.supabase.co/graphql/v1',
      defaultHeaders: <String, String>{
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhqdXNvenl0ZGZoZmZobWlqbWR4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTMxNDA2MzUsImV4cCI6MjAwODcxNjYzNX0.jf0mRwzXJ51QuG7LGkAo7I3nzHxpzzWSEMLEfBLZbFA',
      },
    );

    client = GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(),
    );
  }
  String generateRandomEmployeeId() {
    final random = Random();
    const allChars = "faangFAANG0123456789";
    final randomString =
        List.generate(8, (index) => allChars[random.nextInt(allChars.length)])
            .join();
    return randomString;
  }

  // Future insertNewUser(String email, var id) async {
  //   await _supabase.from(Constants.employeeTable).insert({
  //     'id': id,
  //     'name': '',
  //     'email': email,
  //     'employee_id': generateRandomEmployeeId(),
  //     'departement': null,
  //     'numero':0,
  //     'Admin':false
  //   });
  // }
  Future insertNewUser(String email, String name, var id) async {
    MutationOptions options = MutationOptions(document: gql('''
mutation insetNewUser (\$UserEmail : String ,\$UserName: String \$UserId : UUID , \$employee :String){
  insertIntoemployeesCollection(
    objects:[
      {
      id:\$UserId,
      name:\$UserName,
      email:\$UserEmail,
      employee_id:\$employee,
      departement : 1 ,
      numero : 0 ,
      Admin : false
      }
    ]
  )
  {
    affectedCount
  }
}
'''), variables: <String, dynamic>{
      'UserId': id,
      'UserName': name,
      'UserEmail': email,
      'employee': generateRandomEmployeeId(),
    });
    final QueryResult result = await client.mutate(options);
    if (result.hasException) {
      print(result.exception.toString());
    } else {
      print('employee insert success');
    }
  }

  // Future<UserModel> getUserData() async {
  //   final userData = await _supabase
  //       .from(Constants.employeeTable)
  //       .select()
  //       .eq('id', _supabase.auth.currentUser!.id)
  //       .single();
  //   userModel = UserModel.fromJson(userData);
  //   // Since this function can be called multiple times, then it will reset the dartment value
  //   // That is why we are using condition to assign only at the first time
  //   employeeDepartment == null
  //       ? employeeDepartment = userModel?.department
  //       : null;
  //   return userModel!;
  // }
  Future<UserModel> getUserData() async {
    final QueryOptions options = QueryOptions(
      document: gql('''
      query SelectUser (\$UserId: UUID) {
        employeesCollection(
          filter: {id: {eq: \$UserId}}
        ) {
          edges {
            node {
              id
              name
            }
          }
        }
      }
    '''),
      variables: {
        'UserId': _supabase.auth.currentUser!.id,
      },
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      print(result.exception.toString());
      // Handle the exception here if needed
      return UserModel(id: '', email: '', name: '', employeeId: '');
    } else {
      final data = result.data?['employeesCollection']['edges'] ?? [];

      if (data.isEmpty) {
        return UserModel(id: '', email: '', name: '', employeeId: '');
      }

      final edge = data[0];
      final id = edge['node']['id'];
      final name = edge['node']['name'];
      UserModel emp = UserModel(id: id, email: '', name: name, employeeId: '');

      return emp;
    }
  }

  Future<void> getAllDepartments() async {
    final List result =
        await _supabase.from(Constants.departmentTable).select();
    allDepartments = result
        .map((department) => DepartmentModel.fromJson(department))
        .toList();
    notifyListeners();
  }

//Get all departement using graphql
  Future<void> fetchDepartments() async {
    final QueryOptions options = QueryOptions(
      document: gql('''
      {
        departmentsCollection(first: 6) {
          edges {
            node {
              id
              title
            }
          }
        }
      }
    '''),
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      print(result.exception.toString());
    } else {
      final data = result.data?['departmentsCollection']['edges'] ?? [];

      // Create an empty list to store DepartmentModel instances.
      List<DepartmentModel> departmentList = [];

      for (var edge in data) {
        final id = int.tryParse(edge['node']['id'].toString());
        if (id != null) {
          final title = edge['node']['title'];

          // Create a DepartmentModel instance for each department.
          DepartmentModel department = DepartmentModel(id: id, title: title);
          departmentList.add(department);

          print('Department ID: $id, Title: $title');
        } else {
          // Handle the case where 'id' is not a valid integer.
          print('Invalid department ID: ${edge['node']['id']}');
        }
      }

      // Now, departmentList contains a list of DepartmentModel instances.
      // You can use it or set it to a class property as needed.
      // For example, you can set it to your allDepartments variable.
      allDepartments = departmentList;

      final length = allDepartments.length;
      print("allDepartments: $allDepartments, Length: $length");
    }
  }

// check user admin or not
  Future<bool> isAdmin() async {
    final QueryOptions options = QueryOptions(document: gql('''
    query selectAdmin(\$userId: UUID) {
      employeesCollection(
        first: 1
        filter: { id: { eq: \$userId } }
      ) {
        edges {
          node {
            id
            name
            email
            numero
            Admin
          }
        }
      }
    }
  '''), variables: {
      'userId': _supabase.auth.currentUser!.id,
    });

    final QueryResult result = await client.query(options);
    if (result.hasException) {
      print(result.exception.toString());
      return false; // Return false in case of an exception
    } else {
      print(_supabase.auth.currentUser!.id);
      final data = result.data?['employeesCollection']['edges'] ?? [];

      final edge = data[0];
      final admin = edge['node']['Admin'];
      print(admin);

      return admin;
    }
  }

  Future<bool> checkAdminStatus() async {
    final admin = await isAdmin();
    print('user is $admin');
    if (admin == true) {
      return true;
    } else {
      return false;
    }
  }

//get the employee data using graphql
  Future<void> fetchEmployees() async {
    final QueryOptions options = QueryOptions(
      document: gql('''
      {
        employeesCollection(first:100) {
          edges {
            node {
              id
              name
              email
              Admin
              numero

            }
          }
        }
      }
    '''),
    );
    final QueryResult result = await client.query(options);
    if (result.hasException) {
      print(result.exception.toString());
    } else {
      final data = result.data?['employeesCollection']['edges'] ?? [];
      List<EmployeeModel> employeeList = [];
      for (var edge in data) {
        final id = edge['node']['id'];
        final name = edge['node']['name'];
        final email = edge['node']['email'];
        final admin = edge['node']['Admin'];
        final numero = edge['node']['numero'];
        EmployeeModel employee = EmployeeModel(
            id: id, name: name, email: email, numero: numero, admin: admin);
        employeeList.add(employee);

        print(
            'Employee ID: $id, Name: $name, Email: $email, Number : $numero, Admin : $admin');
      }

      allEmployees = employeeList;

      final length = allEmployees.length;
      print("allEmployees: $allEmployees, Length: $length");
    }
    notifyListeners();
  }

  Future updateProfile(String name, BuildContext context) async {
    await _supabase.from(Constants.employeeTable).update({
      'name': name,
      'departement': employeeDepartment,
    }).eq('id', _supabase.auth.currentUser!.id);

    Utils.showSnackBar("Profile Updated Successfully", context,
        color: Colors.green);
    notifyListeners();
  }

//update employee using graphql
  Future<void> updateEmployee(String id, String name, String email,
      String numero, BuildContext context) async {
    final MutationOptions options = MutationOptions(document: gql("""
 mutation updateProfile(
    \$userId: UUID!
    \$newUsername: String!
    \$newEmail: String!
    \$newNumber: BigInt!

  ) {
    updateemployeesCollection(
      filter: { id: { eq: \$userId } }
      set: { name: \$newUsername, email: \$newEmail, numero:\$newNumber}
    ) {
      affectedCount
      records {
        id
        name
        email
        numero
      }
    }
  }
"""), variables: {
      'userId': id,
      'newUsername': name,
      'newEmail': email,
      'newNumber': numero
    });
    final QueryResult result = await client.mutate(options);
    if (result.hasException) {
      print(result.exception.toString());
    } else {
      print('employee $id modified');
      Utils.showSnackBar("Successfully modify !", context, color: Colors.green);
    }
  }

// delete employee using graphql
  Future<void> deleteEmployee(String id, BuildContext context) async {
    final MutationOptions options = MutationOptions(document: gql('''
 mutation DeleteEmployee(\$employeeID: UUIDFilter!) {
    deleteFromemployeesCollection(atMost: 1, filter: { id: { eq: \$employeeID } }) {
      affectedCount
    }
  }
'''), variables: {'employeeID': id});
    final QueryResult result = await client.mutate(options);
    if (result.hasException) {
      print(result.exception.toString());
    } else {
      print("employee : $id deleted");

      Utils.showSnackBar("Successfully deleted !", context,
          color: Colors.green);
    }
  }
}
