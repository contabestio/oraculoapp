import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/animations.dart';

// ==========================================================
// CONSTANTES DE COR E TEMA ORIGINAIS DO PROJETO
// ==========================================================

const Color _lilac = Color(0xFFEADBFF);
const Color _orange = Color(0xFFFFB08E);
const Color _darkPurple = Color(0xFF594A6D);

// ==========================================================
// MODELO DE NOTA (FIREBASE CLOUD FIRESTORE)
// ==========================================================

class NoteItem {
  final String id;
  final String title;
  final String content;
  final DateTime updatedAt;
  final DateTime createdAt;

  NoteItem({
    required this.id,
    required this.title,
    required this.content,
    required this.updatedAt,
    required this.createdAt,
  });

  /// Constrói uma instância a partir de um documento do Cloud Firestore.
  factory NoteItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final updateTimestamp = data['updatedAt'] as Timestamp?;
    final createTimestamp = data['createdAt'] as Timestamp?;

    return NoteItem(
      id: doc.id,
      title: (data['title'] as String?)?.trim() ?? '',
      content: (data['content'] as String?)?.trim() ?? '',
      updatedAt: updateTimestamp?.toDate() ?? DateTime.now(),
      createdAt: createTimestamp?.toDate() ?? DateTime.now(),
    );
  }
}

// ==========================================================
// RESULTADO DO EDITOR DE NOTAS
// ==========================================================

enum NoteEditorAction { save, delete }

class NoteEditorResult {
  final NoteEditorAction action;
  final String title;
  final String content;

  const NoteEditorResult.save({
    required this.title,
    required this.content,
  })  : action = NoteEditorAction.save;

  const NoteEditorResult.delete()
      : action = NoteEditorAction.delete,
        title = '',
        content = '';
}

// ==========================================================
// TELA PRINCIPAL: NOTAS E INSIGHTS
// ==========================================================

class NotesAndInsightsPage extends StatefulWidget {
  const NotesAndInsightsPage({super.key});

  @override
  State<NotesAndInsightsPage> createState() => _NotesAndInsightsPageState();
}

