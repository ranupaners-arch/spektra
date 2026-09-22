import 'package:flutter/material.dart';
// GANTI 'omnispace' DENGAN NAMA PROJECT KAMU DI pubspec.yaml (biasanya sama)
import 'package:omnispace/features/tracking/presentation/tracking_screen.dart'; 

void main() {
  runApp(const OmniSpaceApp());
}

class OmniSpaceApp extends StatelessWidget {
  const OmniSpaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OmniSpace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily: 'Roboto', // Font default yang rapi
      ),
      home: const TrackingScreen(), // <-- Ini yang mengubah layar utama
    );
  }
}