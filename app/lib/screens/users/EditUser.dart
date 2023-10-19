import 'package:employee_flutter/models/employee_model.dart';
import 'package:employee_flutter/screens/home_screen.dart';
import 'package:employee_flutter/screens/splach_screen.dart';
import 'package:employee_flutter/screens/users/users_screen.dart';
import 'package:employee_flutter/services/db_service.dart';
import 'package:employee_flutter/utils/utilis.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetailPage extends StatefulWidget {
  final EmployeeModel employee;

  DetailPage({required this.employee});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool isObscurePassword = true;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dbService = Provider.of<DbService>(context);
    final fullName = widget.employee.name;
    final email = widget.employee.email;
    final id = widget.employee.id;
    final numero = widget.employee.numero;
    return Scaffold(
        appBar: AppBar(
          title: Text('Edit Employee'),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserScreen(),
                  ));
            },
          ),
          actions: [
            IconButton(
                onPressed: () {
                  dbService.deleteEmployee(id, context);
                },
                icon: const Icon(Icons.delete, color: Colors.black))
          ],
        ),
        body: Container(
          padding: EdgeInsets.only(left: 15, top: 20, right: 15),
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: ListView(
              children: [
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                            border: Border.all(width: 4, color: Colors.white),
                            boxShadow: [
                              BoxShadow(
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  color: Colors.white.withOpacity(0.1))
                            ],
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                    'https://cdn.pixabay.com/photo/2016/12/19/21/36/woman-1919143_1280.jpg'))),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(width: 4, color: Colors.white),
                              color: Colors.blue),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 30),
                buildTextField("Full Name", nameController, fullName, false),
                buildTextField("Email", emailController, email, false),
                buildTextField(
                    "Number", numberController, numero as String, false),
                SizedBox(height: 30),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          final admin = dbService.checkAdminStatus();
                          if (admin == true) {
                            print('leith is admin');
                          } else {
                            print('leith is not admin');
                          }
                        },
                        child: Text("CANCEL",
                            style: TextStyle(
                                fontSize: 15,
                                letterSpacing: 2,
                                color: Colors.black)),
                        style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20))),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final newName = nameController.text;
                          final newEmail = emailController.text;
                          final newNumber = numberController.text;

                          if (newName.isNotEmpty && newEmail.isNotEmpty) {
                            dbService.updateEmployee(
                                id, newName, newEmail, newNumber, context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "Please fill in both Name and Email fields."),
                              ),
                            );
                          }
                        },
                        child: Text("SAVE",
                            style: TextStyle(
                                fontSize: 15,
                                letterSpacing: 2,
                                color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                            primary: Colors.blue,
                            padding: EdgeInsets.symmetric(horizontal: 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20))),
                      )
                    ]),
              ],
            ),
          ),
        ));
  }
}

Widget buildTextField(String labelText, TextEditingController controller,
    String placehonder, bool isPasswordTextField) {
  bool isObscurePassword = true;
  return Padding(
    padding: EdgeInsets.only(bottom: 30),
    child: TextField(
        controller: controller,
        obscureText: isPasswordTextField ? isObscurePassword : false,
        decoration: InputDecoration(
            suffixIcon: isPasswordTextField
                ? IconButton(
                    onPressed: () {
                      // setState((){ isObscurePassword = ! isObscurePassword;});
                    },
                    icon: Icon(Icons.remove_red_eye, color: Colors.grey))
                : null,
            contentPadding: EdgeInsets.only(bottom: 5),
            labelText: labelText,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: placehonder,
            hintStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey))),
  );
}
