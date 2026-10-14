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
  });
}
