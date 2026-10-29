import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/admin_config.dart';

/// Serviço que gerencia a autorização de Administradores / Desenvolvedores.
///
/// Garante que usuários regulares NÃO tenham acesso a inserção, edição ou
/// remoção de conteúdo de livros.
class AdminService {
  AdminService._();
  static final AdminService instance = AdminService._();

  static const String _storageKey = 'oraculo_custom_admin_emails_v1';

  final ValueNotifier<bool> isAdminNotifier = ValueNotifier<bool>(false);
  bool get isAdmin => isAdminNotifier.value;

  final List<String> _customAdminEmails = [];

  /// Lista consolidada de todos os e-mails com privilégio de Administrador
  List<String> get allAdminEmails {
    final set = <String>{};
    for (final e in AdminConfig.defaultAdminEmails) {
      set.add(e.trim().toLowerCase());
    }
    for (final e in _customAdminEmails) {
      set.add(e.trim().toLowerCase());
    }
    return set.toList();
  }

  /// Inicializa o serviço carregando e-mails extras salvos e monitorando o status de autenticação
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_storageKey);
      if (stored != null && stored.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(stored);
        _customAdminEmails.clear();
        _customAdminEmails.addAll(decoded.map((e) => e.toString().trim().toLowerCase()));
      }
    } catch (e) {
      debugPrint('AdminService: Erro ao carregar administradores: $e');
    }

    // Verifica o usuário atual
    checkAdminStatus(FirebaseAuth.instance.currentUser);

    // Ouve alterações de login/logout
    FirebaseAuth.instance.authStateChanges().listen((user) {
      checkAdminStatus(user);
    });
  }

  /// Verifica se o usuário autenticado é um administrador
  bool checkAdminStatus(User? user) {
    if (user == null || user.email == null || user.email!.trim().isEmpty) {
      isAdminNotifier.value = false;
      return false;
    }

    final userEmail = user.email!.trim().toLowerCase();
    final isAllowed = allAdminEmails.contains(userEmail);

    isAdminNotifier.value = isAllowed;
    return isAllowed;
  }

  /// Adiciona um novo e-mail à lista de administradores
  Future<bool> addAdminEmail(String email) async {
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty || !normalized.contains('@')) {
      return false;
    }

    if (!allAdminEmails.contains(normalized)) {
      _customAdminEmails.add(normalized);
      await _persistCustomAdmins();
      checkAdminStatus(FirebaseAuth.instance.currentUser);
      return true;
    }
    return false;
  }

  /// Remove um e-mail da lista de administradores customizados
  Future<bool> removeAdminEmail(String email) async {
    final normalized = email.trim().toLowerCase();
    final removed = _customAdminEmails.remove(normalized);
    if (removed) {
      await _persistCustomAdmins();
      checkAdminStatus(FirebaseAuth.instance.currentUser);
      return true;
    }
    return false;
  }

  Future<void> _persistCustomAdmins() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(_customAdminEmails));
    } catch (e) {
      debugPrint('AdminService: Erro ao persistir administradores: $e');
    }
  }
}
