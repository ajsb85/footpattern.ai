// Copyright 2021 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:employee_flutter/models/departement_model.dart';
import 'package:employee_flutter/services/auth_service.dart';
import 'package:employee_flutter/services/db_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const Widget divider = SizedBox(height: 10);

// If screen content width is greater or equal to this value, the light and dark
// color schemes will be displayed in a column. Otherwise, they will
// be displayed in a row.
const double narrowScreenWidthThreshold = 400;
TextEditingController nameController = TextEditingController();

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dbService = Provider.of<DbService>(context);
    dbService.allDepartments.isEmpty ? dbService.fetchDepartments() : null;
    nameController.text.isEmpty
        ? nameController.text = dbService.userModel?.name ?? ''
        : null;

    return Expanded(
        child: Scaffold(
            body: Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 20),
              alignment: Alignment.topRight,
              child: TextButton.icon(
                  onPressed: () {
                    Provider.of<AuthService>(context, listen: false).signOut();
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text("Sign Out")),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.redAccent),
              child: const Center(
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Text("Admin : ${dbService.userModel?.employeeId}"),
            const SizedBox(
              height: 30,
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                  label: Text("Full name"), border: OutlineInputBorder()),
            ),
            const SizedBox(
              height: 15,
            ),
            dbService.allDepartments.isEmpty
                ? const LinearProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: DropdownButtonFormField(
                      decoration:
                          const InputDecoration(border: OutlineInputBorder()),
                      value: dbService.employeeDepartment ??
                          dbService.allDepartments.first.id,
                      items:
                          dbService.allDepartments.map((DepartmentModel item) {
                        return DropdownMenuItem(
                            value: item.id,
                            child: Text(
                              item.title,
                              style: const TextStyle(fontSize: 20),
                            ));
                      }).toList(),
                      onChanged: (selectedValue) {
                        dbService.employeeDepartment = selectedValue as int?;
                      },
                    ),
                  ),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  dbService.updateProfile(nameController.text.trim(), context);
                },
                child: const Text(
                  "Update Profile",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    )));
  }
}
