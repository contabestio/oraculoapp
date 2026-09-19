import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dates_and_tasks.dart';
import 'notes_and_insights_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String userName = 'Estudante';
  bool showLogin = false;
  bool isLoading = true;

  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ==========================================================
  // CARREGAR NOME SALVO
  // ==========================================================

  Future<void> _loadSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedName = prefs.getString('user_name');

    setState(() {
      if (savedName != null && savedName.trim().isNotEmpty) {
        userName = savedName;
        showLogin = false;
      } else {
        userName = 'Estudante';
        showLogin = true;
      }
      isLoading = false;
    });
  }

  // ==========================================================
  // SALVAR NOVO NOME
  // ==========================================================

  Future<void> _saveUser(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final String trimmedName = name.trim().isEmpty ? 'Estudante' : name.trim();

    await prefs.setString('user_name', trimmedName);

    setState(() {
      userName = trimmedName;
      showLogin = false;
    });
  }

  // ==========================================================
  // REDEFINIR NOME / LOGOUT
  // ==========================================================

  Future<void> _resetUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');

    setState(() {
      _nameController.clear();
      showLogin = true;
    });
  }

  // ==========================================================
  // NAVEGAÇÃO
  // ==========================================================

  void openCalendar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DatesAndTasksPage(),
      ),
    );
  }

  void openNotes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotesAndInsightsPage(),
      ),
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
          child: CircularProgressIndicator(
            color: Color(0xFFFFAB8C),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                24,
                24,
                24,
                160,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ==================================================
                  // CABEÇALHO
                  // ==================================================

                  Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE4D1FF),
                          shape: BoxShape.circle,
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bem, Vindo(a) ao Oráculo',
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

                      // Botão para redefinir e abrir a tela de login novamente
                      IconButton(
                        onPressed: _resetUser,
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: Color(0xFFFFAB8C),
                          size: 24,
                        ),
                        tooltip: 'Redefinir Login',
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // ==================================================
                  // MEUS MATERIAIS
                  // ==================================================

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

                        // ==================================================
                        // CAIXA DE BUSCA
                        // ==================================================

                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
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
              padding: const EdgeInsets.fromLTRB(
                24,
                10,
                24,
                35,
              ),
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
          // DIÁLOGO DE LOGIN
          // ==========================================================

          if (showLogin)
            Positioned.fill(
              child: Container(
                color: Colors.white,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      width: 370,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFFAB8C),
                            Color(0xFFFFC2AD),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Bem Vinde ao Oráculo',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 28),

                          const Text(
                            'Por favor digite seu nome:',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),

                          const SizedBox(height: 12),

                          TextField(
                            controller: _nameController,
                            style: const TextStyle(color: Color(0xFF333333)),
                            decoration: InputDecoration(
                              hintText: 'Insira aqui',
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
                            onPressed: () {
                              _saveUser(_nameController.text);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFFFFAB8C),
                              minimumSize: const Size(110, 45),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Entrar',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
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

// ============================================================
// BOTÃO INFERIOR
// ============================================================

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
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFFFAB8C),
            width: 3,
          ),
        ),
        child: Icon(
          icon,
          color: const Color(0xFFFFAB8C),
          size: 38,
        ),
      ),
    );
  }
}