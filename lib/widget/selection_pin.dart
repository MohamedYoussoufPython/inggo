import 'dart:math' as math;
import 'package:flutter/material.dart';

class SelectionPin extends StatelessWidget {
  final bool isDestination;

  const SelectionPin({
    super.key,
    required this.isDestination,
  });

  @override
  Widget build(BuildContext context) {
    // Départ → jaune Inggo / Destination → noir Inggo
    final Color backgroundColor =
        isDestination ? const Color(0xFF1A1A1A) : const Color(0xFFFFC700);

    final Color dotColor =
        isDestination ? const Color(0xFFFFC700) : const Color(0xFF1A1A1A);

    return SizedBox(
      width: 56,
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ombre au sol
          Positioned(
            bottom: 0,
            child: Container(
              width: 20,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Pin
          Transform.translate(
            offset: const Offset(0, -10),
            child: Transform.rotate(
              angle: -math.pi / 4,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomLeft: Radius.zero,
                    bottomRight: Radius.circular(23),
                  ),
                  border: Border.all(                    color: Colors.white,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.20),
                      blurRadius: 14,
                      offset: const Offset(3, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
