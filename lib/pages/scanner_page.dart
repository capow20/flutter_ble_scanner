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

  int compareBeacons(Beacon a, Beacon b) {
    if (a.rssi == 0) {
      return 1;
    } else if (b.rssi == 0) {
      return -1;
    } else if (a.rssi > b.rssi) {
      return -1;
    } else if (a.rssi < b.rssi) {
      return 1;
    } else {
      return 0;
    }
  }

  void initBluetooth() async {
    BeaconsPlugin.listenToBeacons(beaconEventsController);
    beaconEventsController.stream.listen(
      (data) {
        if (data.isNotEmpty) {
          Beacon b = Beacon.fromJson(data);
          if (_beacons.any((e) => e.major == b.major)) {
            int index = _beacons.indexWhere((element) => element.major == b.major);
            setState(() => _beacons[index] = b);
          } else {
            setState(() => _beacons.add(b));
          }
          setState(() => _beacons.sort((a, b) => compareBeacons(a, b)));
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
    BeaconsPlugin.addRegion("Zebra1", "FE913213B3114A428C1647FAEAC938DC");
    BeaconsPlugin.addRegion("Zebra2", "fe913213b3114a428c1647faeac938dc");
    BeaconsPlugin.addRegion("Zebra3", "fe913213-b311-4a42-8c16-47faeac938dc");
    setState(() => isRunning = true);
    if (Platform.isAndroid) {
      /* print("platform is android");
      BeaconsPlugin.channel.setMethodCallHandler((call) async {
        print("inisde setMethodCallBack");
        if (call.method == 'scannerReady') {
          await BeaconsPlugin.startMonitoring();
          print("Android start monitoring called()");
        } else {
          print("Android not ready to start monitoring");
        }
      }); */

      BeaconsPlugin.startMonitoring();
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Text("UUID: ${beacon.uuid}"),
              Text("Major: ${beacon.major}     Minor: ${beacon.minor}"),
              Text("RSSI: ${beacon.rssi}     Prox: ${beacon.proximity}"),
              Text("Distance: ${beacon.distance}"),
              const Divider()
            ],
          ),
          beacon.rssi < 0 && beacon.rssi != 0
              ? const Icon(
                  Icons.near_me,
                  color: Colors.blue,
                )
              : const SizedBox()
        ],
      ),
    );
  }
}
