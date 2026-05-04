import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/inggo_theme.dart';
import '../../provider/ride_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final int? rideId;
  const SearchScreen({super.key, this.rideId});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with TickerProviderStateMixin {
  int _seconds = 0;
  Timer? _timer;
  Timer? _driverFoundTimer;

  // Animation : 3 ondes radar concentriques
  late AnimationController _wave1;
  late AnimationController _wave2;
  late AnimationController _wave3;
  // Animation : rotation de l'anneau extérieur
  late AnimationController _ring;
  // Animation : pulse du cercle central
  late AnimationController _pulse;
  // Animation : points de chargement texte
  int _dotsCount = 1;
  Timer? _dotsTimer;

  // Nouveau : pour l'overlay de conducteur trouvé
  bool _driverFound = false;
  Map<String, dynamic>? _assignedDriver;
  StreamSubscription? _rideSubscription;

  @override
  void initState() {
    super.initState();

    _wave1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _wave2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _wave3 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    // Décalage des ondes
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _wave2.forward(from: 0.33);
    });
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) _wave3.forward(from: 0.66);
    });

    _ring = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _dotsTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) setState(() => _dotsCount = (_dotsCount % 3) + 1);
    });

    _startTimer();
    _initRideSubscription();
  }

  void _initRideSubscription() {
    if (widget.rideId == null) {
      _simulateDriverFound(); // Fallback simulation if no ID
      return;
    }

    _rideSubscription = ref
        .read(rideProvider.notifier)
        .watchRide(widget.rideId!)
        .listen((ride) {
      if (ride != null &&
          ride['status'] == 'accepted' &&
          ride['driver_id'] != null) {
        setState(() {
          _assignedDriver = ride;
        });
        _showDriverFoundOverlay();
      } else if (ride != null && ride['status'] == 'cancelled') {
        _timer?.cancel();
        context.go('/booking');
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
  }

  void _simulateDriverFound() {
    _driverFoundTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) _showDriverFoundOverlay();
    });
  }

  void _showDriverFoundOverlay() {
    // Arrêter le timer principal pour ne plus afficher le temps
    _timer?.cancel();
    _driverFoundTimer?.cancel();

    setState(() {
      _driverFound = true;
    });

    // Après 2,5 secondes, naviguer vers l'écran de suivi
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        context.go('/trip-in-progress', extra: {
          'rideId': widget.rideId,
          'driverData': _assignedDriver,
        });
      }
    });
  }

  @override
  void dispose() {
    _rideSubscription?.cancel();
    _timer?.cancel();
    _driverFoundTimer?.cancel();
    _dotsTimer?.cancel();
    _wave1.dispose();
    _wave2.dispose();
    _wave3.dispose();
    _ring.dispose();
    _pulse.dispose();
    super.dispose();
  }

  String _formatTime(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  void _cancelSearch() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: InggoColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: InggoColors.border1,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Icône
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: InggoColors.errorLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.close_rounded,
                    color: InggoColors.error, size: 28),
              ),
              const SizedBox(height: 16),

              const Text(
                'Annuler la recherche ?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: InggoColors.text1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Un conducteur est peut-être\nen route vers vous.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14, color: InggoColors.text2, height: 1.5),
              ),
              const SizedBox(height: 28),

              Row(children: [
                Expanded(
                  child: _OutlineBtn(
                    label: 'Continuer',
                    onTap: () => Navigator.pop(ctx),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DangerBtn(
                    label: 'Annuler',
                    onTap: () async {
                      Navigator.pop(ctx);
                      _timer?.cancel();
                      _rideSubscription?.cancel();
                      if (widget.rideId != null) {
                        await ref
                            .read(rideProvider.notifier)
                            .cancelRide(widget.rideId!);
                      }
                      context.go('/booking');
                    },
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // ── Onde radar ──────────────────────────────────────────────
  Widget _buildWave(AnimationController ctrl, double size) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        final v = ctrl.value;
        final scale = 0.6 + v * 1.4;
        final opacity = (1.0 - v).clamp(0.0, 1.0);
        return Transform.scale(
          scale: scale,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: InggoColors.primary.withValues(alpha: opacity * 0.6),
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Anneau rotatif ───────────────────────────────────────────
  Widget _buildRing(double size) {
    return RotationTransition(
      turns: _ring,
      child: Container(
        width: size + 4,
        height: size + 4,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: CustomPaint(
          painter: _DashedRingPainter(ringSize: size + 4),
        ),
      ),
    );
  }

  // ── Cercle central ───────────────────────────────────────────
  Widget _buildCenter(double size) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) {
        final scale = 0.96 + _pulse.value * 0.04;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: InggoColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: InggoColors.primary
                      .withValues(alpha: 0.35 + _pulse.value * 0.15),
                  blurRadius: 24 + _pulse.value * 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              Icons.sports_motorsports_rounded,
              size: size * 0.3,
              color: InggoColors.text1,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: InggoColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;
            final isSmall = screenWidth < 360;

            // Taille de l'animation : 60% de la largeur, bornée entre 180 et 250
            final animSize = (screenWidth * 0.6).clamp(180.0, 250.0);
            final centerSize = animSize - 40;

            // Espacements proportionnels
            final double headerBottomPadding = screenHeight * 0.02;
            final double animTopSpacing = screenHeight * 0.02;
            final double textSpacing = screenHeight * 0.015;
            final double cardSpacing = screenHeight * (isSmall ? 0.02 : 0.03);

            final dots = '.' * _dotsCount;

            return Stack(
              children: [
                // Contenu principal (scrollable)
                Column(
                  children: [
                    // Header
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        isSmall ? 16 : 20,
                        16,
                        isSmall ? 16 : 20,
                        headerBottomPadding,
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: _cancelSearch,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: InggoColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: InggoColors.border1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: InggoColors.text2,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              'Recherche en cours',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: InggoColors.text1,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: InggoColors.primaryLight,
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: InggoColors.primaryBorder),
                            ),
                            child: Text(
                              _formatTime(_seconds),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: InggoColors.primaryDark,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Zone centrale (peut défiler)
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: animTopSpacing),
                            // Animation radar
                            SizedBox(
                              width: animSize + 40,
                              height: animSize + 40,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  _buildWave(_wave1, animSize),
                                  _buildWave(_wave2, animSize),
                                  _buildWave(_wave3, animSize),
                                  _buildRing(animSize),
                                  _buildCenter(centerSize),
                                ],
                              ),
                            ),
                            SizedBox(height: textSpacing * 2),
                            // Texte principal
                            Text(
                              'Recherche d\'un conducteur',
                              style: TextStyle(
                                fontSize: isSmall ? 20 : 22,
                                fontWeight: FontWeight.w700,
                                color: InggoColors.text1,
                                letterSpacing: -0.3,
                              ),
                            ),
                            SizedBox(height: textSpacing),
                            Text(
                              'Nous trouvons le meilleur conducteur\ndisponible près de vous$dots',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isSmall ? 13 : 15,
                                color: InggoColors.text2,
                                height: 1.6,
                              ),
                            ),
                            SizedBox(height: cardSpacing),
                            // Carte du trajet
                            Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: isSmall ? 16 : 24,
                              ),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: InggoColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: InggoColors.border1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 12,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const _RouteRow(
                                    dot: InggoColors.text1,
                                    label: 'Gabode 5, Djibouti-Ville',
                                    isFirst: true,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Container(
                                      width: 1.5,
                                      height: 20,
                                      color: InggoColors.border2,
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                    ),
                                  ),
                                  const _RouteRow(
                                    dot: InggoColors.primary,
                                    label: 'Place Ménélik, Centre-ville',
                                    isFirst: false,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: isSmall
                                  ? cardSpacing * 0.3
                                  : cardSpacing * 0.5,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bouton annuler
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        isSmall ? 16 : 24,
                        0,
                        isSmall ? 16 : 24,
                        isSmall ? 4 : 24,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: GestureDetector(
                          onTap: _cancelSearch,
                          child: Container(
                            decoration: BoxDecoration(
                              color: InggoColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: InggoColors.border2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'Annuler la recherche',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: InggoColors.text1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Overlay de confirmation (si _driverFound)
                if (_driverFound)
                  _DriverFoundOverlay(driverData: _assignedDriver),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  Overlay "Conducteur trouvé"
// ─────────────────────────────────────────

class _DriverFoundOverlay extends StatefulWidget {
  final Map<String, dynamic>? driverData;

  const _DriverFoundOverlay({this.driverData});

  @override
  State<_DriverFoundOverlay> createState() => _DriverFoundOverlayState();
}

class _DriverFoundOverlayState extends State<_DriverFoundOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Container(
        color: Colors.black.withValues(alpha: 0.55),
        child: Center(
          child: SlideTransition(
            position: _slide,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 40,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icône animée
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.elasticOut,
                    builder: (_, v, child) =>
                        Transform.scale(scale: v, child: child),
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: InggoColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.sports_motorsports_rounded,
                        size: 36,
                        color: InggoColors.text1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Conducteur trouvé !',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: InggoColors.text1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Infos conducteur (à remplacer par les vraies données)
                  Text(
                    widget.driverData != null
                        ? '${widget.driverData!['driver_name']} · ★ 5.0'
                        : 'Khaireh A. · ★ 4.8',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // ETA
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: InggoColors.primaryLight,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: InggoColors.primaryBorder),
                    ),
                    child: const Text(
                      'Arrive dans 3 min',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: InggoColors.primaryDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Barre de progression automatique
                  _AutoProgressBar(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Barre de progression qui se remplit en 2.5s
class _AutoProgressBar extends StatefulWidget {
  @override
  State<_AutoProgressBar> createState() => _AutoProgressBarState();
}

class _AutoProgressBarState extends State<_AutoProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => LinearProgressIndicator(
              value: _ctrl.value,
              backgroundColor: const Color(0xFFE8E8E8),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(InggoColors.primary),
              minHeight: 4,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Suivi du trajet en cours...',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
//  Composants annexes (inchangés)
// ─────────────────────────────────────────

class _RouteRow extends StatelessWidget {
  final Color dot;
  final String label;
  final bool isFirst;

  const _RouteRow({
    required this.dot,
    required this.label,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: dot,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isFirst ? FontWeight.w600 : FontWeight.w400,
              color: isFirst ? InggoColors.text1 : InggoColors.text2,
            ),
          ),
        ),
      ],
    );
  }
}

class _OutlineBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _OutlineBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: InggoColors.surface,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: InggoColors.border2),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: InggoColors.text1,
            ),
          ),
        ),
      ),
    );
  }
}

class _DangerBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DangerBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: InggoColors.errorLight,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: InggoColors.error,
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedRingPainter extends CustomPainter {
  final double ringSize;

  const _DashedRingPainter({required this.ringSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFC700).withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = ringSize / 2 - 2;
    const dashCount = 24;
    const dashAngle = 0.18;
    const gapAngle = (3.14159 * 2 / dashCount) - dashAngle;

    double angle = 0;
    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        angle,
        dashAngle,
        false,
        paint,
      );
      angle += dashAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRingPainter oldDelegate) {
    return ringSize != oldDelegate.ringSize;
  }
}
