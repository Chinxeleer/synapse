import 'package:flutter/material.dart';
import 'package:multilingual/features/text_translation/data/definition_service.dart';

class TappableWord extends StatefulWidget {
  final String word;
  final TextStyle? style;

  const TappableWord({
    super.key,
    required this.word,
    this.style,
  });

  @override
  State<TappableWord> createState() => _TappableWordState();
}

class _TappableWordState extends State<TappableWord> {
  OverlayEntry? _overlayEntry;
  final GlobalKey _wordKey = GlobalKey();

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> _onTap() async {
    if (_overlayEntry != null) {
      _removeOverlay();
      return;
    }

    final cleanWord = widget.word.replaceAll(RegExp(r'[^\w]'), '');
    if (cleanWord.isEmpty) return;

    _showOverlay(word: cleanWord, definition: null, isLoading: true);

    try {
      final definition = await DefinitionService.defineWord(cleanWord);
      _removeOverlay();
      if (mounted) {
        _showOverlay(word: cleanWord, definition: definition, isLoading: false);
      }
    } catch (e) {
      _removeOverlay();
      if (mounted) {
        _showOverlay(
          word: cleanWord,
          definition: 'Could not load definition.',
          isLoading: false,
        );
      }
    }
  }

  void _showOverlay({
    required String word,
    required String? definition,
    required bool isLoading,
  }) {
    final renderBox =
        _wordKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final wordPosition = renderBox.localToGlobal(Offset.zero);
    final wordSize = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        const popupWidth = 220.0;

        double left =
            wordPosition.dx + (wordSize.width / 2) - (popupWidth / 2);
        left = left.clamp(12.0, screenWidth - popupWidth - 12.0);

        final top = wordPosition.dy - (isLoading ? 60 : 110);

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _removeOverlay,
                behavior: HitTestBehavior.translucent,
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              left: left,
              top: top,
              child: _DefinitionPopup(
                word: word,
                definition: definition,
                isLoading: isLoading,
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Text(
        '${widget.word} ',
        key: _wordKey,
        style: (widget.style ?? DefaultTextStyle.of(context).style).copyWith(
          decoration: TextDecoration.underline,
          decorationStyle: TextDecorationStyle.dotted,
          decorationColor: const Color(0xFFE02020).withOpacity(0.5),
          decorationThickness: 1.5,
        ),
      ),
    );
  }
}

class _DefinitionPopup extends StatelessWidget {
  final String word;
  final String? definition;
  final bool isLoading;

  const _DefinitionPopup({
    required this.word,
    required this.definition,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),          // black card background
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE02020),        // red border
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE02020).withOpacity(0.15), // red glow
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 3,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE02020),  // red accent bar
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  word,
                  style: const TextStyle(
                    color: Color(0xFFFFFFFF),         // white
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            const Divider(
              color: Color(0xFF222222),              // dark divider
              height: 1,
            ),

            const SizedBox(height: 10),

            if (isLoading)
              const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFE02020),         // red spinner
                  ),
                ),
              )
            else
              Text(
                definition ?? 'No definition found.',
                style: const TextStyle(
                  color: Color(0xFFB0B0B0),           // muted white
                  fontSize: 13,
                  height: 1.5,
                ),
              ),

            const SizedBox(height: 8),

            Align(
              alignment: Alignment.bottomCenter,
              child: CustomPaint(
                size: const Size(12, 6),
                painter: _TrianglePainter(
                  color: const Color(0xFFE02020),     // red pointer triangle
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  const _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter old) => old.color != color;
}