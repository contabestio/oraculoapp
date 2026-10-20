import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/dashboard.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const OraculoApp());
}

class OraculoApp extends StatelessWidget {
  const OraculoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Oráculo',
      theme: AppTheme.lightTheme,
      home: const DashboardPage(),
    );
  }
}

// ============================================================
// CORES ORIGINAIS
// ============================================================

const Color orange = Color(0xFFFFA77F);
const Color lightPurple = Color(0xFFE4D1FF);
const Color darkText = Color(0xFF333333);
const Color lightBackground = Color(0xFFFFFFFF);
