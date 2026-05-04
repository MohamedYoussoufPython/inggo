import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/inggo_theme.dart';
import '../../widget/inggo_button.dart';
import 'package:go_router/go_router.dart';

class RideRequestScreen extends StatefulWidget {
  const RideRequestScreen({super.key});

  @override
  State<RideRequestScreen> createState() => _RideRequestScreenState();
}

class _RideRequestScreenState extends State<RideRequestScreen>
    with TickerProviderStateMixin {
  static const int _totalSeconds = 18;
  int _secondsLeft = _totalSeconds;
  Timer? _timer;
  bool _accepted = false;
  bool _declined = false;
  bool _showWarning = false;

  // Animations
  late AnimationController _cardController;
  late Animation<double> _cardScale;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    // Card pop-in animation
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _cardScale = CurvedAnimation(
      parent: _cardController,
      curve: Curves.elasticOut,
    );
    _cardController.forward();

    // Pulse animation for border
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        _handleTimeout();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _handleTimeout() {
    HapticFeedback.heavyImpact();
    setState(() {
      _declined = true;
      _secondsLeft = 0;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.maybePop(context);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cardController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleAccept() {
    _timer?.cancel();
    HapticFeedback.heavyImpact();
    setState(() => _accepted = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        context.go('/ride');
      }
    });
  }

  void _handleRefuse() {
    HapticFeedback.mediumImpact();
    setState(() => _showWarning = true);
  }

  void _confirmRefuse() {
    _timer?.cancel();
    setState(() {
      _showWarning = false;
      _declined = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.maybePop(context);
    });
  }

  double get _progress => _secondsLeft / _totalSeconds;

  Color get _timerColor {
    if (_secondsLeft > 10) return InggoColors.success;
    if (_secondsLeft > 5) return InggoColors.primary;
    return InggoColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: InggoColors.text1,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A1A2E), Color(0xFF121212)],
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Center(
              child: ScaleTransition(scale: _cardScale, child: _buildCard()),
            ),
          ),

          // Warning modal overlay
          if (_showWarning) _buildWarningOverlay(),
        ],
      ),
    );
  }

  Widget _buildCard() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, child) {
        final pulseValue = _pulseController.value;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: _timerColor.withValues(alpha: 0.15 + pulseValue * 0.15),
                blurRadius: 40 + pulseValue * 20,
                spreadRadius: pulseValue * 4,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBanner(),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  children: [
                    _buildPassengerRow(),
                    const SizedBox(height: 20),
                    _buildRoute(),
                    const SizedBox(height: 6),
                    _buildDetails(),
                    const SizedBox(height: 24),
                    if (!_accepted && !_declined) _buildActionButtons(),
                    if (_accepted)
                      _buildStatusMessage(
                        Icons.check_circle,
                        InggoColors.success,
                        'Course acceptée !',
                      ),
                    if (_declined)
                      _buildStatusMessage(
                        Icons.cancel,
                        InggoColors.error,
                        'Course refusée',
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBanner() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      decoration: const BoxDecoration(
        color: Color(0xFFFFC107),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Row(
        children: [
          // Timer circle
          SizedBox(
            width: 52,
            height: 52,
            child: Stack(
              children: [
                CircularProgressIndicator(
                  value: _progress,
                  strokeWidth: 4,
                  backgroundColor: Colors.black.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _secondsLeft <= 5
                        ? InggoColors.error
                        : const Color(0xFF121212),
                  ),
                ),
                Center(
                  child: Text(
                    '${_secondsLeft}s',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: _secondsLeft <= 5
                          ? InggoColors.error
                          : const Color(0xFF121212),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nouvelle Course !',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF121212),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Un passager vous attend',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF333333),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '250 FDJ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Color(0xFF121212),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerRow() {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: InggoColors.border1,
            shape: BoxShape.circle,
            border: Border.all(color: InggoColors.primary, width: 2),
          ),
          child: const Icon(Icons.person, color: Color(0xFF757575), size: 28),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Amin M.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.star, size: 14, color: Color(0xFFFFC107)),
                  SizedBox(width: 3),
                  Text(
                    '4.8',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF757575),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '• 12 courses',
                    style: TextStyle(fontSize: 12, color: Color(0xFF757575)),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: InggoColors.border1,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.location_on, size: 14, color: Color(0xFFFFC107)),
              SizedBox(width: 4),
              Text(
                '1.2 km',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoute() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: InggoColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Dots timeline
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF43A047),
                  shape: BoxShape.circle,
                ),
              ),
              Container(width: 2, height: 24, color: InggoColors.border2),
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFFD32F2F),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gabode 5',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 16),
                Text(
                  'Palais du Peuple',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _DetailChip(icon: Icons.straighten, label: '3.5 km'),
          _DetailChip(icon: Icons.schedule, label: '~8 min'),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: InggoButton(
            label: 'Refuser',
            variant: InggoButtonVariant.danger,
            icon: Icons.close,
            onPressed: _handleRefuse,
            height: 52,
            borderRadius: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: InggoButton(
            label: 'Accepter',
            icon: Icons.check,
            onPressed: _handleAccept,
            height: 52,
            borderRadius: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusMessage(IconData icon, Color color, String text) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.elasticOut,
      builder: (_, v, child) => Transform.scale(scale: v, child: child),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningOverlay() {
    return GestureDetector(
      onTap: () => setState(() => _showWarning = false),
      child: Container(
        color: Colors.black54,
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent dismiss on card tap
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFEBEE),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFD32F2F),
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Refuser la course ?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Refuser trop de courses peut affecter votre score et réduire les courses proposées.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  InggoButton(
                    label: 'Confirmer le refus',
                    variant: InggoButtonVariant.danger,
                    icon: Icons.close,
                    onPressed: _confirmRefuse,
                    height: 48,
                  ),
                  const SizedBox(height: 10),
                  InggoButton(
                    label: 'Annuler',
                    variant: InggoButtonVariant.ghost,
                    onPressed: () => setState(() => _showWarning = false),
                    height: 44,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: InggoColors.text3),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF757575),
          ),
        ),
      ],
    );
  }
}
