import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book_model.dart';
import 'universal_books_catalog.dart';

/// Repositório central de livros e materiais de estudo do Oráculo.
///
/// Como publicar conteúdo permanentemente para todos os usuários:
/// 1. Abra o arquivo `universal_books_catalog.dart` e adicione/edite o livro diretamente lá.
/// 2. OU use o painel no próprio app e toque em "Exportar Todo o Arquivo Catálogo"
///    ou "Copiar Código Universal" para colar lá!
/// 3. Tudo em `universal_books_catalog.dart` fica gravado localmente no código do app,
///    garantindo que todos os usuários tenham acesso imediato e permanente (inclusive offline).
/// 4. Opcionalmente, administradores também podem sincronizar livros em tempo real pelo Firestore.
class BooksRepository {
  BooksRepository._();
  static final BooksRepository instance = BooksRepository._();

  static const String _storageKey = 'oraculo_dev_custom_books_v1';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final ValueNotifier<List<BookModel>> booksNotifier =
      ValueNotifier<List<BookModel>>(universalBooksCatalog);

  List<BookModel> get books => booksNotifier.value;

  /// Inicializa o repositório com o catálogo universal do código,
  /// mescla com alterações locais do desenvolvedor e busca atualizações na nuvem.
  Future<void> initialize() async {
    // 1. Inicia com todos os livros universais embutidos no código
    final Map<String, BookModel> bookMap = {
      for (final b in universalBooksCatalog) b.id: b,
    };

    // 2. Carrega eventuais edições locais salvas pelo desenvolvedor
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedJson = prefs.getString(_storageKey);

      if (storedJson != null && storedJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(storedJson);
        final customList = decoded
            .map((e) => BookModel.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();

        for (final customBook in customList) {
          bookMap[customBook.id] = customBook;
        }
      }
    } catch (e) {
      debugPrint('BooksRepository: Erro ao carregar livros locais: $e');
    }

    booksNotifier.value = bookMap.values.toList();

    // 3. Sincroniza em segundo plano com livros públicos no Firestore (se houver conexão)
    _syncWithCloud();
  }

  Future<void> _syncWithCloud() async {
    try {
      final snapshot = await _firestore.collection('public_materials').get();
      if (snapshot.docs.isNotEmpty) {
        final currentMap = {
          for (final b in booksNotifier.value) b.id: b,
        };

        for (final doc in snapshot.docs) {
          final data = doc.data();
          data['id'] = doc.id;
          final cloudBook = BookModel.fromMap(data);
          currentMap[cloudBook.id] = cloudBook;
        }

        booksNotifier.value = currentMap.values.toList();
      }
    } catch (e) {
      // Falha silenciosa caso offline ou regras não publicadas
      debugPrint('BooksRepository: Sincronização cloud opcional: $e');
    }
  }

  /// Salva ou atualiza um livro (Acessível por Administradores)
  Future<void> saveBook(BookModel book, {bool syncToCloud = true}) async {
    final currentList = List<BookModel>.from(booksNotifier.value);
    final index = currentList.indexWhere((b) => b.id == book.id);

    final updatedBook = book.copyWith(isCustom: true);

    if (index >= 0) {
      currentList[index] = updatedBook;
    } else {
      currentList.insert(0, updatedBook);
    }

    booksNotifier.value = currentList;
    await _persistCustomBooks();

    // Sincroniza também com o Firestore para distribuição automática
    if (syncToCloud) {
      try {
        await _firestore
            .collection('public_materials')
            .doc(book.id)
            .set(book.toMap());
      } catch (e) {
        debugPrint('BooksRepository: Erro ao sincronizar livro na nuvem: $e');
      }
    }
  }

  /// Remove um livro ou restaura a versão original do catálogo universal
  Future<void> deleteBook(String id) async {
    final currentList = List<BookModel>.from(booksNotifier.value);
    final universalMatch =
        universalBooksCatalog.where((b) => b.id == id).toList();

    if (universalMatch.isNotEmpty) {
      final index = currentList.indexWhere((b) => b.id == id);
      if (index >= 0) {
        currentList[index] = universalMatch.first;
      }
    } else {
      currentList.removeWhere((b) => b.id == id);
    }

    booksNotifier.value = currentList;
    await _persistCustomBooks();

    try {
      await _firestore.collection('public_materials').doc(id).delete();
    } catch (_) {}
  }

  /// Restaura todos os livros para o catálogo universal original definido no código
  Future<void> resetToDefaults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e) {
      debugPrint('Erro ao resetar livros: $e');
    }
    booksNotifier.value = List.unmodifiable(universalBooksCatalog);
  }

  Future<void> _persistCustomBooks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customBooks = booksNotifier.value.where((b) => b.isCustom).toList();
      final encoded = jsonEncode(customBooks.map((b) => b.toMap()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      debugPrint('Erro ao persistir livros: $e');
    }
  }

  /// Encontra um livro pelo ID ou pelo título
  BookModel? getByIdOrTitle(String query) {
    final q = query.trim().toLowerCase();
    for (final book in booksNotifier.value) {
      if (book.id.toLowerCase() == q || book.title.toLowerCase() == q) {
        return book;
      }
    }
    return null;
  }

  /// Exporta o conteúdo completo para substituir o arquivo `universal_books_catalog.dart`.
  /// Basta copiar e colar todo o texto gerado dentro de `universal_books_catalog.dart`!
  String exportCompleteCatalogFile() {
    final buffer = StringBuffer();
    buffer.writeln("import '../models/book_model.dart';");
    buffer.writeln();
    buffer.writeln('/// Catálogo Universal de Livros gerado automaticamente.');
    buffer.writeln('/// Cole este conteúdo em lib/data/universal_books_catalog.dart.');
    buffer.writeln('final List<BookModel> universalBooksCatalog = [');
    for (final b in booksNotifier.value) {
      buffer.writeln('  ${b.toDartCode().replaceAll('\n', '\n  ')},');
    }
    buffer.writeln('];');
    return buffer.toString();
  }

  /// Exporta todo o catálogo em formato de código Dart como lista simples
  String exportAllAsDartCode() => exportCompleteCatalogFile();
}
