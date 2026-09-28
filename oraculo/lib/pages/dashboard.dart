import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dates_and_tasks.dart';
import 'notes_and_insights_page.dart';

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

      final User? user = credential.user;

      if (!mounted) return;

      setState(() {
        userName = user?.displayName?.trim().isNotEmpty == true
            ? user!.displayName!
            : 'Estudante';
        userPhotoUrl = user?.photoURL;
        showLogin = false;
        isProcessingAuth = false;
      });

      _clearAuthFields();
      _showMessage('Login realizado com sucesso!');
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
  // ATUALIZAR FOTO DO USUÁRIO
  // ==========================================================

  Future<void> _updateProfilePhotoDialog() async {
    final TextEditingController urlController = TextEditingController(text: userPhotoUrl);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Atualizar Foto de Perfil'),
          content: TextField(
            controller: urlController,
            decoration: const InputDecoration(
              hintText: 'Cole a URL da sua imagem',
              prefixIcon: Icon(Icons.link),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newUrl = urlController.text.trim();
                Navigator.pop(context);

                try {
                  await _auth.currentUser?.updatePhotoURL(newUrl.isEmpty ? null : newUrl);
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
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  // ==========================================================
  // NAVEGAÇÃO
  // ==========================================================

  void openCalendar() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DatesAndTasksPage()),
    );
  }

  void openNotes() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotesAndInsightsPage()),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFFAB8C)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ======================================================
          // CONTEÚDO PRINCIPAL
          // ======================================================
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 160),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // CABEÇALHO
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _updateProfilePhotoDialog,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: const Color(0xFFE4D1FF),
                              backgroundImage: (userPhotoUrl != null && userPhotoUrl!.isNotEmpty)
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
                                  color: Color(0xFFFFAB8C),
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
                                color: Color(0xFFFFAB8C),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userName,
                              style: const TextStyle(
                                color: Color(0xFFFFAB8C),
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _resetUser,
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: Color(0xFFFFAB8C),
                          size: 24,
                        ),
                        tooltip: 'Sair',
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // MEUS MATERIAIS
                  Container(
                    height: 470,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFAB8C),
                      borderRadius: BorderRadius.circular(55),
                    ),
                    child: Stack(
                      children: [
                        const Positioned(
                          top: 0,
                          left: 0,
                          child: Text(
                            'Meus Materiais >',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 3),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Coleção Oráculo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  height: 46,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'Ex: Matemática, Linguagens...',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Color(0xFF333333),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFFFAB8C),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.search,
                                          color: Colors.white,
                                          size: 19,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ==========================================================
          // BARRA INFERIOR
          // ==========================================================
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 145,
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 35),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _BottomButton(
                    icon: Icons.edit_note,
                    size: 70,
                    onTap: openNotes,
                  ),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE4D1FF),
                        width: 4,
                      ),
                    ),
                    child: const Icon(
                      Icons.crop_square,
                      color: Color(0xFFE4D1FF),
                      size: 58,
                    ),
                  ),
                  _BottomButton(
                    icon: Icons.calendar_month,
                    size: 70,
                    onTap: openCalendar,
                  ),
                ],
              ),
            ),
          ),

          // ==========================================================
          // SOBREPOSIÇÃO DE LOGIN / CADASTRO
          // ==========================================================
          if (showLogin)
            Positioned.fill(
              child: Container(
                color: Colors.white,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      width: 370,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFAB8C), Color(0xFFFFC2AD)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(24),
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

                          // MODO LOGIN
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
                              style: const TextStyle(color: Color(0xFF333333)),
                              decoration: InputDecoration(
                                hintText: 'E-mail',
                                prefixIcon: const Icon(Icons.email_outlined),
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
                              style: const TextStyle(color: Color(0xFF333333)),
                              decoration: InputDecoration(
                                hintText: 'Senha',
                                prefixIcon: const Icon(Icons.lock_outline),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: isProcessingAuth ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFFFFAB8C),
                                minimumSize: const Size(130, 45),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: isProcessingAuth
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFFFFAB8C),
                                      ),
                                    )
                                  : const Text(
                                      'Entrar',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
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
                          // MODO CADASTRO
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
                              style: const TextStyle(color: Color(0xFF333333)),
                              decoration: InputDecoration(
                                hintText: 'Seu nome',
                                prefixIcon: const Icon(Icons.person_outline),
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
                              style: const TextStyle(color: Color(0xFF333333)),
                              decoration: InputDecoration(
                                hintText: 'E-mail',
                                prefixIcon: const Icon(Icons.email_outlined),
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
                              style: const TextStyle(color: Color(0xFF333333)),
                              decoration: InputDecoration(
                                hintText: 'Senha (mín. 6 caracteres)',
                                prefixIcon: const Icon(Icons.lock_outline),
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
                              style: const TextStyle(color: Color(0xFF333333)),
                              decoration: InputDecoration(
                                hintText: 'URL da foto de perfil (opcional)',
                                prefixIcon: const Icon(Icons.image_outlined),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed:
                                  isProcessingAuth ? null : _createAccount,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFFFFAB8C),
                                minimumSize: const Size(130, 45),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: isProcessingAuth
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFFFFAB8C),
                                      ),
                                    )
                                  : const Text(
                                      'Cadastrar',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
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
            ),
        ],
      ),
    );
  }
}

// Widget auxiliar para os botões da barra inferior
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          color: const Color(0xFFFFAB8C),
          size: size * 0.6,
        ),
      ),
    );
  }
}