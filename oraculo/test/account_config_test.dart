import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oraculo/pages/account_config_page.dart';
import 'package:oraculo/services/account_service.dart';

class _FakeAccountService implements AccountService {
  AccountProfile profile;
  String? lastResetEmail;
  String? lastDeletedWithPassword;
  bool deleteCalled = false;
  AccountOperationException? nextDeleteError;

  _FakeAccountService(this.profile);

  @override
  AccountProfile getCurrentProfile() => profile;

  @override
  Future<AccountProfile> updateDisplayName(String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) {
      throw const AccountOperationException(
        code: 'invalid-name',
        message: 'Digite um nome válido.',
      );
    }
    profile = profile.copyWith(displayName: trimmed);
    return profile;
  }

  @override
  Future<AccountProfile> updatePhotoUrl(String? photoUrl) async {
    final trimmed = photoUrl?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      profile = profile.copyWith(clearPhotoUrl: true);
    } else {
      profile = profile.copyWith(photoUrl: trimmed);
    }
    return profile;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    lastResetEmail = email;
  }

  @override
  Future<void> deleteAccount({String? password}) async {
    if (nextDeleteError != null) {
      final err = nextDeleteError!;
      nextDeleteError = null;
      throw err;
    }
    deleteCalled = true;
    lastDeletedWithPassword = password;
  }
}