class _NotesAndInsightsPageState extends State<NotesAndInsightsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Retorna a referência da subcoleção de notas do usuário autenticado atual:
  /// users/{uid}/notes
  CollectionReference<Map<String, dynamic>>? _getUserNotesCollection() {
    final user = _auth.currentUser;
    if (user == null) return null;

    return _firestore.collection('users').doc(user.uid).collection('notes');
  }

  /// Exibe um SnackBar informativo ou de erro.
  void _showFeedback(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : _darkPurple,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Abre a tela de edição para criar uma nova nota ou atualizar uma existente.
  Future<void> _openNote({NoteItem? existingNote}) async {
    final collection = _getUserNotesCollection();
    if (collection == null) {
      _showFeedback(
        'Você precisa estar autenticado para gerenciar notas.',
        isError: true,
      );
      return;
    }

    // Navega para o editor com transição suave
    final NoteEditorResult? result = await Navigator.push<NoteEditorResult>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            NoteEditorPage(initialNote: existingNote),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curveAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curveAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(curveAnimation),
              child: child,
            ),
          );
        },
      ),
    );

    if (!mounted || result == null) return;

    try {
      if (result.action == NoteEditorAction.delete) {
        if (existingNote != null) {
          await collection.doc(existingNote.id).delete();
          _showFeedback('Nota excluída com sucesso.');
        }
      } else if (result.action == NoteEditorAction.save) {
        if (existingNote == null) {
          // Criação de nova nota
          await collection.add({
            'title': result.title,
            'content': result.content,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          _showFeedback('Nota criada com sucesso!');
        } else {
          // Edição de nota existente
          await collection.doc(existingNote.id).update({
            'title': result.title,
            'content': result.content,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          _showFeedback('Nota atualizada com sucesso!');
        }
      }
    } on FirebaseException catch (e) {
      String errorMessage = 'Erro ao processar nota no Firebase.';
      if (e.code == 'permission-denied') {
        errorMessage =
            'Permissão negada. Verifique as regras de segurança do Firestore.';
      } else if (e.code == 'unavailable') {
        errorMessage =
            'Sem conexão com o Firebase. As alterações serão sincronizadas quando houver rede.';
      }
      _showFeedback(errorMessage, isError: true);
    } catch (_) {
      _showFeedback(
        'Ocorreu um erro inesperado ao salvar a nota.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final collection = _getUserNotesCollection();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // ------------------------------------------------------
              // BARRA SUPERIOR ORIGINAL COM ANIMAÇÃO
              // ------------------------------------------------------
              FadeSlideTransition(
                delay: const Duration(milliseconds: 50),
                child: Row(
                  children: [
                    BouncingPressable(
                      onTap: () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.close,
                          color: _orange,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: _orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.outlined_flag,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Metas',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ------------------------------------------------------
              // PAINEL PRINCIPAL LILÁS ORIGINAL COM ANIMAÇÃO
              // ------------------------------------------------------
              Expanded(
                child: FadeSlideTransition(
                  delay: const Duration(milliseconds: 150),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _lilac,
                      borderRadius: BorderRadius.circular(36),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Notas e Insights >',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: collection == null
                              ? _buildUnauthenticatedState()
                              : StreamBuilder<
                                  QuerySnapshot<Map<String, dynamic>>>(
                                  stream: collection
                                      .orderBy('updatedAt', descending: true)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return _buildErrorState(snapshot.error);
                                    }

                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      );
                                    }

                                    final docs = snapshot.data?.docs ?? [];
                                    final List<NoteItem> notes = docs
                                        .map((doc) => NoteItem.fromFirestore(doc))
                                        .toList();

                                    final int totalCards =
                                        notes.length < 6 ? 6 : notes.length;

                                    return GridView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: totalCards,
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                        childAspectRatio: 0.85,
                                      ),
                                      itemBuilder: (context, index) {
                                        final bool hasNote =
                                            index < notes.length;

                                        return BouncingPressable(
                                          onTap: () => _openNote(
                                            existingNote:
                                                hasNote ? notes[index] : null,
                                          ),
                                          scaleFactor: 0.94,
                                          child: Material(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            elevation: hasNote ? 2 : 0,
                                            shadowColor: Colors.black.withValues(alpha: 0.1),
                                            clipBehavior: Clip.antiAlias,
                                            child: Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: hasNote
                                                  ? _buildNoteCardContent(
                                                      notes[index],
                                                    )
                                                  : _buildEmptyCardContent(),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Botão flutuante original com compressão animada
      floatingActionButton: BouncingPressable(
        onTap: () => _openNote(),
        child: FloatingActionButton(
          onPressed: () => _openNote(),
          backgroundColor: _orange,
          foregroundColor: Colors.white,
          tooltip: 'Criar nota',
          elevation: 4,
          child: const Icon(Icons.add, size: 30),
        ),
      ),
    );
  }

  /// Conteúdo do cartão com dados da nota preenchida.
  Widget _buildNoteCardContent(NoteItem note) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          note.title.trim().isEmpty ? 'Sem título' : note.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _darkPurple,
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Text(
            note.content.trim().isEmpty
                ? 'Nota sem conteúdo adicional...'
                : note.content,
            maxLines: 7,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color:
                  note.content.trim().isEmpty ? Colors.grey : Colors.black87,
            ),
          ),
        ),
        Text(
          '${note.updatedAt.day.toString().padLeft(2, '0')}/'
          '${note.updatedAt.month.toString().padLeft(2, '0')}/'
          '${note.updatedAt.year}',
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }

  /// Conteúdo do cartão vazio da grade (espaço reservado para nova nota).
  Widget _buildEmptyCardContent() {
    return Center(
      child: Icon(
        Icons.add_rounded,
        size: 32,
        color: _orange.withValues(alpha: 0.5),
      ),
    );
  }

  /// Estado exibido caso o usuário não esteja autenticado no Firebase.
  Widget _buildUnauthenticatedState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 12),
          const Text(
            'Usuário não autenticado',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Faça login na tela principal para sincronizar suas anotações com segurança.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _darkPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Voltar ao Início'),
          ),
        ],
      ),
    );
  }

  /// Estado de erro de permissão ou conexão com Firestore.
  Widget _buildErrorState(dynamic error) {
    String message = 'Ocorreu um erro ao carregar as notas.';
    if (error is FirebaseException) {
      if (error.code == 'permission-denied') {
        message =
            'Acesso negado: verifique as regras de segurança do Firestore no Firebase Console.';
      } else if (error.code == 'unavailable') {
        message =
            'Serviço temporariamente indisponível. Verifique sua conexão com a internet.';
      }
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: Colors.white,
            size: 46,
          ),
          const SizedBox(height: 12),
          const Text(
            'Falha na sincronização',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() {}),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _darkPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// TELA DE CRIAÇÃO E EDIÇÃO DE NOTAS
// ==========================================================

class NoteEditorPage extends StatefulWidget {
  final NoteItem? initialNote;

  const NoteEditorPage({super.key, this.initialNote});

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.initialNote?.title ?? '',
    );

    _contentController = TextEditingController(
      text: widget.initialNote?.content ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escreva algo antes de salvar.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      NoteEditorResult.save(title: title, content: content),
    );
  }

  Future<void> _confirmDelete() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Excluir nota?'),
          content: const Text(
            'Esta ação não pode ser desfeita. A nota será excluída permanentemente.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogCtx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      Navigator.pop(context, const NoteEditorResult.delete());
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.initialNote != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BouncingPressable(
          onTap: () => Navigator.pop(context),
          child: const Padding(
            padding: EdgeInsets.all(4.0),
            child: Icon(Icons.arrow_back, color: _orange),
          ),
        ),
        title: Text(
          isEditing ? 'Editar nota' : 'Nova nota',
          style: const TextStyle(
            color: _darkPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          BouncingPressable(
            onTap: _saveNote,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Icon(Icons.check, color: _orange, size: 28),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                maxLength: 80,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Título da nota',
                  counterText: '',
                  filled: true,
                  fillColor: _lilac.withValues(alpha: 0.35),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _darkPurple,
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: TextField(
                  controller: _contentController,
                  expands: true,
                  minLines: null,
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: 'Escreva suas ideias aqui...',
                    filled: true,
                    fillColor: _lilac.withValues(alpha: 0.25),
                    contentPadding: const EdgeInsets.all(20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              if (isEditing) ...[
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: BouncingPressable(
                    onTap: _confirmDelete,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Excluir nota',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
