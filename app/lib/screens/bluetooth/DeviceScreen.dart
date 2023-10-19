import 'package:employee_flutter/screens/bluetooth/FindDevicesScreen.dart';
import 'package:employee_flutter/screens/bluetooth/wifi_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

const String wifiServiceUuid = "0000ff01-0000-1000-8000-00805f9b34fb";
const String wifiCharacteristicUuid = "00002a0d-0000-1000-8000-00805f9b34fb";

List<String> wifiNetworks = [];

class DeviceScreen extends StatefulWidget {
  final BluetoothDevice device;

  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  @override
  _DeviceScreenState createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.localName),
        actions: <Widget>[
          StreamBuilder<BluetoothConnectionState>(
            stream: widget.device.connectionState,
            initialData: BluetoothConnectionState.connecting,
            builder: (c, snapshot) {
              VoidCallback? onPressed;
              String text;
              switch (snapshot.data) {
                case BluetoothConnectionState.connected:
                  onPressed = () async {
                    try {
                      await widget.device.disconnect();
                      final snackBar =
                          SnackBar(content: Text("Disconnect: Success"));
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    } catch (e) {
                      final snackBar =
                          SnackBar(content: Text("Disconnect Error: $e"));
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  };
                  text = 'DISCONNECT';
                  break;
                case BluetoothConnectionState.disconnected:
                  onPressed = () async {
                    try {
                      await widget.device
                          .connect(timeout: Duration(seconds: 35));
                      final snackBar =
                          SnackBar(content: Text("Connect: Success"));
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    } catch (e) {
                      final snackBar =
                          SnackBar(content: Text("Connect Error: $e"));
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  };
                  text = 'CONNECT';
                  break;
                default:
                  onPressed = null;
                  text = snapshot.data.toString().split(".").last.toUpperCase();
                  break;
              }
              return ValueListenableBuilder<bool>(
                valueListenable:
                    isConnectingOrDisconnecting[widget.device.remoteId]!,
                builder: (context, value, child) {
                  isConnectingOrDisconnecting[widget.device.remoteId] ??=
                      ValueNotifier(false);
                  if (isConnectingOrDisconnecting[widget.device.remoteId]!
                          .value ==
                      true) {
                    return Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.black12,
                          color: Colors.black26,
                        ),
                      ),
                    );
                  } else {
                    return TextButton(
                      onPressed: onPressed,
                      child: Text(
                        text,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .labelLarge
                            ?.copyWith(color: Colors.white),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            StreamBuilder<BluetoothConnectionState>(
              stream: widget.device.connectionState,
              initialData: BluetoothConnectionState.connecting,
              builder: (c, snapshot) => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${widget.device.remoteId}'),
                  ),
                  ListTile(
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        snapshot.data == BluetoothConnectionState.connected
                            ? const Icon(Icons.bluetooth_connected)
                            : const Icon(Icons.bluetooth_disabled),
                        snapshot.data == BluetoothConnectionState.connected
                            ? StreamBuilder<int>(
                                stream: rssiStream(maxItems: 1),
                                builder: (context, snapshot) {
                                  return Text(
                                    snapshot.hasData
                                        ? '${snapshot.data}dBm'
                                        : '',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  );
                                },
                              )
                            : Text('',
                                style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                    title: Text(
                        'Device is ${snapshot.data.toString().split('.')[1]}.'),
                    trailing: StreamBuilder<bool>(
                      stream: widget.device.isDiscoveringServices,
                      initialData: false,
                      builder: (c, snapshot) => IndexedStack(
                        index: (snapshot.data ?? false) ? 1 : 0,
                        children: <Widget>[
                          TextButton(
                            child: const Text("Get Services"),
                            onPressed: () async {
                              try {
                                await widget.device.discoverServices();
                                final snackBar = SnackBar(
                                    content:
                                        Text("Discover Services: Success"));
                                ScaffoldMessenger.of(context)
                                    .removeCurrentSnackBar();
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              } catch (e) {
                                final snackBar = SnackBar(
                                    content:
                                        Text("Discover Services Error: $e"));
                                ScaffoldMessenger.of(context)
                                    .removeCurrentSnackBar();
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              }
                            },
                          ),
                          const IconButton(
                            icon: SizedBox(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(Colors.grey),
                              ),
                              width: 18.0,
                              height: 18.0,
                            ),
                            onPressed: null,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            StreamBuilder<int>(
              stream: widget.device.mtu,
              initialData: 0,
              builder: (c, snapshot) => ListTile(
                title: const Text('MTU Size'),
                subtitle: Text('${snapshot.data} bytes'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    try {
                      await widget.device.requestMtu(223);
                      final snackBar =
                          SnackBar(content: Text("Request Mtu: Success"));
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    } catch (e) {
                      final snackBar =
                          SnackBar(content: Text("Change Mtu Error: $e"));
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  },
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => WifiScreen(
                              deviceLocalName: widget.device.localName,
                            )));
              },
              child: const Text("Show Wi-Fi AP"),
            ),
          ],
        ),
      ),
    );
  }

  Stream<int> rssiStream(
      {Duration frequency = const Duration(seconds: 5),
      int? maxItems = null}) async* {
    var isConnected = true;
    final subscription = widget.device.connectionState.listen((v) {
      isConnected = v == BluetoothConnectionState.connected;
    });
    int i = 0;
    while (isConnected && (maxItems == null || i < maxItems)) {
      try {
        yield await widget.device.readRssi();
      } catch (e) {
        print("Error reading RSSI: $e");
        break;
      }
      await Future.delayed(frequency);
      i++;
    }
    // Device disconnected, stopping RSSI stream
    subscription.cancel();
  }
}