void main() {
  group('AccountConfigPage - Configurações da Conta', () {
    testWidgets('exibe o nome atual e o e-mail do usuário autenticado',
        (tester) async {
      final fakeService = _FakeAccountService(
        const AccountProfile(
          uid: 'uid-1',
          displayName: 'Maria Silva',
          email: 'maria@oraculo.com',
          isGuest: false,
          hasPasswordProvider: true,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: AccountConfigPage(accountService: fakeService),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Configurações da Conta'), findsOneWidget);
      expect(find.text('Maria Silva'), findsAtLeastNWidgets(1));
      expect(find.byKey(const Key('account_email_text')), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('account_email_text'))).data,
        equals('maria@oraculo.com'),
      );
    });

    testWidgets('permite alterar o nome e notifica onProfileUpdated',
        (tester) async {
      final fakeService = _FakeAccountService(
        const AccountProfile(
          uid: 'uid-2',
          displayName: 'João',
          email: 'joao@oraculo.com',
          isGuest: false,
          hasPasswordProvider: true,
        ),
      );
      var callbackCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: AccountConfigPage(
            accountService: fakeService,
            onProfileUpdated: () => callbackCount++,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Botão salvar inicia desabilitado enquanto o nome não muda
      final saveButtonFinder = find.byKey(const Key('save_name_button'));
      expect(
        tester.widget<ElevatedButton>(saveButtonFinder).onPressed,
        isNull,
      );

      await tester.enterText(
        find.byKey(const Key('account_name_field')),
        'João Pedro',
      );
      await tester.pumpAndSettle();

      await tester.tap(saveButtonFinder);
      await tester.pumpAndSettle();

      expect(fakeService.profile.displayName, equals('João Pedro'));
      expect(callbackCount, equals(1));
      expect(find.text('Nome atualizado com sucesso!'), findsOneWidget);
    });

    testWidgets('solicita confirmação e envia e-mail de redefinição de senha',
        (tester) async {
      final fakeService = _FakeAccountService(
        const AccountProfile(
          uid: 'uid-3',
          displayName: 'Ana',
          email: 'ana@oraculo.com',
          isGuest: false,
          hasPasswordProvider: true,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: AccountConfigPage(accountService: fakeService),
        ),
      );
      await tester.pumpAndSettle();

      final resetBtn = find.byKey(const Key('request_password_reset_button'));
      await tester.ensureVisible(resetBtn);
      await tester.tap(resetBtn);
      await tester.pumpAndSettle();

      // Diálogo de confirmação deve exibir o e-mail de destino
      expect(find.text('Redefinir senha'), findsOneWidget);
      expect(
        find.byKey(const Key('confirm_password_reset_button')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('confirm_password_reset_button')));
      await tester.pumpAndSettle();

      expect(fakeService.lastResetEmail, equals('ana@oraculo.com'));
      expect(
        find.text('E-mail de redefinição de senha enviado para ana@oraculo.com!'),
        findsOneWidget,
      );
    });

    testWidgets(
        'exige senha e exclui conta com provedor de senha retornando AccountConfigAction.deleted',
        (tester) async {
      final fakeService = _FakeAccountService(
        const AccountProfile(
          uid: 'uid-4',
          displayName: 'Lucas',
          email: 'lucas@oraculo.com',
          isGuest: false,
          hasPasswordProvider: true,
        ),
      );
      AccountConfigAction? poppedAction;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  poppedAction = await Navigator.push<AccountConfigAction?>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AccountConfigPage(accountService: fakeService),
                    ),
                  );
                },
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      final deleteBtn = find.byKey(const Key('delete_account_button'));
      await tester.ensureVisible(deleteBtn);
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      // Simula erro de senha incorreta primeiro
      fakeService.nextDeleteError = const AccountOperationException(
        code: 'wrong-password',
        message: 'Senha incorreta. Verifique e tente novamente.',
      );

      await tester.enterText(
        find.byKey(const Key('delete_confirm_password_field')),
        'errada123',
      );
      await tester.tap(find.byKey(const Key('confirm_delete_account_button')));
      await tester.pumpAndSettle();

      expect(
        find.text('Senha incorreta. Verifique e tente novamente.'),
        findsOneWidget,
      );
      expect(fakeService.deleteCalled, isFalse);

      // Agora informa senha correta
      await tester.enterText(
        find.byKey(const Key('delete_confirm_password_field')),
        'correta123',
      );
      await tester.tap(find.byKey(const Key('confirm_delete_account_button')));
      await tester.pumpAndSettle();

      expect(fakeService.deleteCalled, isTrue);
      expect(fakeService.lastDeletedWithPassword, equals('correta123'));
      expect(poppedAction, equals(AccountConfigAction.deleted));
    });

    testWidgets('conta somente Google exige digitar EXCLUIR para confirmar',
        (tester) async {
      final fakeService = _FakeAccountService(
        const AccountProfile(
          uid: 'uid-5',
          displayName: 'Carla',
          email: 'carla@gmail.com',
          isGuest: false,
          hasPasswordProvider: false,
          hasGoogleProvider: true,
        ),
      );
      AccountConfigAction? poppedAction;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  poppedAction = await Navigator.push<AccountConfigAction?>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AccountConfigPage(accountService: fakeService),
                    ),
                  );
                },
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      final deleteBtn = find.byKey(const Key('delete_account_button'));
      await tester.ensureVisible(deleteBtn);
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('delete_confirm_text_field')),
        'NAO',
      );
      await tester.tap(find.byKey(const Key('confirm_delete_account_button')));
      await tester.pumpAndSettle();

      expect(
        find.text('Digite EXCLUIR para confirmar a exclusão.'),
        findsOneWidget,
      );
      expect(fakeService.deleteCalled, isFalse);

      await tester.enterText(
        find.byKey(const Key('delete_confirm_text_field')),
        'EXCLUIR',
      );
      await tester.tap(find.byKey(const Key('confirm_delete_account_button')));
      await tester.pumpAndSettle();

      expect(fakeService.deleteCalled, isTrue);
      expect(fakeService.lastDeletedWithPassword, isNull);
      expect(poppedAction, equals(AccountConfigAction.deleted));
    });

    testWidgets('modo convidado exibe aviso e botão para abrir login',
        (tester) async {
      final fakeService = _FakeAccountService(const AccountProfile.guest());
      AccountConfigAction? poppedAction;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  poppedAction = await Navigator.push<AccountConfigAction?>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AccountConfigPage(accountService: fakeService),
                    ),
                  );
                },
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      expect(find.text('Você está no Modo Convidado'), findsOneWidget);
      expect(find.byKey(const Key('edit_profile_photo_avatar')), findsNothing);
      await tester.tap(find.byKey(const Key('guest_sign_in_button')));
      await tester.pumpAndSettle();

      expect(poppedAction, equals(AccountConfigAction.openLogin));
    });

    testWidgets('permite atualizar e remover a foto de perfil pelo avatar',
        (tester) async {
      final fakeService = _FakeAccountService(
        const AccountProfile(
          uid: 'uid-6',
          displayName: 'Sofia',
          email: 'sofia@oraculo.com',
          isGuest: false,
          hasPasswordProvider: true,
        ),
      );
      var callbackCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: AccountConfigPage(
            accountService: fakeService,
            onProfileUpdated: () => callbackCount++,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Abre editor clicando no avatar com o ícone de lápis
      await tester.tap(find.byKey(const Key('edit_profile_photo_avatar')));
      await tester.pumpAndSettle();

      expect(find.text('Atualizar Foto de Perfil'), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('profile_photo_url_field')),
        'https://example.com/sofia.png',
      );
      await tester.tap(find.byKey(const Key('save_photo_button')));
      await tester.pumpAndSettle();

      expect(
        fakeService.profile.photoUrl,
        equals('https://example.com/sofia.png'),
      );
      expect(callbackCount, equals(1));
      expect(find.text('Foto de perfil atualizada!'), findsOneWidget);

      // Abre editor novamente clicando no avatar e remove a foto
      await tester.tap(find.byKey(const Key('edit_profile_photo_avatar')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('remove_photo_button')), findsOneWidget);
      await tester.tap(find.byKey(const Key('remove_photo_button')));
      await tester.pumpAndSettle();

      expect(fakeService.profile.photoUrl, isNull);
      expect(callbackCount, equals(2));
      expect(find.text('Foto de perfil removida!'), findsOneWidget);
    });
  });
}
