import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'data/books_repository.dart';
import 'services/admin_service.dart';
import 'services/simulado_score_service.dart';
import 'services/event_notification_service.dart';
import 'pages/dashboard.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 4));
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  try {
    // Inicializa o repositório central de livros / materiais
    await BooksRepository.instance.initialize().timeout(const Duration(seconds: 3));
  } catch (e) {
    debugPrint('BooksRepository init error: $e');
  }

  try {
    // Inicializa o serviço de verificação de Administradores
    await AdminService.instance.initialize().timeout(const Duration(seconds: 3));
  } catch (e) {
    debugPrint('AdminService init error: $e');
  }

  try {
    // Inicializa a tabela de pontuações de simulados do banco de dados
    await SimuladoScoreService.instance.initialize().timeout(const Duration(seconds: 3));
  } catch (e) {
    debugPrint('SimuladoScoreService init error: $e');
  }

  try {
    // Inicializa o serviço de alertas e notificações de eventos (24h de antecedência)
    await EventNotificationService.instance.initialize().timeout(const Duration(seconds: 3));
  } catch (e) {
    debugPrint('EventNotificationService init error: $e');
  }

  runApp(const OraculoApp());
}

class OraculoApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  const OraculoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
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
