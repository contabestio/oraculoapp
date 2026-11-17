import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'admin_service.dart';
import 'simulado_score_service.dart';

/// Representa os dados resumidos do perfil da conta atual.
class AccountProfile {
  final String? uid;
  final String displayName;
  final String? email;
  final String? photoUrl;
  final bool isGuest;
  final bool hasPasswordProvider;
  final bool hasGoogleProvider;

  const AccountProfile({
    this.uid,
    required this.displayName,
    this.email,
    this.photoUrl,
    required this.isGuest,
    this.hasPasswordProvider = false,
    this.hasGoogleProvider = false,
  });

  const AccountProfile.guest()
      : uid = null,
        displayName = 'Estudante',
        email = null,
        photoUrl = null,
        isGuest = true,
        hasPasswordProvider = false,
        hasGoogleProvider = false;

  AccountProfile copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoUrl,
    bool clearPhotoUrl = false,
    bool? isGuest,
    bool? hasPasswordProvider,
    bool? hasGoogleProvider,
  }) {
    return AccountProfile(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: clearPhotoUrl ? null : (photoUrl ?? this.photoUrl),
      isGuest: isGuest ?? this.isGuest,
      hasPasswordProvider: hasPasswordProvider ?? this.hasPasswordProvider,
      hasGoogleProvider: hasGoogleProvider ?? this.hasGoogleProvider,
    );
  }
}

/// Exceção padronizada para operações de gerenciamento de conta.
class AccountOperationException implements Exception {
  final String code;
  final String message;

  const AccountOperationException({
    required this.code,
    required this.message,
  });

  bool get requiresRecentLogin => code == 'requires-recent-login';

  @override
  String toString() => message;
}

/// Contrato de serviço para gerenciamento da conta do usuário.
abstract class AccountService {
  AccountProfile getCurrentProfile();
  Future<AccountProfile> updateDisplayName(String newName);
  Future<AccountProfile> updatePhotoUrl(String? photoUrl);
  Future<void> sendPasswordResetEmail(String email);
  Future<void> deleteAccount({String? password});
}

/// Implementação padrão utilizando Firebase Authentication e Cloud Firestore.
class FirebaseAccountService implements AccountService {
  FirebaseAccountService._();
  static final FirebaseAccountService instance = FirebaseAccountService._();

  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  @override
  AccountProfile getCurrentProfile() {
    final user = _auth?.currentUser;
    if (user == null) {
      return const AccountProfile.guest();
    }

    final providerIds = user.providerData.map((p) => p.providerId).toSet();
    final resolvedName = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : (user.email?.split('@').first ?? 'Estudante');

    return AccountProfile(
      uid: user.uid,
      displayName: resolvedName,
      email: user.email,
      photoUrl: user.photoURL,
      isGuest: false,
      hasPasswordProvider: providerIds.contains('password'),
      hasGoogleProvider: providerIds.contains('google.com'),
    );
  }

  @override
  Future<AccountProfile> updateDisplayName(String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) {
      throw const AccountOperationException(
        code: 'invalid-name',
        message: 'Digite um nome válido.',
      );
    }

    final auth = _auth;
    final user = auth?.currentUser;
    if (user == null) {
      throw const AccountOperationException(
        code: 'no-user',
        message: 'Nenhuma conta conectada no momento.',
      );
    }

