import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:beacons_plugin/beacons_plugin.dart';
import 'package:flutter/material.dart';
import 'package:motb_beacons_plugin/models/beacon.dart';
import 'package:permission_handler/permission_handler.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({Key? key}) : super(key: key);

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final StreamController<String> beaconEventsController = StreamController<String>.broadcast();
  final List<Beacon> _beacons = List.empty(growable: true);
  bool isRunning = false;
  late PermissionStatus bluetoothStatus;
  late PermissionStatus locationStatus;

  void checkPermissions() async {
    bluetoothStatus = await Permission.bluetooth.status;
    locationStatus = await Permission.location.status;
    if (!bluetoothStatus.isGranted) await Permission.bluetooth.request();
    if (!locationStatus.isGranted) await Permission.location.request();
  }

  void initBluetooth() async {
    BeaconsPlugin.listenToBeacons(beaconEventsController);

    setState(() => isRunning = true);
    beaconEventsController.stream.listen(
      (data) {
        if (data.isNotEmpty) {
          Beacon b = Beacon.fromJson(data);
          if (_beacons.any((element) => element.major == b.major)) {
            int index = _beacons.indexWhere((element) => element.major == b.major);
            setState(() => _beacons[index] = b);
          } else {
            setState(() => _beacons.add(b));
          }
          setState(() => _beacons.sort(((a, b) => a.major < b.major ? 0 : 1)));
        }
      },
    ).onError(
      (error, errorr) {
        log("Error listening to bt stream: $error");
      },
    );
  }

  void startBt() async {
    BeaconsPlugin.addRegion("Zebra", "FE913213-B311-4A42-8C16-47FAEAC938DC");
    setState(() => isRunning = true);
    if (Platform.isAndroid) {
      BeaconsPlugin.channel.setMethodCallHandler((call) async {
        if (call.method == 'scannerReady') {
          await BeaconsPlugin.startMonitoring();
        }
      });
    } else if (Platform.isIOS) {
      await BeaconsPlugin.startMonitoring();
    }
  }

  void stopBt() async {
    setState(() => isRunning = false);
    await BeaconsPlugin.stopMonitoring();
  }

  @override
  void initState() {
    super.initState();
    //checkPermissions();
    initBluetooth();
  }

  @override
  void dispose() {
    super.dispose();
    beaconEventsController.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: isRunning ? stopBt : startBt,
        child: isRunning ? const Icon(Icons.stop) : const Icon(Icons.play_arrow),
      ),
      appBar: AppBar(
        title: const Text("Beacon Scanner"),
      ),
      body: Center(
        child: /* Text(
            _beaconResult), */
            ListView.builder(
          itemCount: _beacons.length,
          itemBuilder: ((context, index) {
            return BeaconWidget(beacon: _beacons[index]);
          }),
        ),
      ),
    );
  }
}

class BeaconWidget extends StatelessWidget {
  const BeaconWidget({Key? key, required this.beacon}) : super(key: key);
  final Beacon beacon;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        children: [
          Text("UUID: ${beacon.uuid}"),
          Text("Major: ${beacon.major}     Minor: ${beacon.minor}"),
          Text("RSSI: ${beacon.rssi}     Prox: ${beacon.proximity}"),
          Text("Distance: ${beacon.distance}"),
          const Divider()
        ],
      ),
    );
  }
}
