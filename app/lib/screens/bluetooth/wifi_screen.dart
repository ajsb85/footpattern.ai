// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:wifi_scan/wifi_scan.dart';

class WifiScreen extends StatefulWidget {
  final String deviceLocalName;

  const WifiScreen({Key? key, required this.deviceLocalName}) : super(key: key);

  @override
  State<WifiScreen> createState() => _WifiScreen();
}

class _WifiScreen extends State<WifiScreen> {
  List<WiFiAccessPoint> accessPoints = <WiFiAccessPoint>[];
  StreamSubscription<List<WiFiAccessPoint>>? subscription;
  bool shouldCheckCan = true;
  bool isDeviceConnected = false; // Track device connection status

  bool get isStreaming => subscription != null;

  // Initialize FlutterBlue
  final flutterBlue = FlutterBluePlus.instance;

  // Discover and connect to the device
  late BluetoothDevice device;

  // Initialize Bluetooth device connection
  Future<void> _initializeDevice() async {
    final connectedDevices = await FlutterBluePlus.connectedDevices;
    for (var d in connectedDevices) {
      if (d.name == widget.deviceLocalName) {
        setState(() {
          isDeviceConnected = true;
          device = d;
        });
        break;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeDevice();
  }

  Future<void> _startScan(BuildContext context) async {
    if (!isDeviceConnected) {
      kShowSnackBar(context, 'Device is not connected.');
      return;
    }

    if (shouldCheckCan) {
      final can = await WiFiScan.instance.canStartScan();
      if (can != CanStartScan.yes) {
        kShowSnackBar(context, 'Cannot start scan: $can');
        return;
      }
    }

    final result = await WiFiScan.instance.startScan();
    kShowSnackBar(context, 'startScan: $result');
    setState(() => accessPoints = <WiFiAccessPoint>[]);
  }

  Future<bool> _canGetScannedResults(BuildContext context) async {
    if (!isDeviceConnected) {
      kShowSnackBar(context, 'Device is not connected.');
      accessPoints = <WiFiAccessPoint>[];
      return false;
    }

    if (shouldCheckCan) {
      final can = await WiFiScan.instance.canGetScannedResults();
      if (can != CanGetScannedResults.yes) {
        kShowSnackBar(context, 'Cannot get scanned results: $can');
        accessPoints = <WiFiAccessPoint>[];
        return false;
      }
    }
    return true;
  }

  Future<void> _getScannedResults(BuildContext context) async {
    if (await _canGetScannedResults(context)) {
      final results = await WiFiScan.instance.getScannedResults();
      setState(() => accessPoints = results);
    }
  }

  Future<void> _startListeningToScanResults(BuildContext context) async {
    if (await _canGetScannedResults(context)) {
      subscription = WiFiScan.instance.onScannedResultsAvailable
          .listen((result) => setState(() => accessPoints = result));
    }
  }

  void _stopListeningToScanResults() {
    subscription?.cancel();
    setState(() => subscription = null);
  }

  // Write Wi-Fi SSID and password to the characteristic
  void _writeWifiConfig(
      String ssid, String password, BuildContext context) async {
    if (!isDeviceConnected) {
      kShowSnackBar(context, 'Device is not connected.');
      return;
    }

    final serviceUuid = Guid('0000ff01-0000-1000-8000-00805f9b34fb');
    final characteristicUuid = Guid('00002a0d-0000-1000-8000-00805f9b34fb');

    final service = await device.discoverServices();
    final characteristic = service
        .firstWhere((s) => s.uuid == serviceUuid)
        .characteristics
        .firstWhere((c) => c.uuid == characteristicUuid);

    final data = utf8.encode('$ssid:$password');

    await characteristic.write(data, withoutResponse: false);

    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text('Wi-Fi configuration sent successfully.'),
    //     duration: Duration(seconds: 3),
    //   ),
    // );
  }

  Widget _buildToggle({
    String? label,
    bool value = false,
    ValueChanged<bool>? onChanged,
    Color? activeColor,
  }) =>
      Row(
        children: [
          if (label != null) Text(label),
          Switch(value: value, onChanged: onChanged, activeColor: activeColor),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deviceLocalName),
      ),
      body: Builder(
        builder: (context) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.perm_scan_wifi),
                    label: const Text('SCAN'),
                    onPressed: () async => _startScan(context),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('GET'),
                    onPressed: () async => _getScannedResults(context),
                  ),
                ],
              ),
              const Divider(),
              Flexible(
                child: Center(
                  child: accessPoints.isEmpty
                      ? const Text("NO SCANNED RESULTS")
                      : ListView.builder(
                          itemCount: accessPoints.length,
                          itemBuilder: (context, i) => _AccessPointTile(
                            accessPoint: accessPoints[i],
                            writeWifiConfig:
                                _writeWifiConfig, // Pass the callback
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccessPointTile extends StatelessWidget {
  final WiFiAccessPoint accessPoint;
  final Function(String, String, BuildContext) writeWifiConfig; // Callback

  const _AccessPointTile({
    Key? key,
    required this.accessPoint,
    required this.writeWifiConfig, // Receive the callback
  }) : super(key: key);

  Widget _buildInfo(String label, dynamic value) => Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey)),
        ),
        child: Row(
          children: [
            Text(
              "$label: ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(child: Text(value.toString()))
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final TextEditingController _textEditingController =
        TextEditingController();
    final title = accessPoint.ssid.isNotEmpty ? accessPoint.ssid : "**EMPTY**";
    final signalIcon = accessPoint.level >= -80
        ? Icons.signal_wifi_4_bar
        : Icons.signal_wifi_0_bar;
    return ListTile(
      visualDensity: VisualDensity.compact,
      leading: Icon(signalIcon),
      title: Text(title),
      subtitle: Text(accessPoint.capabilities),
      onTap: () => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Enter WiFi Password:"),
              TextField(
                controller: _textEditingController,
                decoration: InputDecoration(hintText: "Type here..."),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                String wifiPassword = _textEditingController.text;
                String SSID = title ; 
                writeWifiConfig(wifiPassword, SSID,
                    context); // Call the callback with SSID as a placeholder
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}



void kShowSnackBar(BuildContext context, String message) {
  if (kDebugMode) print(message);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
