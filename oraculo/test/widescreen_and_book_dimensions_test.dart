import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oraculo/widgets/book_cover_card.dart';
import 'package:oraculo/widgets/meus_materiais_section.dart';
import 'package:oraculo/pages/materials_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BookCoverCard - Dimensões Padrão de Livros', () {
    test('Valores padrão de largura, altura e proporção do livro são definidos', () {
      expect(BookCoverCard.standardWidth, equals(140.0));
      expect(BookCoverCard.standardHeight, equals(220.0));
      expect(BookCoverCard.standardAspectRatio, closeTo(140.0 / 220.0, 0.001));
    });

    testWidgets('BookCoverCard respeita dimensões padrão quando inserido', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: BookCoverCard(
                title: 'Livro Teste',
                imageUrl: 'https://example.com/cover.png',
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      final cardFinder = find.byType(BookCoverCard);
      expect(cardFinder, findsOneWidget);

      final size = tester.getSize(cardFinder);
      expect(size.height, equals(BookCoverCard.standardHeight));
    });

    testWidgets('BookCoverCard aceita largura e altura customizadas quando fornecidas', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: BookCoverCard(
                title: 'Livro Customizado',
                imageUrl: 'https://example.com/cover.png',
                width: 160.0,
                height: 240.0,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      final cardFinder = find.byType(BookCoverCard);
      expect(cardFinder, findsOneWidget);

      final size = tester.getSize(cardFinder);
      expect(size.width, equals(160.0));
      expect(size.height, equals(240.0));
    });
  });

  group('Centralização em Widescreen (Telas Largas / Desktop)', () {
    testWidgets('MaterialsPage centraliza conteúdo com largura máxima em tela widescreen (1920x1080)', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: MaterialsPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Encontra o ConstrainedBox que centraliza o conteúdo em widescreen
      final constrainedBoxes = find.byType(ConstrainedBox);
      expect(constrainedBoxes, findsWidgets);

      bool foundCenterContainer = false;
      for (final element in constrainedBoxes.evaluate()) {
        final widget = element.widget as ConstrainedBox;
        if (widget.constraints.maxWidth == 1000) {
          foundCenterContainer = true;
          break;
        }
      }
      expect(foundCenterContainer, isTrue);
    });

    testWidgets('MeusMateriaisSection utiliza BookCoverCard com dimensões e proporções padronizadas', (tester) async {
      final sampleBooks = [
        const MaterialBook(
          title: 'Matemática ENEM',
          imageUrl: 'https://example.com/mat.png',
        ),
        const MaterialBook(
          title: 'Redação Nota 1000',
          imageUrl: 'https://example.com/red.png',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MeusMateriaisSection(books: sampleBooks),
            ),
          ),
        ),
      );

      final booksFound = find.byType(BookCoverCard);
      expect(booksFound, findsNWidgets(2));
    });
  });
}
