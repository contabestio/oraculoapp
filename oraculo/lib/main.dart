import 'package:flutter/material.dart';
import 'pages/dashboard.dart';

void main() {
  runApp(const OraculoApp());
}

class OraculoApp extends StatelessWidget {
  const OraculoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Oráculo',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFA77F),
        ),
      ),
      home: const DashboardPage(),
    );
  }
}

// ============================================================
// CORES
// ============================================================

const Color orange = Color(0xFFFFA77F);
const Color lightPurple = Color(0xFFE4D1FF);
const Color darkText = Color(0xFF333333);
const Color lightBackground = Color(0xFFFFFFFF);
