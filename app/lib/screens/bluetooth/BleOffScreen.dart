import 'dart:io';

import 'package:employee_flutter/screens/bluetooth/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:employee_flutter/services/widget.dart';
import 'package:permission_handler/permission_handler.dart';

final snackBarKeyA = GlobalKey<ScaffoldMessengerState>();
final snackBarKeyB = GlobalKey<ScaffoldMessengerState>();
final snackBarKeyC = GlobalKey<ScaffoldMessengerState>();

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key? key, this.adapterState}) : super(key: key);

  final BluetoothAdapterState? adapterState;

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: snackBarKeyA,
      child: Scaffold(
        backgroundColor: Colors.lightBlue,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.bluetooth_disabled,
                size: 200.0,
                color: Colors.white54,
              ),
              Text(
                'Bluetooth Adapter is ${adapterState != null ? adapterState.toString().split(".").last : 'not available'}.',
                style: Theme.of(context)
                    .primaryTextTheme
                    .titleSmall
                    ?.copyWith(color: Colors.white),
              ),
              if (Platform.isAndroid)
                ElevatedButton(
                  child: const Text('TURN ON'),
                  onPressed: () async {
                    PermissionStatus status =
                        await Permission.bluetooth.request();
                    if (status.isDenied) {
                      // The permission was denied.
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Bluetooth Permission"),
                          content: const Text(
                              "This feature requires Bluetooth access. Please enable it from the app settings."),
                          actions: [
                            TextButton(
                              child: Text("Close"),
                              onPressed: () {
                                Navigator.of(ctx).pop();
                              },
                            ),
                            TextButton(
                              child: Text("Open Settings"),
                              onPressed: () async {
                                openAppSettings();
                              },
                            ),
                          ],
                        ),
                      );
                    } else if (status.isGranted) {
                      try {
                        if (Platform.isAndroid) {
                          await FlutterBluePlus.turnOn();
                        }
                      } catch (e) {
                        final snackBar = snackBarFail(
                            prettyException("Error Turning On:", e));
                        snackBarKeyA.currentState?.removeCurrentSnackBar();
                        snackBarKeyA.currentState?.showSnackBar(snackBar);
                      }
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
