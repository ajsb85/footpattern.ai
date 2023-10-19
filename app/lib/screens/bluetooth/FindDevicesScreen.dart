// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:employee_flutter/screens/bluetooth/DeviceScreen.dart';
import 'package:employee_flutter/screens/bluetooth/constant.dart';
import 'package:employee_flutter/services/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

final snackBarKeyA = GlobalKey<ScaffoldMessengerState>();
final snackBarKeyB = GlobalKey<ScaffoldMessengerState>();
final snackBarKeyC = GlobalKey<ScaffoldMessengerState>();
final Map<DeviceIdentifier, ValueNotifier<bool>> isConnectingOrDisconnecting =
    {};




  //Find Devices Screen 
class FindDevicesScreen extends StatefulWidget {
  const FindDevicesScreen({Key? key}) : super(key: key);

  @override
  State<FindDevicesScreen> createState() => _FindDevicesScreenState();
}

class _FindDevicesScreenState extends State<FindDevicesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Devices'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {}); // Force refresh of connectedSystemDevices
          if (FlutterBluePlus.isScanningNow == false) {
            FlutterBluePlus.startScan(
              timeout: const Duration(seconds: 15),
              androidUsesFineLocation: false,
            );
          }
          return Future.delayed(Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBluePlus.scanResults,
                initialData: const [],
                builder: (c, snapshot) {
                  final filteredResults = snapshot.data?.where((result) {
                    // Define the service UUID you want to filter by
                    final serviceUuid = '0000ff01-0000-1000-8000-00805f9b34fb';

                    return result.advertisementData.serviceUuids
                        .contains(serviceUuid);
                  }).toList();

                  if (filteredResults == null || filteredResults.isEmpty) {
                    // No devices found with the specified service UUID
                    return Center(
                      child: Text(
                          'No devices found with the specified service UUID.'),
                    );
                  }

                  return Column(
                    children: filteredResults
                        .map(
                          (r) => ScanResultTile(
                            result: r,
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) {
                                      isConnectingOrDisconnecting[r.device
                                          .remoteId] ??= ValueNotifier(true);
                                      isConnectingOrDisconnecting[
                                              r.device.remoteId]!
                                          .value = true;
                                      r.device
                                          .connect(
                                              timeout: Duration(seconds: 35))
                                          .catchError((e) {
                                        final snackBar = snackBarFail(
                                            prettyException(
                                                "Connect Error:", e));
                                        snackBarKeyC.currentState
                                            ?.removeCurrentSnackBar();
                                        snackBarKeyC.currentState
                                            ?.showSnackBar(snackBar);
                                      }).then((v) {
                                        isConnectingOrDisconnecting[r.device
                                            .remoteId] ??= ValueNotifier(false);
                                        isConnectingOrDisconnecting[
                                                r.device.remoteId]!
                                            .value = false;
                                      });
                                      return DeviceScreen(device: r.device);
                                    },
                                    settings:
                                        RouteSettings(name: '/deviceScreen'))),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBluePlus.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data == true) {
            return FloatingActionButton(
              child: const Icon(Icons.stop),
              onPressed: () async {
                try {
                  FlutterBluePlus.stopScan();
                } catch (e) {
                  final snackBar = SnackBar(
                    content: Text('Stop Scan Error: $e'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
              child: const Text("SCAN"),
              onPressed: () async {
                try {
                  await FlutterBluePlus.startScan(
                    timeout: const Duration(seconds: 15),
                    androidUsesFineLocation: false,
                  );
                } catch (e) {
                  final snackBar = SnackBar(
                    content: Text('Start Scan Error: $e'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
                setState(() {}); // Force refresh of connectedSystemDevices
              },
            );
          }
        },
      ),
    );
  }
}

