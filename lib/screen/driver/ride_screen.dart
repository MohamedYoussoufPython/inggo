import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Ride lifecycle states
enum RideState { enRoute, arrived, inRide, completed }

class RideScreen extends StatefulWidget {
  final int? rideId;
  final String? pickupAddress;
  final String? dropoffAddress;
  final double? price;
  final String? clientName;

  const RideScreen({
    super.key,
    this.rideId,
    this.pickupAddress,
    this.dropoffAddress,
    this.price,
    this.clientName,
  });

  @override
  State<RideScreen> createState() => _RideScreenState();
}

class _RideScreenState extends State<RideScreen>
    with SingleTickerProviderStateMixin {
  static const LatLng _pickupLocation = LatLng(11.5750, 43.1450);
  static const LatLng _destinationLocation = LatLng(11.5880, 43.1470);
  static const LatLng _djiboutiCenter = LatLng(11.5850, 43.1460);

  GoogleMapController? _mapController;
  RideState _state = RideState.enRoute;
  bool _sheetExpanded = false;
  bool _showRating = false;
  int _selectedStars = 0;
  bool _ratingSubmitted = false;

  // Ride timer
  int _elapsedSeconds = 0;
  Timer? _timer;

  // Bottom sheet animation
  late AnimationController _sheetController;
  late Animation<double> _sheetHeight;

  @override
  void initState() {
    super.initState();
    _sheetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _sheetHeight = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sheetController, curve: Curves.easeOutCubic),
    );
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsedSeconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sheetController.dispose();
    super.dispose();
  }

  String get _formattedTime {
    final m = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _advanceState() {
    HapticFeedback.heavyImpact();
    setState(() {
      switch (_state) {
        case RideState.enRoute:
          _state = RideState.arrived;
          break;
        case RideState.arrived:
          _state = RideState.inRide;
          break;
        case RideState.inRide:
          _timer?.cancel();
          _state = RideState.completed;
          _showRating = true;
          break;
        case RideState.completed:
          break;
      }
    });
  }

  void _toggleSheet() {
    setState(() => _sheetExpanded = !_sheetExpanded);
    if (_sheetExpanded) {
      _sheetController.forward();
    } else {
      _sheetController.reverse();
    }
  }

  String get _actionLabel {
    switch (_state) {
      case RideState.enRoute:
        return "Je suis arrivé";
      case RideState.arrived:
        return "Démarrer la course";
      case RideState.inRide:
        return "Terminer la course";
      case RideState.completed:
        return "Terminé";
    }
  }

  IconData get _actionIcon {
    switch (_state) {
      case RideState.enRoute:
        return Icons.location_on;
      case RideState.arrived:
        return Icons.play_arrow;
      case RideState.inRide:
        return Icons.flag;
      case RideState.completed:
        return Icons.check;
    }
  }

  Color get _actionColor {
    switch (_state) {
      case RideState.enRoute:
        return const Color(0xFFFFC107);
      case RideState.arrived:
        return const Color(0xFF43A047);
      case RideState.inRide:
        return const Color(0xFFD32F2F);
      case RideState.completed:
        return const Color(0xFF43A047);
    }
  }

  String get _statusLabel {
    switch (_state) {
      case RideState.enRoute:
        return 'En route vers le client';
      case RideState.arrived:
        return 'Arrivé au point de départ';
      case RideState.inRide:
        return 'Course en cours';
      case RideState.completed:
        return 'Course terminée';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      body: Stack(
        children: [
          // Simulated map background
          _buildMapPlaceholder(),

          // Top bar
          _buildTopBar(),

          // Bottom sheet
          _buildBottomSheet(),

          // Rating overlay
          if (_showRating) _buildRatingOverlay(),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    LatLng target;
    double zoom = 15.0;

    switch (_state) {
      case RideState.enRoute:
      case RideState.arrived:
        target = _pickupLocation;
        break;
      case RideState.inRide:
      case RideState.completed:
        target = _destinationLocation;
        break;
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: target,
        zoom: zoom,
      ),
      onMapCreated: (controller) {
        _mapController = controller;
      },
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,
      polylines: _buildPolylines(),
      markers: _buildMarkers(),
    );
  }

  Set<Polyline> _buildPolylines() {
    return {
      const Polyline(
        polylineId: PolylineId('trip_route'),
        points: [_pickupLocation, _destinationLocation],
        color: Color(0xFFFFC107),
        width: 5,
      ),
    };
  }

  Set<Marker> _buildMarkers() {
    return {
      Marker(
        markerId: const MarkerId('pickup'),
        position: _pickupLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Point de départ'),
      ),
      Marker(
        markerId: const MarkerId('destination'),
        position: _destinationLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Destination'),
      ),
      Marker(
        markerId: const MarkerId('driver'),
        position: _state == RideState.enRoute || _state == RideState.arrived
            ? _pickupLocation
            : _destinationLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        infoWindow: const InfoWindow(title: 'Vous'),
      ),
    };
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Status chips
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.circle,
                        size: 8,
                        color: _state == RideState.inRide
                            ? const Color(0xFF43A047)
                            : const Color(0xFFFFC107)),
                    const SizedBox(width: 8),
                    Text(
                      _formattedTime,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
              // Contact buttons
              Row(
                children: [
                  _CircleBtn(
                    icon: Icons.phone,
                    color: const Color(0xFF43A047),
                    onTap: () {},
                  ),
                  const SizedBox(width: 8),
                  _CircleBtn(
                    icon: Icons.chat,
                    color: const Color(0xFF336D91),
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedBuilder(
        animation: _sheetHeight,
        builder: (_, __) {
          return Container(
            padding: EdgeInsets.fromLTRB(
              24,
              16,
              24,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                GestureDetector(
                  onTap: _toggleSheet,
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDDDDD),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Client info
                _buildClientInfo(),

                // Expanded details
                if (_sheetExpanded) ...[
                  const SizedBox(height: 16),
                  _buildTripStats(),
                ],

                const SizedBox(height: 16),

                // Action button
                if (_state != RideState.completed)
                  GestureDetector(
                    onTap: _advanceState,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        color: _actionColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: _actionColor.withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_actionIcon,
                              color: _state == RideState.enRoute
                                  ? const Color(0xFF121212)
                                  : Colors.white,
                              size: 22),
                          const SizedBox(width: 10),
                          Text(
                            _actionLabel,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: _state == RideState.enRoute
                                  ? const Color(0xFF121212)
                                  : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildClientInfo() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFFC107), width: 2),
          ),
          child: const Icon(Icons.person, color: Color(0xFF757575), size: 26),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Amin Mohamed',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(
                _statusLabel,
                style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
              ),
            ],
          ),
        ),
        // Chevron toggle
        GestureDetector(
          onTap: _toggleSheet,
          child: AnimatedRotation(
            duration: const Duration(milliseconds: 300),
            turns: _sheetExpanded ? 0.5 : 0,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  const Icon(Icons.keyboard_arrow_up, color: Color(0xFF757575)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTripStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const _StatItem(
                icon: Icons.straighten,
                label: 'Distance',
                value: '3.5 km',
              ),
              const SizedBox(width: 12),
              _StatItem(
                icon: Icons.schedule,
                label: 'Temps',
                value: _formattedTime,
              ),
              const SizedBox(width: 12),
              const _StatItem(
                icon: Icons.payments,
                label: 'Prix',
                value: '250 FDJ',
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Route summary
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF43A047),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text('Gabode 5',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(width: 12),
              const Icon(Icons.arrow_forward,
                  size: 14, color: Color(0xFF757575)),
              const SizedBox(width: 12),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFD32F2F),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text('Palais du Peuple',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingOverlay() {
    return AnimatedOpacity(
      opacity: _showRating ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        color: Colors.black.withOpacity(0.6),
        child: Center(
          child: _ratingSubmitted ? _buildRatingSuccess() : _buildRatingCard(),
        ),
      ),
    );
  }

  Widget _buildRatingCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Client avatar in rating
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFC107), width: 3),
            ),
            child: const Icon(Icons.person, color: Color(0xFF757575), size: 36),
          ),
          const SizedBox(height: 16),
          const Text(
            'Comment était Amin ?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            'Évaluez votre passager',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          // Stars
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final starNum = i + 1;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedStars = starNum);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: AnimatedScale(
                    scale: _selectedStars >= starNum ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _selectedStars >= starNum
                          ? Icons.star
                          : Icons.star_border,
                      size: 40,
                      color: _selectedStars >= starNum
                          ? const Color(0xFFFFC107)
                          : const Color(0xFFCCCCCC),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          if (_selectedStars > 0)
            Text(
              _ratingLabel(_selectedStars),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFFFFC107),
              ),
            ),
          const SizedBox(height: 24),
          // Submit
          GestureDetector(
            onTap: _selectedStars > 0
                ? () {
                    HapticFeedback.heavyImpact();
                    setState(() => _ratingSubmitted = true);
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) {
                        Navigator.of(context).pushReplacementNamed('/login');
                      }
                    });
                  }
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: _selectedStars > 0
                    ? const Color(0xFFFFC107)
                    : const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(14),
                boxShadow: _selectedStars > 0
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFFC107).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  'Envoyer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: _selectedStars > 0
                        ? const Color(0xFF121212)
                        : const Color(0xFF999999),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: Text(
              'Passer',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSuccess() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (_, v, child) => Transform.scale(scale: v, child: child),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.check, size: 40, color: Color(0xFF43A047)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Merci !',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              'Note envoyée avec succès',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  String _ratingLabel(int stars) {
    switch (stars) {
      case 1:
        return 'Mauvais';
      case 2:
        return 'Médiocre';
      case 3:
        return 'Correct';
      case 4:
        return 'Bien';
      case 5:
        return 'Excellent !';
      default:
        return '';
    }
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CircleBtn(
      {required this.icon, required this.color, required this.onTap});

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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF757575)),
            const SizedBox(height: 4),
            Text(value,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 11, color: Color(0xFF757575))),
          ],
        ),
      ),
    );
  }
}

// --- Map Grid Painter (simulates a map background) ---

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD0D0D0)
      ..strokeWidth = 0.5;

    // Horizontal lines
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Vertical lines
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Thicker "roads"
    final roadPaint = Paint()
      ..color = const Color(0xFFBBBBBB)
      ..strokeWidth = 3;

    canvas.drawLine(
      Offset(0, size.height * 0.3),
      Offset(size.width, size.height * 0.3),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.4, 0),
      Offset(size.width * 0.4, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.7),
      Offset(size.width, size.height * 0.7),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.75, 0),
      Offset(size.width * 0.75, size.height),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
