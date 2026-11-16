import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oraculo/widgets/formatted_book_content.dart';

void main() {
  group('FormattedBookContent - Testes Unitários', () {
    test('parseInlineSpans identifica negrito com asteriscos duplos (**texto**)', () {
      final spans = FormattedBookContent.parseInlineSpans('Este é um **termo importante** no texto.');

      expect(spans.length, equals(3));
      expect(spans[0].toPlainText(), equals('Este é um '));
      expect(spans[1].toPlainText(), equals('termo importante'));
      expect(spans[1].style?.fontWeight, equals(FontWeight.bold));
      expect(spans[2].toPlainText(), equals(' no texto.'));
    });

    test('parseInlineSpans identifica negrito com tags HTML (<b>texto</b>)', () {
      final spans = FormattedBookContent.parseInlineSpans('Regra: <b>atenção redobrada</b> aqui.');

      expect(spans.length, equals(3));
      expect(spans[0].toPlainText(), equals('Regra: '));
      expect(spans[1].toPlainText(), equals('atenção redobrada'));
      expect(spans[1].style?.fontWeight, equals(FontWeight.bold));
      expect(spans[2].toPlainText(), equals(' aqui.'));
    });

    test('parseInlineSpans aplica negrito automático no rótulo antes de dois-pontos', () {
      final spans = FormattedBookContent.parseInlineSpans(
        '1. AGENTE: Quem executará a ação?',
        autoBoldLeadingLabel: true,
      );

      expect(spans.isNotEmpty, isTrue);
      // O rótulo "1. AGENTE:" deve estar em negrito
      final boldSpan = spans.firstWhere(
        (s) => s.toPlainText().contains('1. AGENTE:'),
        orElse: () => const TextSpan(text: ''),
      );
      expect(boldSpan.toPlainText(), isNotEmpty);
      expect(boldSpan.style?.fontWeight, equals(FontWeight.bold));
    });

    testWidgets('FormattedBookContent renderiza múltiplos blocos (título, lista, quebra)', (tester) async {
      const rawContent = '''### Introdução ao Paleolítico
A arte no período paleolítico era viva e mágica.

• **Pintura Rupestre:** Cavernas de Lascaux e Altamira.
• **Escultura:** Vênus de Willendorf e fertilidade.

1. **Passo 1:** Analisar o sítio arqueológico.
2. **Passo 2:** Catalogar os pigmentos.

> A arte fazia parte da sobrevivência cotidiana.''';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: FormattedBookContent(content: rawContent),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verifica presença de textos esperados
      expect(find.textContaining('Introdução ao Paleolítico'), findsOneWidget);
      expect(find.textContaining('A arte no período paleolítico'), findsOneWidget);
      expect(find.textContaining('Pintura Rupestre:'), findsOneWidget);
      expect(find.textContaining('Vênus de Willendorf'), findsOneWidget);
      expect(find.textContaining('Passo 1:'), findsOneWidget);
      expect(find.textContaining('A arte fazia parte da sobrevivência'), findsOneWidget);
    });

    testWidgets('FormattedBookContent converte tags <...> no meio do texto em subtítulos', (tester) async {
      const rawWithInlineTag = '''Texto anterior.  <Características Principais>  Texto posterior com mais detalhes.''';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FormattedBookContent(content: rawWithInlineTag),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Características Principais'), findsOneWidget);
      expect(find.textContaining('Texto anterior.'), findsOneWidget);
      expect(find.textContaining('Texto posterior com mais detalhes.'), findsOneWidget);
    });
  });
}
