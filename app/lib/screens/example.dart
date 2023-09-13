// Copyright 2021 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:employee_flutter/models/attendance_model.dart';

import 'package:employee_flutter/services/attendance_service.dart';

import 'package:employee_flutter/services/db_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:simple_month_year_picker/simple_month_year_picker.dart';

const Widget divider = SizedBox(height: 10);

// If screen content width is greater or equal to this value, the light and dark
// color schemes will be displayed in a column. Otherwise, they will
// be displayed in a row.
const double narrowScreenWidthThreshold = 400;

class ColorPalettesScreen extends StatelessWidget {
  const ColorPalettesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final attendanceService = Provider.of<AttendanceService>(context);
    TextEditingController nameController = TextEditingController();
    final dbService = Provider.of<DbService>(context);
    dbService.allDepartments.isEmpty ? dbService.getAllDepartments() : null;
    nameController.text.isEmpty
        ? nameController.text = dbService.userModel?.name ?? ''
        : null;

    return Expanded(
      child: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth < narrowScreenWidthThreshold) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(left: 20, top: 60, bottom: 10),
                  child: const Text(
                    "My Attendance",
                    style: TextStyle(fontSize: 25),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      attendanceService.attendanceHistoryMonth,
                      style: const TextStyle(fontSize: 25),
                    ),
                    OutlinedButton(
                        onPressed: () async {
                          final selectedDate = await SimpleMonthYearPicker
                              .showMonthYearPickerDialog(
                                  context: context, disableFuture: true);
                          String pickedMonth =
                              DateFormat('MMMM yyyy').format(selectedDate);
                          attendanceService.attendanceHistoryMonth =
                              pickedMonth;
                        },
                        child: const Text("Pick a month")),
                  ],
                ),
              ],
            ),
          );
        } else {
          return Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(left: 20, top: 60, bottom: 10),
                child: const Text(
                  "My Attendance",
                  style: TextStyle(fontSize: 25),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    attendanceService.attendanceHistoryMonth,
                    style: const TextStyle(fontSize: 25),
                  ),
                  OutlinedButton(
                      onPressed: () async {
                        final selectedDate = await SimpleMonthYearPicker
                            .showMonthYearPickerDialog(
                                context: context, disableFuture: true);
                        String pickedMonth =
                            DateFormat('MMMM yyyy').format(selectedDate);
                        attendanceService.attendanceHistoryMonth = pickedMonth;
                      },
                      child: const Text("Pick a month")),
                ],
              ),
              Expanded(
                  child: FutureBuilder(
                      future: attendanceService.getAttendanceHistory(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data.length > 0) {
                            return ListView.builder(
                                itemCount: snapshot.data.length,
                                itemBuilder: (context, index) {
                                  AttendanceModel attendanceData =
                                      snapshot.data[index];
                                  return Container(
                                    margin: const EdgeInsets.only(
                                        top: 12,
                                        left: 20,
                                        right: 20,
                                        bottom: 10),
                                    height: 150,
                                    decoration: const BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 10,
                                              offset: Offset(2, 2)),
                                        ],
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                            child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.redAccent,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20)),
                                          ),
                                          child: Center(
                                            child: Text(
                                              DateFormat("EE \n dd").format(
                                                  attendanceData.createdAt),
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        )),
                                        Expanded(
                                            child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const Text(
                                              "Check in",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.black54),
                                            ),
                                            const SizedBox(
                                              width: 80,
                                              child: Divider(),
                                            ),
                                            Text(
                                              attendanceData.checkIn,
                                              style:
                                                  const TextStyle(fontSize: 25),
                                            )
                                          ],
                                        )),
                                        Expanded(
                                            child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const Text(
                                              "Check Out",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.black54),
                                            ),
                                            const SizedBox(
                                              width: 80,
                                              child: Divider(),
                                            ),
                                            Text(
                                              attendanceData.checkOut
                                                      ?.toString() ??
                                                  '--/--',
                                              style:
                                                  const TextStyle(fontSize: 25),
                                            )
                                          ],
                                        )),
                                        const SizedBox(
                                          width: 15,
                                        )
                                      ],
                                    ),
                                  );
                                });
                          } else {
                            return const Center(
                              child: Text(
                                "No Data Available",
                                style: TextStyle(fontSize: 25),
                              ),
                            );
                          }
                        }
                        return const LinearProgressIndicator(
                          backgroundColor: Colors.white,
                          color: Colors.grey,
                        );
                      })),
            ],
          );
        }
      }),
    );
  }
}
