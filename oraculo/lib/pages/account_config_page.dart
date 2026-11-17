import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/account_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animations.dart';

/// Resultado retornado pela tela de Configurações da Conta ao Dashboard.
enum AccountConfigAction {
  updated,
  deleted,
  openLogin,
}

class AccountConfigPage extends StatefulWidget {
  final AccountService? accountService;
  final VoidCallback? onProfileUpdated;

  const AccountConfigPage({
    super.key,
    this.accountService,
    this.onProfileUpdated,
  });

  @override
  State<AccountConfigPage> createState() => _AccountConfigPageState();
}

class _AccountConfigPageState extends State<AccountConfigPage> {
  late final AccountService _accountService;
  late AccountProfile _profile;
  late final TextEditingController _nameController;

  bool _isSavingName = false;
  bool _isSendingReset = false;
  bool _isDeletingAccount = false;
  bool _hasUpdatedProfile = false;

  @override
  void initState() {
    super.initState();
    _accountService = widget.accountService ?? FirebaseAccountService.instance;
    _profile = _accountService.getCurrentProfile();
    _nameController = TextEditingController(text: _profile.displayName);
    _nameController.addListener(_onNameInputChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameInputChanged);
    _nameController.dispose();
    super.dispose();
  }

  void _onNameInputChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  bool get _canSaveName {
    final trimmed = _nameController.text.trim();
    return !_isSavingName &&
        !_isDeletingAccount &&
        trimmed.isNotEmpty &&
        trimmed != _profile.displayName.trim();
  }

  String get _providerLabel {
    if (_profile.isGuest) return 'Modo Convidado';
    if (_profile.hasGoogleProvider && _profile.hasPasswordProvider) {
      return 'Google e E-mail';
    }
    if (_profile.hasGoogleProvider) return 'Conta Google';
    return 'E-mail e Senha';
  }

  // ==========================================================
  // AÇÕES DA CONTA
  // ==========================================================

