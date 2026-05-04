import 'package:flutter/material.dart';

/// Widget accordéon pour la FAQ (question/réponse avec chevron rotatif).
class FaqAccordion extends StatefulWidget {
  final String question;
  final String answer;

  const FaqAccordion({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  State<FaqAccordion> createState() => _FaqAccordionState();
}

class _FaqAccordionState extends State<FaqAccordion>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _expansionAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _expansionAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Question header
        GestureDetector(
          onTap: _toggle,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.question,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF121212),
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
                RotationTransition(
                  turns: _rotationAnimation,
                  child: Icon(
                    Icons.expand_more,
                    color: _isOpen
                        ? const Color(0xFFFFC107)
                        : const Color(0xFFCCCCCC),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Réponse avec animation
        SizeTransition(
          sizeFactor: _expansionAnimation,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 20),
            child: Text(
              widget.answer,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF757575),
                height: 1.6,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
