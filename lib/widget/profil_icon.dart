import 'package:flutter/material.dart';

class ProfilIcon extends StatelessWidget {
  final VoidCallback? onTap;

  const ProfilIcon({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFE8E8E8),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(
          Icons.person_rounded,
          size: 22,
          color: Color(0xFF1A1A1A),
        ),
      ),
    );
  }
}
