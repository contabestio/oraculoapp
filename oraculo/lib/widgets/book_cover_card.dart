import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'animations.dart';

class BookCoverCard extends StatefulWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onTap;
  final double? width;
  final double? height;

  /// Standard width for books throughout the application
  static const double standardWidth = 140.0;

  /// Standard height for books throughout the application (cover + title)
  static const double standardHeight = 220.0;

  /// Standard aspect ratio for book cards (width / height)
  static const double standardAspectRatio = standardWidth / standardHeight;

  const BookCoverCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.onTap,
    this.width,
    this.height,
  });

  @override
  State<BookCoverCard> createState() => _BookCoverCardState();
}

class _BookCoverCardState extends State<BookCoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedHeight = constraints.hasBoundedHeight;
        final effectiveWidth = widget.width;
        final effectiveHeight =
            widget.height ?? (hasBoundedHeight ? null : BookCoverCard.standardHeight);

        final Widget bookCover = AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          transform: _isHovered
              ? (Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(-0.35)
                ..setTranslationRaw(0.0, -10.0, 0.0))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(6),
              bottomRight: Radius.circular(6),
              topLeft: Radius.circular(3),
              bottomLeft: Radius.circular(3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered ? 0.35 : 0.12),
                blurRadius: _isHovered ? 24 : 10,
                offset: Offset(_isHovered ? -16 : 0, _isHovered ? 16 : 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(6),
              bottomRight: Radius.circular(6),
              topLeft: Radius.circular(3),
              bottomLeft: Radius.circular(3),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Imagem da capa ou fallback original
                Image.network(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppTheme.lilac,
                    child: const Icon(
                      Icons.menu_book_rounded,
                      size: 48,
                      color: AppTheme.darkText,
                    ),
                  ),
                ),

                // Sombra da lombada do livro (efeito original)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 18,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.35),
                          Colors.white.withValues(alpha: 0.2),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.25, 1.0],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),

                // Borda das folhas do livro (efeito original)
                Positioned(
                  right: 0,
                  top: 2,
                  bottom: 2,
                  width: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EAE1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),

                // Brilho acetinado na capa
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: _isHovered ? 0.15 : 0.05),
                        Colors.transparent,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        final bool hasTitle = widget.title.trim().isNotEmpty;

        Widget content;
        if (hasTitle) {
          content = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(child: bookCover),
              const SizedBox(height: 10),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkText,
                  height: 1.2,
                ),
              ),
            ],
          );
        } else {
          content = bookCover;
        }

        Widget card = BouncingPressable(
          onTap: widget.onTap,
          scaleFactor: 0.96,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: content,
          ),
        );

        if (effectiveWidth != null || effectiveHeight != null) {
          card = SizedBox(
            width: effectiveWidth,
            height: effectiveHeight,
            child: card,
          );
        }

        return card;
      },
    );
  }
}