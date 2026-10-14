import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ==========================================================
// MODELO DE NOTA
// ==========================================================

class Note {
  final String title;
  final String content;
  final DateTime updatedAt;

  Note({required this.title, required this.content, DateTime? updatedAt})
    : updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

// ==========================================================
// TELA PRINCIPAL
// ==========================================================

class NotesAndInsightsPage extends StatefulWidget {
  const NotesAndInsightsPage({super.key});

  @override
  State<NotesAndInsightsPage> createState() => _NotesAndInsightsPageState();
}

class _NotesAndInsightsPageState extends State<NotesAndInsightsPage> {
  static const Color lilac = Color(0xFFEADBFF);
  static const Color orange = Color(0xFFFFB08E);

  List<Note> notes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  // Carrega as notas salvas no celular.
  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNotes = prefs.getString('user_notes');

    if (savedNotes != null) {
      try {
        final List<dynamic> decoded = jsonDecode(savedNotes);

        notes = decoded
            .map((item) => Note.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } catch (_) {
        notes = [];
      }
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Salva todas as notas no armazenamento local.
  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'user_notes',
      jsonEncode(notes.map((note) => note.toJson()).toList()),
    );
  }

  // Abre o editor de uma nota existente ou de uma nova nota.
  Future<void> _openNote({int? index}) async {
    final Note? existingNote = index != null ? notes[index] : null;

    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (_) => NoteEditorPage(initialNote: existingNote),
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      if (result == 'delete') {
        if (index != null) {
          notes.removeAt(index);
        }
      } else if (result is Note) {
        if (index != null) {
          notes[index] = result;
        } else {
          notes.insert(0, result);
        }

        // Mostra as notas mais recentes primeiro.
        notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      }
    });

    await _saveNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Barra superior.
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: orange, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: orange,
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

              const SizedBox(height: 32),

              // Painel de notas.
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: lilac,
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
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : GridView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: notes.length < 6 ? 6 : notes.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: 0.85,
                                    ),
                                itemBuilder: (context, index) {
                                  final bool hasNote = index < notes.length;

                                  return Material(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    clipBehavior: Clip.antiAlias,
                                    child: InkWell(
                                      onTap: () => _openNote(
                                        index: hasNote ? index : null,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: hasNote
                                            ? Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    notes[index].title
                                                            .trim()
                                                            .isEmpty
                                                        ? 'Sem título'
                                                        : notes[index].title,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF594A6D),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Expanded(
                                                    child: Text(
                                                      notes[index].content,
                                                      maxLines: 7,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    '${notes[index].updatedAt.day.toString().padLeft(2, '0')}/'
                                                    '${notes[index].updatedAt.month.toString().padLeft(2, '0')}/'
                                                    '${notes[index].updatedAt.year}',
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : const SizedBox.expand(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Botão para criar uma nova nota.
      floatingActionButton: FloatingActionButton(
        onPressed: isLoading ? null : () => _openNote(),
        backgroundColor: orange,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}

// ==========================================================
// TELA DE CRIAÇÃO E EDIÇÃO DE NOTAS
// ==========================================================

class NoteEditorPage extends StatefulWidget {
  final Note? initialNote;

  const NoteEditorPage({super.key, this.initialNote});

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  static const Color lilac = Color(0xFFEADBFF);
  static const Color orange = Color(0xFFFFB08E);

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
        const SnackBar(content: Text('Escreva algo antes de salvar.')),
      );
      return;
    }

    Navigator.pop(context, Note(title: title, content: content));
  }

  void _deleteNote() {
    Navigator.pop(context, 'delete');
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.initialNote != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: orange),
        ),
        title: Text(
          isEditing ? 'Editar nota' : 'Nova nota',
          style: const TextStyle(
            color: Color(0xFF594A6D),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Salvar nota',
            onPressed: _saveNote,
            icon: const Icon(Icons.check, color: orange, size: 28),
          ),
        ],
      ),
      body: Padding(
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
                fillColor: lilac.withValues(alpha: 0.35),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  fillColor: lilac.withValues(alpha: 0.25),
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
                child: TextButton.icon(
                  onPressed: _deleteNote,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  label: const Text(
                    'Excluir nota',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
