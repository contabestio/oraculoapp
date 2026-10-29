import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../config/admin_config.dart';
import '../services/admin_service.dart';
import '../theme/app_theme.dart';
import 'animations.dart';

/// Diálogo exclusivo para Administradores visualizarem e configurarem
/// outras contas com privilégios de Admin/Dev.
class AdminManagementDialog extends StatefulWidget {
  const AdminManagementDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const AdminManagementDialog(),
    );
  }

  @override
  State<AdminManagementDialog> createState() => _AdminManagementDialogState();
}

class _AdminManagementDialogState extends State<AdminManagementDialog> {
  final TextEditingController _emailController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _addAdmin() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _errorMessage = 'Por favor, insira um e-mail válido.';
      });
      return;
    }

    final success = await AdminService.instance.addAdminEmail(email);
    if (!mounted) return;

    if (success) {
      _emailController.clear();
      setState(() {
        _errorMessage = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('E-mail "$email" adicionado como Administrador!'),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'Este e-mail já é um administrador cadastrado.';
      });
    }
  }

  Future<void> _removeAdmin(String email) async {
    final success = await AdminService.instance.removeAdminEmail(email);
    if (!mounted) return;

    if (success) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('E-mail "$email" removido dos Administradores.'),
          backgroundColor: AppTheme.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    final defaultEmails = AdminConfig.defaultAdminEmails
        .map((e) => e.trim().toLowerCase())
        .toSet();
    final allAdmins = AdminService.instance.allAdminEmails;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabeçalho
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    color: Color(0xFF38BDF8),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contas de Administrador',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkText,
                        ),
                      ),
                      Text(
                        'Apenas admins podem inserir e editar livros',
                        style: TextStyle(fontSize: 12, color: AppTheme.mutedText),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.mutedText),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Informação do usuário atual
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.surfaceSoft,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_rounded, size: 18, color: AppTheme.darkPurple),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Logado como: $currentUserEmail',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkText,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'ADMIN',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Campo para adicionar novo admin
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontSize: 13, color: AppTheme.darkText),
                    decoration: InputDecoration(
                      hintText: 'Novo e-mail (ex: prof@escola.com)',
                      hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                      prefixIcon: const Icon(Icons.email_outlined, size: 18, color: AppTheme.orange),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      filled: true,
                      fillColor: AppTheme.surfaceSoft,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                BouncingPressable(
                  onTap: _addAdmin,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.orange,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 18),
                        SizedBox(width: 4),
                        Text(
                          'Adicionar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 6),
              Text(
                _errorMessage!,
                style: const TextStyle(color: AppTheme.deleteRed, fontSize: 11),
              ),
            ],
            const SizedBox(height: 16),

            // Lista de Administradores
            const Text(
              'Administradores Ativos:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: ListView.separated(
                itemCount: allAdmins.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final email = allAdmins[index];
                  final isCodeConfigured = defaultEmails.contains(email);

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified_user_rounded,
                          size: 16,
                          color: Color(0xFF38BDF8),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            email,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.darkText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isCodeConfigured
                                ? Colors.grey.shade200
                                : AppTheme.orangeBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isCodeConfigured ? 'Código' : 'Custom',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isCodeConfigured
                                  ? Colors.grey.shade700
                                  : AppTheme.orangeDark,
                            ),
                          ),
                        ),
                        if (!isCodeConfigured) ...[
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppTheme.deleteRed,
                              size: 18,
                            ),
                            onPressed: () => _removeAdmin(email),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),
            Center(
              child: Text(
                'Nota: E-mails marcados como "Código" estão definidos em admin_config.dart',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
