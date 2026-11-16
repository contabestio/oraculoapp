import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Widget inteligente para renderização de conteúdo de livros e materiais de estudo.
///
/// Suporta de forma dinâmica e elegante:
/// 1. Negrito com markdown (`**texto**`, `__texto__`) ou tags HTML (`<b>texto</b>`).
/// 2. Quebras de linha simples (`\n`) e parágrafos estruturados (`\n\n`).
/// 3. Subtítulos / Tópicos com marcadores (`### Título`, `## Título`, `# Título`, ou `<Título>`).
/// 4. Listas com marcadores estilizados (`• `, `- `, `* `).
/// 5. Listas numeradas com badges visuais (`1. `, `2. `).
/// 6. Caixas de destaque e citações (`> texto`).
/// 7. Fórmulas e leis matemáticas / físicas em cartões destacados.
/// 8. Destaque automático de palavras-chave antes de dois-pontos (`Termo: definição`).
class FormattedBookContent extends StatelessWidget {
  final String content;
  final double fontSize;
  final bool selectable;
  final Color? textColor;

  const FormattedBookContent({
    super.key,
    required this.content,
    this.fontSize = 14.5,
    this.selectable = true,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    if (content.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final blocks = _parseBlocks(content);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < blocks.length; i++) ...[
          _buildBlockWidget(context, blocks[i]),
          if (i < blocks.length - 1)
            SizedBox(
              height: _getSpacingAfterBlock(blocks[i], blocks[i + 1]),
            ),
        ],
      ],
    );
  }

  double _getSpacingAfterBlock(_ContentBlock current, _ContentBlock next) {
    if (current.type == _BlockType.heading) {
      return 10.0;
    }
    if (current.type == _BlockType.bulletList && next.type == _BlockType.bulletList) {
      return 6.0;
    }
    if (current.type == _BlockType.numberedList && next.type == _BlockType.numberedList) {
      return 6.0;
    }
    return 14.0;
  }

  Widget _buildBlockWidget(BuildContext context, _ContentBlock block) {
    switch (block.type) {
      case _BlockType.heading:
        return _buildHeadingWidget(block.text);

      case _BlockType.bulletList:
        return _buildBulletItemWidget(block.text);

      case _BlockType.numberedList:
        return _buildNumberedItemWidget(block.index ?? 1, block.text);

      case _BlockType.callout:
        return _buildCalloutWidget(block.text);

      case _BlockType.formula:
        return _buildFormulaWidget(block.text);

      case _BlockType.paragraph:
        return _buildParagraphWidget(block.text);
    }
  }

  // ==========================================================================
  // CONSTRUTORES DE WIDGETS POR TIPO DE BLOCO
  // ==========================================================================

  Widget _buildHeadingWidget(String text) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 4,
            height: fontSize + 5,
            decoration: BoxDecoration(
              color: AppTheme.orange,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: parseInlineSpans(
                  text,
                  baseStyle: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: fontSize + 2.5,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkTextHeading,
                    height: 1.3,
                  ),
                  boldStyle: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: fontSize + 2.5,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.orangeDark,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletItemWidget(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: fontSize * 0.45, right: 10),
            width: 6.5,
            height: 6.5,
            decoration: const BoxDecoration(
              color: AppTheme.orange,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: parseInlineSpans(
                  text,
                  autoBoldLeadingLabel: true,
                  baseStyle: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: fontSize,
                    color: textColor ?? AppTheme.darkText,
                    height: 1.55,
                  ),
                  boldStyle: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkTextHeading,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberedItemWidget(int number, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 10, top: 1),
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.orangeBg,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: AppTheme.orange.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                fontFamily: 'Arial',
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: AppTheme.orangeDark,
              ),
            ),
          ),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: parseInlineSpans(
                  text,
                  autoBoldLeadingLabel: true,
                  baseStyle: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: fontSize,
                    color: textColor ?? AppTheme.darkText,
                    height: 1.55,
                  ),
                  boldStyle: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkTextHeading,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalloutWidget(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.orangeBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.orange.withValues(alpha: 0.35)),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 5,
              color: AppTheme.orange,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.format_quote_rounded,
                      color: AppTheme.orangeDark,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: parseInlineSpans(
                            text,
                            baseStyle: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: fontSize - 0.5,
                              fontStyle: FontStyle.italic,
                              color: AppTheme.darkTextHeading,
                              height: 1.5,
                            ),
                            boldStyle: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: fontSize - 0.5,
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.orangeDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormulaWidget(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F7FD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.lilacContainer),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.functions_rounded,
              color: AppTheme.darkPurple,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: parseInlineSpans(
                  text,
                  baseStyle: TextStyle(
                    fontFamily: 'Courier',
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkPurple,
                    height: 1.4,
                  ),
                  boldStyle: TextStyle(
                    fontFamily: 'Courier',
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkTextHeading,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParagraphWidget(String text) {
    return Text.rich(
      TextSpan(
        children: parseInlineSpans(
          text,
          baseStyle: TextStyle(
            fontFamily: 'Arial',
            fontSize: fontSize,
            color: textColor ?? AppTheme.darkText,
            height: 1.65,
          ),
          boldStyle: TextStyle(
            fontFamily: 'Arial',
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkTextHeading,
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // PARSER DE BLOCOS DE CONTEÚDO
  // ==========================================================================

  static List<_ContentBlock> _parseBlocks(String rawText) {
    final List<_ContentBlock> result = [];

    // 1. Normaliza quebras de linha
    String normalized = rawText
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n');

    // 2. Extrai títulos inseridos entre <tags> no meio de sentenças
    // Exemplo: "...Altamira (Espanha).  <Características da arte no paleolítico> Essas primeiras..."
    normalized = normalized.replaceAllMapped(
      RegExp(r'\s*<([A-Za-zÀ-ÖØ-öø-ÿ0-9\s,\.:/\-—]+)>\s*'),
      (match) => '\n\n### ${match.group(1)?.trim()}\n\n',
    );

    // 3. Divide por quebras de parágrafo duplas
    final rawParagraphs = normalized.split(RegExp(r'\n{2,}'));

    for (final rawPara in rawParagraphs) {
      final trimmedPara = rawPara.trim();
      if (trimmedPara.isEmpty) continue;

      final lines = trimmedPara.split('\n');

      // Se todas as linhas forem itens de lista (com marcadores ou números),
      // processamos linha a linha
      bool allListItems = true;
      for (final line in lines) {
        final t = line.trim();
        if (t.isEmpty) continue;
        final isBullet = _isBulletLine(t);
        final isNumbered = _isNumberedLine(t);
        if (!isBullet && !isNumbered) {
          allListItems = false;
          break;
        }
      }

      if (allListItems && lines.length > 1) {
        for (final line in lines) {
          final t = line.trim();
          if (t.isEmpty) continue;
          _addSingleLineBlock(result, t);
        }
        continue;
      }

      // Se for apenas 1 linha ou parágrafo padrão
      if (lines.length == 1) {
        _addSingleLineBlock(result, trimmedPara);
      } else {
        // Verifica se a primeira linha é um cabeçalho
        if (_isHeadingLine(lines.first.trim())) {
          _addSingleLineBlock(result, lines.first.trim());
          final remaining = lines.sublist(1).join('\n').trim();
          if (remaining.isNotEmpty) {
            _parseMultiLineParagraph(result, remaining);
          }
        } else {
          _parseMultiLineParagraph(result, trimmedPara);
        }
      }
    }

    return result;
  }

  static void _parseMultiLineParagraph(List<_ContentBlock> result, String text) {
    final lines = text.split('\n');
    final List<String> currentParagraphLines = [];

    for (final line in lines) {
      final t = line.trim();
      if (t.isEmpty) continue;

      if (_isBulletLine(t) || _isNumberedLine(t) || _isHeadingLine(t) || _isCalloutLine(t)) {
        if (currentParagraphLines.isNotEmpty) {
          result.add(_ContentBlock(
            type: _BlockType.paragraph,
            text: currentParagraphLines.join(' '),
          ));
          currentParagraphLines.clear();
        }
        _addSingleLineBlock(result, t);
      } else {
        currentParagraphLines.add(t);
      }
    }

    if (currentParagraphLines.isNotEmpty) {
      result.add(_ContentBlock(
        type: _BlockType.paragraph,
        text: currentParagraphLines.join(' '),
      ));
    }
  }

  static void _addSingleLineBlock(List<_ContentBlock> result, String line) {
    if (_isHeadingLine(line)) {
      final cleanText = line
          .replaceFirst(RegExp(r'^#{1,6}\s*'), '')
          .replaceFirst(RegExp(r'^<|>'), '')
          .trim();
      result.add(_ContentBlock(type: _BlockType.heading, text: cleanText));
    } else if (_isCalloutLine(line)) {
      final cleanText = line
          .replaceFirst(RegExp(r'^(>\s*|💡\s*)'), '')
          .trim();
      result.add(_ContentBlock(type: _BlockType.callout, text: cleanText));
    } else if (_isFormulaLine(line)) {
      final cleanText = line
          .replaceAll('```', '')
          .trim();
      result.add(_ContentBlock(type: _BlockType.formula, text: cleanText));
    } else if (_isNumberedLine(line)) {
      final match = RegExp(r'^(\d+)[\.\)]\s*(.*)$').firstMatch(line);
      final number = int.tryParse(match?.group(1) ?? '1') ?? 1;
      final text = match?.group(2)?.trim() ?? line;
      result.add(_ContentBlock(
        type: _BlockType.numberedList,
        text: text,
        index: number,
      ));
    } else if (_isBulletLine(line)) {
      final cleanText = line
          .replaceFirst(RegExp(r'^[•\-\*\+]\s*'), '')
          .trim();
      result.add(_ContentBlock(type: _BlockType.bulletList, text: cleanText));
    } else {
      result.add(_ContentBlock(type: _BlockType.paragraph, text: line));
    }
  }

  static bool _isHeadingLine(String line) {
    return RegExp(r'^#{1,6}\s+').hasMatch(line) ||
        RegExp(r'^<[^>]+>$').hasMatch(line);
  }

  static bool _isCalloutLine(String line) {
    return line.startsWith('>') || line.startsWith('💡');
  }

  static bool _isFormulaLine(String line) {
    return line.startsWith('```') ||
        RegExp(r'^(f\(x\)\s*=|V\s*=|FR\s*=|P\s*=|ax\s*\+\s*b\s*=)').hasMatch(line);
  }

  static bool _isBulletLine(String line) {
    return RegExp(r'^[•\-\*\+]\s+').hasMatch(line);
  }

  static bool _isNumberedLine(String line) {
    return RegExp(r'^\d+[\.\)]\s+').hasMatch(line);
  }

  // ==========================================================================
  // PARSER DE TEXTO INLINE (NEGRITO, ITÁLICO, CÓDIGO E DOIS-PONTOS)
  // ==========================================================================

  /// Converte texto bruto com markdown/tags em uma lista de [InlineSpan]s estilizados.
  static List<InlineSpan> parseInlineSpans(
    String rawText, {
    TextStyle? baseStyle,
    TextStyle? boldStyle,
    TextStyle? italicStyle,
    TextStyle? codeStyle,
    bool autoBoldLeadingLabel = false,
  }) {
    final List<InlineSpan> spans = [];

    // Se autoBoldLeadingLabel estiver ativado e o texto tiver um formato como:
    // "1. AGENTE: Quem executará a ação?" ou "Álcool: Hidroxila (-OH)..."
    // e o texto ainda não tiver markdown explícito no início,
    // garantimos que o rótulo inicial seja destacado em negrito!
    String textToParse = rawText;
    if (autoBoldLeadingLabel) {
      final labelMatch = RegExp(r'^([A-Za-zÀ-ÖØ-öø-ÿ0-9\.\s()/\-—]+:)(.*)$')
          .firstMatch(textToParse);
      if (labelMatch != null &&
          !textToParse.startsWith('**') &&
          !textToParse.startsWith('<b>')) {
        final label = labelMatch.group(1)!;
        final rest = labelMatch.group(2)!;
        textToParse = '**$label**$rest';
      }
    }

    // Expressão regular para capturar negrito, itálico, código e tags HTML
    // 1: **bold** ou __bold__
    // 2: <b>bold</b> ou <strong>bold</strong>
    // 3: *italic* ou _italic_
    // 4: <i>italic</i> ou <em>italic</em>
    // 5: `code`
    final pattern = RegExp(
      r'(\*\*(.*?)\*\*|__(.*?)__)|'
      r'(<b>(.*?)<\/b>|<strong>(.*?)<\/strong>)|'
      r'(\*(.*?)\*|_(.*?)_)|'
      r'(<i>(.*?)<\/i>|<em>(.*?)<\/em>)|'
      r'(`(.*?)`)',
      dotAll: true,
    );

    int currentIndex = 0;

    for (final match in pattern.allMatches(textToParse)) {
      // Texto simples anterior ao marcador
      if (match.start > currentIndex) {
        final plainText = textToParse.substring(currentIndex, match.start);
        spans.add(TextSpan(text: plainText, style: baseStyle));
      }

      final fullMatch = match.group(0) ?? '';

      if (fullMatch.startsWith('**') ||
          fullMatch.startsWith('__') ||
          fullMatch.startsWith('<b>') ||
          fullMatch.startsWith('<strong>')) {
        // Negrito
        final innerText = match.group(2) ??
            match.group(3) ??
            match.group(5) ??
            match.group(6) ??
            fullMatch;
        spans.add(TextSpan(
          text: innerText,
          style: boldStyle ??
              (baseStyle != null
                  ? baseStyle.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkTextHeading,
                    )
                  : const TextStyle(fontWeight: FontWeight.bold)),
        ));
      } else if (fullMatch.startsWith('*') ||
          fullMatch.startsWith('_') ||
          fullMatch.startsWith('<i>') ||
          fullMatch.startsWith('<em>')) {
        // Itálico
        final innerText = match.group(8) ??
            match.group(9) ??
            match.group(11) ??
            match.group(12) ??
            fullMatch;
        spans.add(TextSpan(
          text: innerText,
          style: italicStyle ??
              (baseStyle != null
                  ? baseStyle.copyWith(fontStyle: FontStyle.italic)
                  : const TextStyle(fontStyle: FontStyle.italic)),
        ));
      } else if (fullMatch.startsWith('`')) {
        // Código / Fórmula inline
        final innerText = match.group(14) ?? fullMatch;
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF1EDF8),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.lilacContainer),
            ),
            child: Text(
              innerText,
              style: codeStyle ??
                  TextStyle(
                    fontFamily: 'Courier',
                    fontSize: (baseStyle?.fontSize ?? 14) * 0.95,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkPurple,
                  ),
            ),
          ),
        ));
      }

      currentIndex = match.end;
    }

    // Texto restante após o último casamento
    if (currentIndex < textToParse.length) {
      final trailingText = textToParse.substring(currentIndex);
      spans.add(TextSpan(text: trailingText, style: baseStyle));
    }

    return spans;
  }
}

enum _BlockType {
  heading,
  paragraph,
  bulletList,
  numberedList,
  callout,
  formula,
}

class _ContentBlock {
  final _BlockType type;
  final String text;
  final int? index;

  const _ContentBlock({
    required this.type,
    required this.text,
    this.index,
  });
}
