import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/app_theme.dart';
import '../widgets/animations.dart';
import '../widgets/book_cover_card.dart';
import 'dates_and_tasks.dart';
import 'notes_and_insights_page.dart';
import 'materials_page.dart';

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
  bool isLoading = true;
  bool isCreatingAccount = false;
  bool isProcessingAuth = false;

  // Busca de materiais
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Lista de materiais de estudo com as capas do projeto
  final List<Map<String, String>> _allMaterials = [
    {
      'title': 'Redação',
      'image': 'https://images.unsplash.com/photo-1455390582262-044cdead277a?w=400&q=80',
    },
    {
      'title': 'Matemática',
      'image': 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=400&q=80',
    },
    {
      'title': 'Linguagens',
      'image': 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&q=80',
    },
    {
      'title': 'Ciências',
      'image': 'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=400&q=80',
    },
  ];

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
  }

  @override
  void dispose() {
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

  Future<void> _loadSavedUser() async {
    try {
      final User? user = _auth.currentUser;

      if (!mounted) return;

      if (user != null) {
        setState(() {
          userName = user.displayName?.trim().isNotEmpty == true
              ? user.displayName!
              : 'Estudante';
          userPhotoUrl = user.photoURL;
          showLogin = false;
          isLoading = false;
        });
      } else {
        setState(() {
          userName = 'Estudante';
          userPhotoUrl = null;
          showLogin = true;
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        userName = 'Estudante';
        userPhotoUrl = null;
        showLogin = true;
        isLoading = false;
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
      await _auth.signOut();

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

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
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

    final filteredMaterials = _allMaterials.where((m) {
      return _searchQuery.isEmpty ||
          (m['title']?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
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
        BouncingPressable(
          onTap: _resetUser,
          child: Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(
              Icons.logout_rounded,
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

  Widget _buildMaterialsContainer(List<Map<String, String>> filteredMaterials) {
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
                        title: item['title'] ?? '',
                        imageUrl: item['image'] ?? '',
                        onTap: () {
                          openMaterials(item['title'] ?? '');
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