import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';
import '../widgets/animations.dart';
import '../widgets/book_cover_card.dart';
import 'dates_and_tasks.dart';
import 'notes_and_insights_page.dart';
import 'materials_page.dart';
import '../data/books_repository.dart';
import '../models/book_model.dart';
import '../services/admin_service.dart';
import '../widgets/admin_management_dialog.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'book_details_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // ==========================================================
  // FIREBASE
  // ==========================================================

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==========================================================
  // ESTADO
  // ==========================================================

  String userName = 'Estudante';
  String? userPhotoUrl;

  bool showLogin = false;
  bool isLoading = false;
  bool isCreatingAccount = false;
  bool isProcessingAuth = false;

  StreamSubscription<User?>? _authSubscription;

  // Busca de materiais
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // ==========================================================
  // CONTROLLERS
  // ==========================================================

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _photoController = TextEditingController();

  // ==========================================================
  // INIT & DISPOSE
  // ==========================================================

  @override
  void initState() {
    super.initState();
    _loadSavedUser();
    _authSubscription = _auth.authStateChanges().listen((user) {
      if (!mounted) return;
      AdminService.instance.checkAdminStatus(user);
      setState(() {
        if (user != null) {
          userName = user.displayName?.trim().isNotEmpty == true
              ? user.displayName!
              : 'Estudante';
          userPhotoUrl = user.photoURL;
          showLogin = false;
        } else {
          userName = 'Estudante';
          userPhotoUrl = null;
          showLogin = true;
        }
      });
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _photoController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ==========================================================
  // CARREGAR USUÁRIO DO FIREBASE
  // ==========================================================

  void _loadSavedUser() async {
    try {
      final User? user = _auth.currentUser;

      if (!mounted) return;

      if (user != null) {
        AdminService.instance.checkAdminStatus(user);
        setState(() {
          userName = user.displayName?.trim().isNotEmpty == true
              ? user.displayName!
              : (user.email?.split('@').first ?? 'Estudante');
          userPhotoUrl = user.photoURL;
          showLogin = false;
        });
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final bool isGuest = prefs.getBool('oraculo_guest_mode') ?? false;

      AdminService.instance.isAdminNotifier.value = false;
      setState(() {
        userName = 'Estudante';
        userPhotoUrl = null;
        showLogin = !isGuest;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        userName = 'Estudante';
        userPhotoUrl = null;
        showLogin = false;
      });
    }
  }

  // ==========================================================
  // CRIAR CONTA
  // ==========================================================

  Future<void> _createAccount() async {
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;
    final String photoUrl = _photoController.text.trim();

    if (name.isEmpty) {
      _showMessage('Digite seu nome.');
      return;
    }

    if (email.isEmpty) {
      _showMessage('Digite seu e-mail.');
      return;
    }

    if (password.isEmpty) {
      _showMessage('Digite uma senha.');
      return;
    }

    if (password.length < 6) {
      _showMessage('A senha precisa ter pelo menos 6 caracteres.');
      return;
    }

    setState(() {
      isProcessingAuth = true;
    });

    try {
      final UserCredential credential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await credential.user?.updateDisplayName(name);

      if (photoUrl.isNotEmpty) {
        await credential.user?.updatePhotoURL(photoUrl);
      }

      await credential.user?.reload();

      if (!mounted) return;

      final updatedUser = _auth.currentUser;
      AdminService.instance.checkAdminStatus(updatedUser);

      setState(() {
        userName = name;
        userPhotoUrl = updatedUser?.photoURL;
        showLogin = false;
        isProcessingAuth = false;
      });

      _clearAuthFields();
      _showMessage('Conta criada com sucesso!');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        isProcessingAuth = false;
      });
      _showFirebaseError(e);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isProcessingAuth = false;
      });
      _showMessage('Ocorreu um erro inesperado.');
    }
  }

  // ==========================================================
  // LOGIN
  // ==========================================================

  Future<void> _login() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    if (email.isEmpty) {
      _showMessage('Digite seu e-mail.');
      return;
    }

    if (password.isEmpty) {
      _showMessage('Digite sua senha.');
      return;
    }

    setState(() {
      isProcessingAuth = true;
    });

    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      final user = credential.user;
      AdminService.instance.checkAdminStatus(user);

      setState(() {
        userName = user?.displayName?.trim().isNotEmpty == true
            ? user!.displayName!
            : 'Estudante';
        userPhotoUrl = user?.photoURL;
        showLogin = false;
        isProcessingAuth = false;
      });

      _clearAuthFields();
      _showMessage('Bem-vindo(a) de volta!');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        isProcessingAuth = false;
      });
      _showFirebaseError(e);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isProcessingAuth = false;
      });
      _showMessage('Não foi possível entrar. Tente novamente.');
    }
  }

  // ==========================================================
  // LOGIN COM GOOGLE (MULTI-PLATAFORMA: WEB, WINDOWS, MOBILE)
  // ==========================================================

  Future<void> _loginWithGoogle() async {
    setState(() {
      isProcessingAuth = true;
    });

    try {
      UserCredential userCredential;

      if (kIsWeb) {
        // Navegador Web: usa signInWithPopup oficial do Firebase
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        userCredential = await _auth
            .signInWithPopup(googleProvider)
            .timeout(const Duration(seconds: 30));
      } else if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.windows ||
              defaultTargetPlatform == TargetPlatform.macOS ||
              defaultTargetPlatform == TargetPlatform.linux)) {
        // Desktop (Windows/macOS/Linux): tenta abrir navegador para autenticar com timeout
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        userCredential = await _auth
            .signInWithProvider(googleProvider)
            .timeout(const Duration(seconds: 15));
      } else {
        // Mobile (Android / iOS): usa o plugin nativo google_sign_in
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn
            .signIn()
            .timeout(const Duration(seconds: 25));

        if (googleUser == null) {
          // Usuário fechou a janela de seleção de conta do Google
          if (!mounted) return;
          setState(() {
            isProcessingAuth = false;
          });
          return;
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await _auth
            .signInWithCredential(credential)
            .timeout(const Duration(seconds: 20));
      }

      if (!mounted) return;

      final user = userCredential.user;
      AdminService.instance.checkAdminStatus(user);

      setState(() {
        userName = user?.displayName?.trim().isNotEmpty == true
            ? user!.displayName!
            : (user?.email?.split('@').first ?? 'Estudante');
        userPhotoUrl = user?.photoURL;
        showLogin = false;
        isProcessingAuth = false;
      });

      _clearAuthFields();
      _showMessage('Bem-vindo(a), $userName!');
    } on TimeoutException {
      if (!mounted) return;
      _showMessage(
        'Tempo limite de autenticação excedido. No Desktop, entre com seu E-mail e Senha.',
        isError: true,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showFirebaseError(e);
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      if (!mounted) return;

      final errorString = e.toString();
      if (errorString.contains('10') ||
          errorString.contains('developer_error') ||
          errorString.contains('ApiException')) {
        _showMessage(
          'Configuração do Google no Firebase incompleta (adicione a chave SHA-1 do app no Console do Firebase).',
        );
      } else if (errorString.contains('unimplemented') ||
          errorString.contains('MissingPluginException')) {
        _showMessage(
          'Login com Google indisponível nesta plataforma desktop. Entre com seu e-mail e senha abaixo.',
        );
      } else {
        _showMessage('Não foi possível entrar com o Google: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          isProcessingAuth = false;
        });
      }
    }
  }

  // ==========================================================
  // DIÁLOGO DE ATUALIZAÇÃO DE FOTO
  // ==========================================================

  void _updateProfilePhotoDialog() {
    final TextEditingController urlController =
        TextEditingController(text: userPhotoUrl ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Atualizar Foto de Perfil',
            style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: urlController,
            style: const TextStyle(color: AppTheme.darkText),
            decoration: const InputDecoration(
              hintText: 'Cole a URL da sua imagem',
              prefixIcon: Icon(Icons.link, color: AppTheme.orange),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: AppTheme.darkText)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final newUrl = urlController.text.trim();
                Navigator.pop(context);

                try {
                  await _auth.currentUser
                      ?.updatePhotoURL(newUrl.isEmpty ? null : newUrl);
                  await _auth.currentUser?.reload();

                  if (!mounted) return;
                  setState(() {
                    userPhotoUrl = _auth.currentUser?.photoURL;
                  });
                  _showMessage('Foto atualizada!');
                } catch (e) {
                  _showMessage('Erro ao atualizar foto.');
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // LOGOUT
  // ==========================================================

  Future<void> _resetUser() async {
    try {
      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS)) {
        try {
          await GoogleSignIn().signOut();
        } catch (_) {}
      }
      await _auth.signOut();
      AdminService.instance.isAdminNotifier.value = false;

      if (!mounted) return;

      _clearAuthFields();

      setState(() {
        userName = 'Estudante';
        userPhotoUrl = null;
        showLogin = true;
      });
    } catch (e) {
      _showMessage('Não foi possível sair da conta.');
    }
  }

  void _clearAuthFields() {
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _photoController.clear();
  }

  // ==========================================================
  // MENSAGENS E ERROS
  // ==========================================================

  void _showFirebaseError(FirebaseAuthException e) {
    String message;

    switch (e.code) {
      case 'operation-not-allowed':
        message =
            'O login com Google não está ativado no Firebase. Acesse o Console do Firebase > Authentication > Sign-in method e ative o provedor Google.';
        break;
      case 'popup-closed-by-user':
      case 'canceled':
        message = 'Login com o Google cancelado.';
        break;
      case 'account-exists-with-different-credential':
        message =
            'Já existe uma conta com este e-mail usando outro método de login.';
        break;
      case 'email-already-in-use':
        message = 'Este e-mail já está cadastrado.';
        break;
      case 'invalid-email':
        message = 'Digite um e-mail válido.';
        break;
      case 'weak-password':
        message = 'A senha é muito fraca.';
        break;
      case 'user-not-found':
        message = 'Não existe uma conta com este e-mail.';
        break;
      case 'wrong-password':
      case 'invalid-credential':
        message = 'E-mail ou senha incorretos.';
        break;
      case 'too-many-requests':
        message = 'Muitas tentativas. Tente novamente mais tarde.';
        break;
      case 'network-request-failed':
        message = 'Verifique sua conexão com a internet.';
        break;
      default:
        message = e.message ?? 'Erro de autenticação.';
    }

    _showMessage(message);
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? const Color(0xFFFF6B6B) : const Color(0xFF594A6D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // ==========================================================
  // NAVEGAÇÃO COM TRANSIÇÃO SUAVE
  // ==========================================================

  void openCalendar() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const DatesAndTasksPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curveAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curveAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.04, 0),
                end: Offset.zero,
              ).animate(curveAnimation),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void openNotes() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const NotesAndInsightsPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curveAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curveAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-0.04, 0),
                end: Offset.zero,
              ).animate(curveAnimation),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void openMaterials([String query = '']) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            MaterialsPage(initialQuery: query),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curveAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curveAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.04, 0),
                end: Offset.zero,
              ).animate(curveAnimation),
              child: child,
            ),
          );
        },
      ),
    );
  }

  // ==========================================================
  // BUILD PRINCIPAL
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.orange),
        ),
      );
    }

    return ValueListenableBuilder<List<BookModel>>(
      valueListenable: BooksRepository.instance.booksNotifier,
      builder: (context, allBooks, _) {
        final filteredMaterials = allBooks.where((m) {
          return _searchQuery.isEmpty ||
              m.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              m.category.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              // ======================================================
              // CONTEÚDO PRINCIPAL COM ANIMAÇÃO DE ENTRADA
              // ======================================================
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 160),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // CABEÇALHO DO PERFIL COM CORES ORIGINAIS E ANIMAÇÃO
                      FadeSlideTransition(
                        delay: const Duration(milliseconds: 100),
                        child: _buildHeader(),
                      ),

                      const SizedBox(height: 32),

                      // CONTAINER PRINCIPAL: MEUS MATERIAIS
                      FadeSlideTransition(
                        delay: const Duration(milliseconds: 200),
                        child: _buildMaterialsContainer(filteredMaterials),
                      ),
                    ],
                  ),
                ),
              ),

              // ======================================================
              // BARRA INFERIOR ORIGINAL COM ANIMAÇÃO DE TOQUE
              // ======================================================
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: FadeSlideTransition(
                  delay: const Duration(milliseconds: 300),
                  direction: SlideDirection.up,
                  child: _buildBottomNav(),
                ),
              ),

              // ======================================================
              // SOBREPOSIÇÃO DE LOGIN / CADASTRO ORIGINAL
              // ======================================================
              if (showLogin)
                Positioned.fill(
                  child: _buildAuthOverlay(),
                ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================
  // CABEÇALHO COM ANIMAÇÃO E CORES ORIGINAIS
  // ==========================================================

  Widget _buildHeader() {
    return Row(
      children: [
        BouncingPressable(
          onTap: _updateProfilePhotoDialog,
          child: Stack(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppTheme.lilac,
                backgroundImage:
                    (userPhotoUrl != null && userPhotoUrl!.isNotEmpty)
                        ? NetworkImage(userPhotoUrl!)
                        : null,
                child: (userPhotoUrl == null || userPhotoUrl!.isEmpty)
                    ? Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'E',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppTheme.orange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bem-vindo(a) ao Oráculo',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  color: AppTheme.orange,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                userName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.orange,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: AdminService.instance.isAdminNotifier,
          builder: (context, isAdmin, _) {
            if (!isAdmin) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: BouncingPressable(
                onTap: () => AdminManagementDialog.show(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield_outlined, color: Color(0xFF38BDF8), size: 16),
                      SizedBox(width: 4),
                      Text(
                        'ADMIN',
                        style: TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        BouncingPressable(
          onTap: _auth.currentUser == null
              ? () => setState(() => showLogin = true)
              : _resetUser,
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              _auth.currentUser == null
                  ? Icons.login_rounded
                  : Icons.logout_rounded,
              color: AppTheme.orange,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // SEÇÃO MEUS MATERIAIS COM ANIMAÇÃO E CORES ORIGINAIS
  // ==========================================================

  Widget _buildMaterialsContainer(List<BookModel> filteredMaterials) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.orange,
        borderRadius: BorderRadius.circular(55),
        boxShadow: [
          BoxShadow(
            color: AppTheme.orange.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BouncingPressable(
            onTap: () => openMaterials(),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Meus Materiais >',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Carrossel de Livros com efeito 3D
          SizedBox(
            height: 205,
            child: filteredMaterials.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum material encontrado.',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: filteredMaterials.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final item = filteredMaterials[index];
                    return SizedBox(
                      width: 125,
                      child: BookCoverCard(
                        title: item.title,
                        imageUrl: item.imageUrl,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookDetailsPage(initialBook: item),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
          ),

          const SizedBox(height: 20),

          // Caixa da Coleção Oráculo com Campo de Busca
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 3),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BouncingPressable(
                  onTap: () => openMaterials(),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Coleção Oráculo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (val) {
                            openMaterials(val.trim());
                          },
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val.trim();
                            });
                          },
                          style: const TextStyle(
                            color: AppTheme.darkText,
                            fontSize: 13,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Ex: Matemática, Linguagens...',
                            hintStyle: TextStyle(
                              color: AppTheme.orange,
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      BouncingPressable(
                        onTap: () {
                          openMaterials(_searchController.text.trim());
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: AppTheme.orange,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 19,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // BARRA INFERIOR ORIGINAL COM SÍMBOLOS E CORES EXATAS
  // ==========================================================

  Widget _buildBottomNav() {
    return Container(
      height: 145,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 35),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Botão Notas (Ícone original: edit_note)
          _BottomButton(
            icon: Icons.edit_note,
            size: 70,
            onTap: openNotes,
          ),

          // Botão Central Original (Ícone original: crop_square com anel lilás)
          BouncingPressable(
            onTap: () {
              // Ação central
              openCalendar();
            },
            scaleFactor: 0.94,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.lilac,
                  width: 4,
                ),
              ),
              child: const Icon(
                Icons.crop_square,
                color: AppTheme.lilac,
                size: 58,
              ),
            ),
          ),

          // Botão Calendário (Ícone original: calendar_month)
          _BottomButton(
            icon: Icons.calendar_month,
            size: 70,
            onTap: openCalendar,
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // TELA DE LOGIN / CADASTRO COM ANIMAÇÃO E CORES ORIGINAIS
  // ==========================================================

  Widget _buildAuthOverlay() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          physics: const BouncingScrollPhysics(),
          child: FadeSlideTransition(
            duration: const Duration(milliseconds: 350),
            child: Container(
              width: 370,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: AppTheme.orangeGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Bem-vindo(a) ao Oráculo',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // MODO LOGIN COM ANIMAÇÃO
                  if (!isCreatingAccount) ...[
                    const Text(
                      'Entre na sua conta',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: AppTheme.darkText),
                      decoration: InputDecoration(
                        hintText: 'E-mail',
                        prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.orange),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(color: AppTheme.darkText),
                      decoration: InputDecoration(
                        hintText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.orange),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    BouncingPressable(
                      onTap: isProcessingAuth ? null : _login,
                      child: Container(
                        height: 45,
                        width: 130,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: isProcessingAuth
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.orange,
                                ),
                              )
                            : const Text(
                                'Entrar',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppTheme.orange,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: isProcessingAuth
                          ? null
                          : () {
                              setState(() {
                                isCreatingAccount = true;
                              });
                            },
                      child: const Text(
                        'Criar uma conta',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ]
                  // MODO CADASTRO COM ANIMAÇÃO
                  else ...[
                    const Text(
                      'Crie sua conta',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(color: AppTheme.darkText),
                      decoration: InputDecoration(
                        hintText: 'Seu nome',
                        prefixIcon: const Icon(Icons.person_outline, color: AppTheme.orange),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: AppTheme.darkText),
                      decoration: InputDecoration(
                        hintText: 'E-mail',
                        prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.orange),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(color: AppTheme.darkText),
                      decoration: InputDecoration(
                        hintText: 'Senha (mín. 6 caracteres)',
                        prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.orange),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _photoController,
                      keyboardType: TextInputType.url,
                      style: const TextStyle(color: AppTheme.darkText),
                      decoration: InputDecoration(
                        hintText: 'URL da foto de perfil (opcional)',
                        prefixIcon: const Icon(Icons.image_outlined, color: AppTheme.orange),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    BouncingPressable(
                      onTap: isProcessingAuth ? null : _createAccount,
                      child: Container(
                        height: 45,
                        width: 130,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: isProcessingAuth
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.orange,
                                ),
                              )
                            : const Text(
                                'Cadastrar',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppTheme.orange,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: isProcessingAuth
                          ? null
                          : () {
                              setState(() {
                                isCreatingAccount = false;
                              });
                            },
                      child: const Text(
                        'Já possui uma conta? Entre',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],

                  // ====================================================
                  // DIVISOR & ENTRAR COM O GOOGLE
                  // ====================================================
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.white.withValues(alpha: 0.5),
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'ou',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.white.withValues(alpha: 0.5),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // BOTÃO GOOGLE SIGN-IN
                  BouncingPressable(
                    onTap: isProcessingAuth ? null : _loginWithGoogle,
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isProcessingAuth) ...[
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.orange,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Conectando com o Google...',
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ] else ...[
                            Container(
                              width: 26,
                              height: 26,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFF1F5F9),
                              ),
                              child: const Text(
                                'G',
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: Color(0xFF4285F4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Entrar com o Google',
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: isProcessingAuth
                        ? null
                        : () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('oraculo_guest_mode', true);
                            if (!mounted) return;
                            setState(() {
                              showLogin = false;
                            });
                          },
                    child: Text(
                      'Continuar como Convidado (modo offline)',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Widget auxiliar para os botões da barra inferior com animação
class _BottomButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onTap;

  const _BottomButton({
    required this.icon,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingPressable(
      onTap: onTap,
      scaleFactor: 0.90,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          color: AppTheme.orange,
          size: size * 0.6,
        ),
      ),
    );
  }
}