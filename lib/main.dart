import 'package:flutter/material.dart';
import 'package:motb_beacons_plugin/pages/scanner_page.dart';

void main() {
  runApp(const ScannerApp());
}

class ScannerApp extends StatelessWidget {
  const ScannerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        "/": (context) => const ScannerPage(),
      },
      initialRoute: '/',
    );
  }
}
