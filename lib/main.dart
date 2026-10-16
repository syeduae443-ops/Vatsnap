import 'package:flutter/material.dart';
import 'screens/camera_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VatSnapApp());
}

class VatSnapApp extends StatelessWidget {
  const VatSnapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VatSnap Dubai',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const CameraScreen(),
    );
  }
}
