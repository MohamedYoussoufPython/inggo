import 'package:flutter/material.dart';

/// Point de localisation pulsant — couleurs Inggo Design System
/// Onde 1 : jaune #FFC700, opacity 0.6 → 0
/// Onde 2 : jaune #FFC700, opacity 0.4 → 0, délai 1s
/// Point central : #1A1A1A avec bordure blanche
class PulsatingLocationPin extends StatefulWidget {
  const PulsatingLocationPin({super.key});

  @override
  State<PulsatingLocationPin> createState() => _PulsatingLocationPinState();
}

class _PulsatingLocationPinState extends State<PulsatingLocationPin>
    with TickerProviderStateMixin {
  late AnimationController _wave1Controller;
  late AnimationController _wave2Controller;

  static const double _pinSize = 22.0;
  static const double _maxWave = 80.0;

  @override
  void initState() {
    super.initState();

    _wave1Controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _wave2Controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) _wave2Controller.repeat();
    });
  }

  @override
  void dispose() {
    _wave1Controller.dispose();
    _wave2Controller.dispose();
    super.dispose();
  }

  Widget _buildWave(AnimationController ctrl, double maxOpacity) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        final v = Curves.easeOut.transform(ctrl.value);
        final size = _pinSize + (_maxWave - _pinSize) * v;
        final opacity = maxOpacity * (1 - v);
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFFC700).withValues(alpha: opacity),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _maxWave,
      height: _maxWave,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildWave(_wave1Controller, 0.45),
          _buildWave(_wave2Controller, 0.25),

          // Point central
          Container(
            width: _pinSize,
            height: _pinSize,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              shape: BoxShape.circle,
              border: const Border.all(                color: Colors.white,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.20),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
