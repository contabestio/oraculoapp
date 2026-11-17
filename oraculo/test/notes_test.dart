import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oraculo/pages/notes_and_insights_page.dart';

void main() {
  group('Testes unitários - Notas e Insights', () {
    test('NoteEditorResult.save armazena ação e campos corretamente', () {
      final result = NoteEditorResult.save(
        title: 'Título de Teste',
        content: 'Conteúdo de Teste',
      );

      expect(result.action, equals(NoteEditorAction.save));
      expect(result.title, equals('Título de Teste'));
      expect(result.content, equals('Conteúdo de Teste'));
    });

    test('NoteEditorResult.delete armazena ação de exclusão corretamente', () {
      const result = NoteEditorResult.delete();

      expect(result.action, equals(NoteEditorAction.delete));
      expect(result.title, isEmpty);
      expect(result.content, isEmpty);
    });

    test('NoteItem instancia com dados esperados', () {
      final now = DateTime.now();
      final item = NoteItem(
        id: '12345',
        title: 'Estudo de Física',
        content: 'Revisar Cinemática',
        updatedAt: now,
        createdAt: now,
      );

      expect(item.id, equals('12345'));
      expect(item.title, equals('Estudo de Física'));
      expect(item.content, equals('Revisar Cinemática'));
      expect(item.updatedAt, equals(now));
      expect(item.createdAt, equals(now));
    });

    test('NoteItem.filterNotes filtra por título e conteúdo sem diferenciar maiúsculas', () {
      final now = DateTime.now();
      final notes = [
        NoteItem(
          id: '1',
          title: 'Física',
          content: 'Revisar Cinemática',
          updatedAt: now,
          createdAt: now,
        ),
        NoteItem(
          id: '2',
          title: 'Redação ENEM',
          content: 'Treinar proposta de intervenção',
          updatedAt: now,
          createdAt: now,
        ),
      ];

      expect(NoteItem.filterNotes(notes, '').length, equals(2));
      expect(NoteItem.filterNotes(notes, 'física').map((n) => n.id), equals(['1']));
      expect(NoteItem.filterNotes(notes, 'INTERVENÇÃO').map((n) => n.id), equals(['2']));
      expect(NoteItem.filterNotes(notes, 'Biologia'), isEmpty);
    });

    testWidgets('Barra de busca no container Metas filtra notas e limpa a busca',
        (tester) async {
      final now = DateTime.now();
      final sampleNotes = [
        NoteItem(
          id: '1',
          title: 'Resumo de História',
          content: 'Revolução Industrial',
          updatedAt: now,
          createdAt: now,
        ),
        NoteItem(
          id: '2',
          title: 'Fórmulas de Química',
          content: 'Estequiometria e mols',
          updatedAt: now,
          createdAt: now,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: NotesAndInsightsPage(
            notesStream: Stream.value(sampleNotes),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Barra de busca deve estar dentro do container Metas
      final metasContainer = find.byKey(const Key('metas_container'));
      final searchField = find.descendant(
        of: metasContainer,
        matching: find.byKey(const Key('metas_search_field')),
      );
      expect(metasContainer, findsOneWidget);
      expect(searchField, findsOneWidget);

      expect(find.text('Resumo de História'), findsOneWidget);
      expect(find.text('Fórmulas de Química'), findsOneWidget);

      // Filtra pelo conteúdo da segunda nota
      await tester.enterText(searchField, 'estequiometria');
      await tester.pumpAndSettle();

      expect(find.text('Resumo de História'), findsNothing);
      expect(find.text('Fórmulas de Química'), findsOneWidget);

      // Termo sem resultados mostra estado vazio
      await tester.enterText(searchField, 'astronomia');
      await tester.pumpAndSettle();

      expect(find.text('Nenhuma nota encontrada'), findsOneWidget);

      // Limpar busca restaura todas as notas
      await tester.tap(find.byKey(const Key('metas_search_clear_button')));
      await tester.pumpAndSettle();

      expect(find.text('Resumo de História'), findsOneWidget);
      expect(find.text('Fórmulas de Química'), findsOneWidget);
    });
  });
}