    try {
      await user.updateDisplayName(trimmed);
      await user.reload();
      return getCurrentProfile();
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    } catch (_) {
      throw const AccountOperationException(
        code: 'update-name-failed',
        message: 'Não foi possível atualizar o seu nome. Tente novamente.',
      );
    }
  }

  @override
  Future<AccountProfile> updatePhotoUrl(String? photoUrl) async {
    final auth = _auth;
    final user = auth?.currentUser;
    if (user == null) {
      throw const AccountOperationException(
        code: 'no-user',
        message: 'Nenhuma conta conectada no momento.',
      );
    }

    final normalized = photoUrl?.trim();
    final valueToSave =
        (normalized == null || normalized.isEmpty) ? null : normalized;

    try {
      await user.updatePhotoURL(valueToSave);
      await user.reload();
      return getCurrentProfile();
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    } catch (_) {
      throw const AccountOperationException(
        code: 'update-photo-failed',
        message: 'Não foi possível atualizar a foto de perfil. Tente novamente.',
      );
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      throw const AccountOperationException(
        code: 'invalid-email',
        message: 'Nenhum e-mail válido encontrado para esta conta.',
      );
    }

    final auth = _auth;
    if (auth == null) {
      throw const AccountOperationException(
        code: 'auth-unavailable',
        message: 'Serviço de autenticação indisponível no momento.',
      );
    }

    try {
      await auth.sendPasswordResetEmail(email: trimmedEmail);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    } catch (_) {
      throw const AccountOperationException(
        code: 'password-reset-failed',
        message:
            'Não foi possível enviar o e-mail de redefinição de senha. Tente novamente.',
      );
    }
  }

  @override
  Future<void> deleteAccount({String? password}) async {
    final auth = _auth;
    final user = auth?.currentUser;
    if (user == null) {
      throw const AccountOperationException(
        code: 'no-user',
        message: 'Nenhuma conta conectada no momento.',
      );
    }

    final providerIds = user.providerData.map((p) => p.providerId).toSet();
    final hasPassword = providerIds.contains('password');
    final hasGoogle = providerIds.contains('google.com');

    try {
      // 1. Se possui login por e-mail e senha, exige e valida a senha atual antes de remover dados.
      if (hasPassword) {
        if (password == null || password.isEmpty) {
          throw const AccountOperationException(
            code: 'password-required',
            message: 'Digite sua senha atual para confirmar a exclusão.',
          );
        }
        final email = user.email;
        if (email == null || email.isEmpty) {
          throw const AccountOperationException(
            code: 'invalid-email',
            message: 'Não foi possível validar o e-mail da conta.',
          );
        }
        final credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      } else if (hasGoogle) {
        // Para contas Google, tenta reautenticar antes de excluir os dados.
        await _tryReauthenticateWithGoogle(user);
      }

      // 2. Remove dados do usuário no Firestore enquanto ainda autenticado.
      await _deleteUserFirestoreData(user.uid);

      // 3. Exclui a conta no Firebase Auth.
      await user.delete();

      // 4. Limpeza de estado local e provedores auxiliares.
      await _cleanupLocalSession();
    } on AccountOperationException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    } catch (_) {
      throw const AccountOperationException(
        code: 'delete-account-failed',
        message: 'Não foi possível excluir sua conta. Tente novamente.',
      );
    }
  }

  Future<bool> _tryReauthenticateWithGoogle(User user) async {
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        provider.addScope('email');
        provider.addScope('profile');
        await user
            .reauthenticateWithPopup(provider)
            .timeout(const Duration(seconds: 30));
        return true;
      } else if (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux) {
        final provider = GoogleAuthProvider();
        provider.addScope('email');
        provider.addScope('profile');
        await user
            .reauthenticateWithProvider(provider)
            .timeout(const Duration(seconds: 15));
        return true;
      } else {
        final googleSignIn = GoogleSignIn();
        final googleUser =
            await googleSignIn.signIn().timeout(const Duration(seconds: 25));
        if (googleUser == null) {
          throw const AccountOperationException(
            code: 'reauth-cancelled',
            message: 'Reautenticação cancelada. A conta não foi excluída.',
          );
        }

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await user
            .reauthenticateWithCredential(credential)
            .timeout(const Duration(seconds: 20));
        return true;
      }
    } on AccountOperationException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'popup-closed-by-user' || e.code == 'canceled') {
        throw const AccountOperationException(
          code: 'reauth-cancelled',
          message: 'Reautenticação cancelada. A conta não foi excluída.',
        );
      }
      debugPrint('FirebaseAccountService: Google reauth FirebaseAuthException: $e');
      return false;
    } catch (e) {
      debugPrint('FirebaseAccountService: Google reauth error: $e');
      return false;
    }
  }

  Future<void> _deleteUserFirestoreData(String uid) async {
    final firestore = _firestore;
    if (firestore == null) return;

    final userDoc = firestore.collection('users').doc(uid);
    const subcollections = ['notes', 'tasks', 'simulado_scores'];

    for (final sub in subcollections) {
      try {
        final snapshot = await userDoc.collection(sub).get();
        if (snapshot.docs.isNotEmpty) {
          final batch = firestore.batch();
          for (final doc in snapshot.docs) {
            batch.delete(doc.reference);
          }
          await batch.commit();
        }
      } catch (e) {
        debugPrint(
          'FirebaseAccountService: Erro ao limpar subcoleção $sub: $e',
        );
      }
    }

    try {
      await userDoc.delete();
    } catch (e) {
      debugPrint('FirebaseAccountService: Erro ao remover doc users/$uid: $e');
    }
  }

  Future<void> _cleanupLocalSession() async {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      try {
        await GoogleSignIn().signOut();
      } catch (_) {}
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('oraculo_guest_mode', false);
    } catch (_) {}

    AdminService.instance.isAdminNotifier.value = false;
    SimuladoScoreService.instance.scoresNotifier.value = [];
  }

  AccountOperationException _mapFirebaseError(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'wrong-password':
      case 'invalid-credential':
        message = 'Senha incorreta. Verifique e tente novamente.';
        break;
      case 'requires-recent-login':
        message =
            'Por segurança, faça login novamente antes de excluir sua conta.';
        break;
      case 'too-many-requests':
        message = 'Muitas tentativas. Aguarde alguns instantes e tente novamente.';
        break;
      case 'network-request-failed':
        message = 'Sem conexão com a internet. Verifique sua rede.';
        break;
      case 'invalid-email':
        message = 'Endereço de e-mail inválido.';
        break;
      case 'user-not-found':
        message = 'Conta não encontrada.';
        break;
      default:
        message = e.message ?? 'Erro ao processar operação da conta.';
    }

    return AccountOperationException(code: e.code, message: message);
  }
}
