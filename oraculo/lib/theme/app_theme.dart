import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTheme {
  // ==========================================================
  // CORES ORIGINAIS DO PROJETO
  // ==========================================================

  // Laranja / Pêssego Original
  static const Color orange = Color(0xFFFFAB8C);
  static const Color orangeLight = Color(0xFFFFC2AD);
  static const Color orangeBg = Color(0xFFFFF0EA);
  static const Color orangeDark = Color(0xFFE87A53);

  // Lilás Original
  static const Color lilac = Color(0xFFE4D1FF);
  static const Color lilacContainer = Color(0xFFE5D9FA);
  static const Color lilacNotes = Color(0xFFEADBFF);

  // Textos Originais
  static const Color darkText = Color(0xFF333333);
  static const Color darkPurple = Color(0xFF594A6D);
  static const Color darkTextHeading = Color(0xFF2B2B2B);
  static const Color mutedText = Color(0xFF8E8E8E);
  static const Color lightText = Color(0xFF666666);

  // Superfícies Originais
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF7F7F9);

  // Cores de Tarefas / Eventos Originais
  static const Color catRedacao = Color(0xFFFFAB8C);
  static const Color catRedacaoBg = Color(0xFFFFF0EA);
  static const Color catLeitura = Color(0xFFFCD068);
  static const Color catLeituraBg = Color(0xFFFFF7E3);
  static const Color catExatas = Color(0xFF9EE08F);
  static const Color catExatasBg = Color(0xFFECFCE8);
  static const Color catReuniao = Color(0xFF7CA1FF);
  static const Color catReuniaoBg = Color(0xFFEFF4FF);
  static const Color catGeral = Color(0xFFD393FF);
  static const Color catGeralBg = Color(0xFFF8EFFE);

  // Cores de Exclusão Originais
  static const Color deleteRed = Color(0xFFFF6B6B);
  static const Color deleteRedLight = Color(0xFFFF8888);

  // Gradiente Original do Login
  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFAB8C), Color(0xFFFFC2AD)],
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Arial',
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: orange,
        primary: orange,
        secondary: lilac,
        surface: Colors.white,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: ZoomPageTransitionsBuilder(),
        },
      ),
    );
  }
}