  Future<void> _saveName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      _showFeedback('Digite um nome válido.', isError: true);
      return;
    }

    if (newName == _profile.displayName.trim()) {
      _showFeedback('Seu nome já está atualizado.');
      return;
    }

    setState(() {
      _isSavingName = true;
    });

    try {
      final updated = await _accountService.updateDisplayName(newName);
      if (!mounted) return;

      setState(() {
        _profile = updated;
        _nameController.text = updated.displayName;
        _isSavingName = false;
        _hasUpdatedProfile = true;
      });

      widget.onProfileUpdated?.call();
      _showFeedback('Nome atualizado com sucesso!');
    } on AccountOperationException catch (e) {
      if (!mounted) return;
      setState(() {
        _isSavingName = false;
      });
      _showFeedback(e.message, isError: true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSavingName = false;
      });
      _showFeedback('Erro ao atualizar o nome. Tente novamente.', isError: true);
    }
  }

  Future<void> _openEditPhotoDialog() async {
    if (_profile.isGuest || _isDeletingAccount) return;

    final updatedProfile = await showDialog<AccountProfile>(
      context: context,
      builder: (dialogContext) {
        return _EditProfilePhotoDialog(
          initialUrl: _profile.photoUrl ?? '',
          onSavePhoto: (newUrl) => _accountService.updatePhotoUrl(newUrl),
        );
      },
    );

    if (updatedProfile == null || !mounted) return;

    final removed =
        updatedProfile.photoUrl == null || updatedProfile.photoUrl!.isEmpty;
    setState(() {
      _profile = updatedProfile;
      _hasUpdatedProfile = true;
    });
    widget.onProfileUpdated?.call();
    _showFeedback(
      removed ? 'Foto de perfil removida!' : 'Foto de perfil atualizada!',
    );
  }

  Future<void> _copyEmail() async {
    final email = _profile.email?.trim() ?? '';
    if (email.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: email));
    if (!mounted) return;
    _showFeedback('E-mail copiado para a área de transferência!');
  }

  Future<void> _confirmAndSendPasswordReset() async {
    final email = _profile.email?.trim() ?? '';
    if (email.isEmpty) {
      _showFeedback(
        'Nenhum e-mail vinculado a esta conta para redefinir a senha.',
        isError: true,
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(Icons.lock_reset_rounded, color: AppTheme.darkPurple),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Redefinir senha',
                  style: TextStyle(
                    color: AppTheme.darkText,
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enviaremos um link para redefinir sua senha para o e-mail:',
                style: TextStyle(color: AppTheme.lightText, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.orangeBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  email,
                  style: const TextStyle(
                    color: AppTheme.darkText,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Verifique também sua caixa de spam caso não encontre a mensagem.',
                style: TextStyle(color: AppTheme.mutedText, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppTheme.mutedText),
              ),
            ),
            ElevatedButton(
              key: const Key('confirm_password_reset_button'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.darkPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Enviar e-mail'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isSendingReset = true;
    });

    try {
      await _accountService.sendPasswordResetEmail(email);
      if (!mounted) return;
      setState(() {
        _isSendingReset = false;
      });
      _showFeedback(
        'E-mail de redefinição de senha enviado para $email!',
      );
    } on AccountOperationException catch (e) {
      if (!mounted) return;
      setState(() {
        _isSendingReset = false;
      });
      _showFeedback(e.message, isError: true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSendingReset = false;
      });
      _showFeedback(
        'Não foi possível solicitar a redefinição de senha.',
        isError: true,
      );
    }
  }

  Future<void> _confirmAndDeleteAccount() async {
    final deleted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _DeleteAccountDialog(
          needsPassword: _profile.hasPasswordProvider,
          onConfirmDelete: (password) async {
            if (mounted) {
              setState(() {
                _isDeletingAccount = true;
              });
            }
            try {
              await _accountService.deleteAccount(password: password);
            } catch (_) {
              if (mounted) {
                setState(() {
                  _isDeletingAccount = false;
                });
              }
              rethrow;
            }
          },
        );
      },
    );

    if (deleted == true && mounted) {
      Navigator.of(context).pop(AccountConfigAction.deleted);
    }
  }

  void _showFeedback(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.deleteRed : AppTheme.darkPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _handleBack() {
    Navigator.of(context).pop(
      _hasUpdatedProfile ? AccountConfigAction.updated : null,
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _handleBack();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FadeSlideTransition(
                        delay: const Duration(milliseconds: 60),
                        child: _buildProfileHeroCard(),
                      ),
                      const SizedBox(height: 24),
                      if (_profile.isGuest)
                        FadeSlideTransition(
                          delay: const Duration(milliseconds: 140),
                          child: _buildGuestCard(),
                        )
                      else ...[
                        FadeSlideTransition(
                          delay: const Duration(milliseconds: 140),
                          child: _buildAccountInfoCard(),
                        ),
                        const SizedBox(height: 20),
                        FadeSlideTransition(
                          delay: const Duration(milliseconds: 210),
                          child: _buildSecurityCard(),
                        ),
                        const SizedBox(height: 20),
                        FadeSlideTransition(
                          delay: const Duration(milliseconds: 280),
                          child: _buildDangerZoneCard(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 20, 8),
      child: Row(
        children: [
          BouncingPressable(
            onTap: _handleBack,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.arrow_back,
                color: AppTheme.orange,
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Configurações da Conta',
              style: TextStyle(
                fontFamily: 'Arial',
                color: AppTheme.darkText,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _profile.isGuest ? AppTheme.orangeBg : AppTheme.lilacContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _profile.isGuest ? 'Convidado' : 'Conta',
              style: TextStyle(
                color: _profile.isGuest ? AppTheme.orangeDark : AppTheme.darkPurple,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeroCard() {
    final initial = _profile.displayName.trim().isNotEmpty
        ? _profile.displayName.trim()[0].toUpperCase()
        : 'E';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.orangeGradient,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppTheme.orange.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildHeroAvatar(initial),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _profile.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _profile.isGuest
                      ? 'Nenhum e-mail vinculado'
                      : (_profile.email ?? 'E-mail não disponível'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.24),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _providerLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroAvatar(String initial) {
    final hasPhoto = _profile.photoUrl != null && _profile.photoUrl!.isNotEmpty;
    final avatar = Container(
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: CircleAvatar(
        radius: 34,
        backgroundColor: AppTheme.lilac,
        backgroundImage: hasPhoto ? NetworkImage(_profile.photoUrl!) : null,
        onBackgroundImageError: hasPhoto ? (_, _) {} : null,
        child: !hasPhoto
            ? Text(
                initial,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
            : null,
      ),
    );

    if (_profile.isGuest) {
      return avatar;
    }

    return BouncingPressable(
      key: const Key('edit_profile_photo_avatar'),
      onTap: _openEditPhotoDialog,
      child: Stack(
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppTheme.darkPurple,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.edit,
                size: 13,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceSoft,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppTheme.lilac,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person_off_outlined, color: AppTheme.darkPurple),
              SizedBox(width: 10),
              Text(
                'Você está no Modo Convidado',
                style: TextStyle(
                  color: AppTheme.darkText,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Entre ou crie uma conta para alterar seu nome, visualizar seu e-mail, sincronizar seus estudos na nuvem e gerenciar opções de segurança.',
            style: TextStyle(
              color: AppTheme.lightText,
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              key: const Key('guest_sign_in_button'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.orange,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(AccountConfigAction.openLogin);
              },
              icon: const Icon(Icons.login_rounded),
              label: const Text(
                'Entrar ou Criar Conta',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfoCard() {
    final emailText = (_profile.email != null && _profile.email!.isNotEmpty)
        ? _profile.email!
        : 'E-mail não disponível';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.lilac.withValues(alpha: 0.7), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.badge_outlined, color: AppTheme.orange, size: 22),
              SizedBox(width: 8),
              Text(
                'Informações da Conta',
                style: TextStyle(
                  color: AppTheme.darkTextHeading,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // CAMPO: NOME DE EXIBIÇÃO
          const Text(
            'Nome de exibição',
            style: TextStyle(
              color: AppTheme.lightText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            key: const Key('account_name_field'),
            controller: _nameController,
            enabled: !_isSavingName && !_isDeletingAccount,
            maxLength: 60,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              if (_canSaveName) {
                _saveName();
              }
            },
            style: const TextStyle(color: AppTheme.darkText, fontSize: 15),
            decoration: InputDecoration(
              counterText: '',
              hintText: 'Digite seu nome',
              prefixIcon: const Icon(
                Icons.person_outline_rounded,
                color: AppTheme.orange,
              ),
              filled: true,
              fillColor: AppTheme.surfaceSoft,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: AppTheme.orange, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              key: const Key('save_name_button'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.orange,
                disabledBackgroundColor: AppTheme.orange.withValues(alpha: 0.45),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _canSaveName ? _saveName : null,
              child: _isSavingName
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Salvar nome',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 22),
          Divider(color: AppTheme.lilac.withValues(alpha: 0.6), height: 1),
          const SizedBox(height: 20),

          // CAMPO SOMENTE LEITURA: E-MAIL
          const Text(
            'E-mail cadastrado',
            style: TextStyle(
              color: AppTheme.lightText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceSoft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.email_outlined,
                  color: AppTheme.darkPurple,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    emailText,
                    key: const Key('account_email_text'),
                    style: const TextStyle(
                      color: AppTheme.darkText,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (_profile.email != null && _profile.email!.isNotEmpty)
                  IconButton(
                    key: const Key('copy_email_button'),
                    tooltip: 'Copiar e-mail',
                    onPressed: _copyEmail,
                    icon: const Icon(
                      Icons.copy_rounded,
                      color: AppTheme.mutedText,
                      size: 19,
                    ),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard() {
    final hasEmail = _profile.email != null && _profile.email!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.lilac.withValues(alpha: 0.7), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield_outlined, color: AppTheme.darkPurple, size: 22),
              SizedBox(width: 8),
              Text(
                'Segurança',
                style: TextStyle(
                  color: AppTheme.darkTextHeading,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            hasEmail
                ? 'Precisa trocar ou recuperar sua senha? Enviaremos um link seguro de redefinição para ${_profile.email}.'
                : 'Nenhum e-mail disponível para solicitar redefinição de senha.',
            style: const TextStyle(
              color: AppTheme.lightText,
              fontSize: 13.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              key: const Key('request_password_reset_button'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lilacContainer,
                foregroundColor: AppTheme.darkPurple,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: (hasEmail && !_isSendingReset && !_isDeletingAccount)
                  ? _confirmAndSendPasswordReset
                  : null,
              icon: _isSendingReset
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.darkPurple,
                      ),
                    )
                  : const Icon(Icons.lock_reset_rounded, size: 20),
              label: Text(
                _isSendingReset
                    ? 'Enviando e-mail...'
                    : 'Solicitar redefinição de senha',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZoneCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppTheme.deleteRed.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.delete_forever_rounded,
                color: AppTheme.deleteRed,
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                'Zona de Perigo',
                style: TextStyle(
                  color: AppTheme.deleteRed,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Ao excluir sua conta, todos os seus dados pessoais, notas, tarefas e resultados de simulados serão removidos permanentemente.',
            style: TextStyle(
              color: AppTheme.lightText,
              fontSize: 13.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              key: const Key('delete_account_button'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.deleteRed,
                side: const BorderSide(color: AppTheme.deleteRed, width: 1.5),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _isDeletingAccount ? null : _confirmAndDeleteAccount,
              icon: const Icon(Icons.delete_outline_rounded, size: 20),
              label: const Text(
                'Excluir conta',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteAccountDialog extends StatefulWidget {
  final bool needsPassword;
  final Future<void> Function(String? password) onConfirmDelete;

  const _DeleteAccountDialog({
    required this.needsPassword,
    required this.onConfirmDelete,
  });

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final TextEditingController _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _dialogError;

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleDelete() async {
    final input = _confirmController.text;
    if (widget.needsPassword) {
      if (input.isEmpty) {
        setState(() {
          _dialogError = 'Digite sua senha atual para confirmar.';
        });
        return;
      }
    } else {
      if (input.trim().toUpperCase() != 'EXCLUIR') {
        setState(() {
          _dialogError = 'Digite EXCLUIR para confirmar a exclusão.';
        });
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
      _dialogError = null;
    });

    try {
      await widget.onConfirmDelete(widget.needsPassword ? input : null);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } on AccountOperationException catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _dialogError = e.message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _dialogError = 'Não foi possível excluir sua conta. Tente novamente.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      title: const Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppTheme.deleteRed,
            size: 26,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Excluir conta',
              style: TextStyle(
                color: AppTheme.deleteRed,
                fontWeight: FontWeight.bold,
                fontSize: 19,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Esta ação é permanente e não pode ser desfeita. Sua conta, anotações, tarefas do calendário e histórico de simulados serão removidos.',
              style: TextStyle(
                color: AppTheme.darkText,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.needsPassword
                  ? 'Digite sua senha atual para confirmar:'
                  : 'Digite EXCLUIR para confirmar:',
              style: const TextStyle(
                color: AppTheme.darkText,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              key: widget.needsPassword
                  ? const Key('delete_confirm_password_field')
                  : const Key('delete_confirm_text_field'),
              controller: _confirmController,
              enabled: !_isSubmitting,
              obscureText: widget.needsPassword ? _obscurePassword : false,
              textCapitalization: widget.needsPassword
                  ? TextCapitalization.none
                  : TextCapitalization.characters,
              onSubmitted: (_) {
                if (!_isSubmitting) {
                  _handleDelete();
                }
              },
              style: const TextStyle(color: AppTheme.darkText),
              decoration: InputDecoration(
                hintText: widget.needsPassword ? 'Sua senha atual' : 'EXCLUIR',
                prefixIcon: Icon(
                  widget.needsPassword
                      ? Icons.lock_outline
                      : Icons.delete_outline,
                  color: AppTheme.deleteRed,
                ),
                suffixIcon: widget.needsPassword
                    ? IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppTheme.mutedText,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.surfaceSoft,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            if (_dialogError != null) ...[
              const SizedBox(height: 10),
              Text(
                _dialogError!,
                style: const TextStyle(
                  color: AppTheme.deleteRed,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context, false),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: AppTheme.mutedText),
          ),
        ),
        ElevatedButton(
          key: const Key('confirm_delete_account_button'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.deleteRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: _isSubmitting ? null : _handleDelete,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Excluir permanentemente'),
        ),
      ],
    );
  }
}

class _EditProfilePhotoDialog extends StatefulWidget {
  final String initialUrl;
  final Future<AccountProfile> Function(String? photoUrl) onSavePhoto;

  const _EditProfilePhotoDialog({
    required this.initialUrl,
    required this.onSavePhoto,
  });

  @override
  State<_EditProfilePhotoDialog> createState() =>
      _EditProfilePhotoDialogState();
}

class _EditProfilePhotoDialogState extends State<_EditProfilePhotoDialog> {
  late final TextEditingController _urlController;
  bool _isSaving = false;
  String? _dialogError;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.initialUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _submit(String? url) async {
    setState(() {
      _isSaving = true;
      _dialogError = null;
    });

    try {
      final updated = await widget.onSavePhoto(url);
      if (mounted) {
        Navigator.pop(context, updated);
      }
    } on AccountOperationException catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _dialogError = e.message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _dialogError = 'Erro ao atualizar foto de perfil.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasInitialPhoto = widget.initialUrl.trim().isNotEmpty;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Row(
        children: [
          Icon(Icons.photo_camera_outlined, color: AppTheme.orange),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Atualizar Foto de Perfil',
              style: TextStyle(
                color: AppTheme.darkText,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            key: const Key('profile_photo_url_field'),
            controller: _urlController,
            enabled: !_isSaving,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              if (!_isSaving) {
                _submit(_urlController.text.trim());
              }
            },
            style: const TextStyle(color: AppTheme.darkText),
            decoration: InputDecoration(
              hintText: 'Cole a URL da sua imagem',
              prefixIcon: const Icon(Icons.link, color: AppTheme.orange),
              filled: true,
              fillColor: AppTheme.surfaceSoft,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (_dialogError != null) ...[
            const SizedBox(height: 10),
            Text(
              _dialogError!,
              style: const TextStyle(
                color: AppTheme.deleteRed,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (hasInitialPhoto)
          TextButton(
            key: const Key('remove_photo_button'),
            onPressed: _isSaving ? null : () => _submit(null),
            child: const Text(
              'Remover',
              style: TextStyle(color: AppTheme.deleteRed),
            ),
          ),
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: AppTheme.mutedText),
          ),
        ),
        ElevatedButton(
          key: const Key('save_photo_button'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.orange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: _isSaving ? null : () => _submit(_urlController.text.trim()),
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Salvar'),
        ),
      ],
    );
  }
}
