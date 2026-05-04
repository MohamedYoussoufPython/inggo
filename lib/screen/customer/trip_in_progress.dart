import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:inggo/theme/inggo_theme.dart';

enum TripPhase {
  driverOnTheWay,
  driverArrived,
  inProgress,
  completed,
}

class TripInProgressScreen extends StatefulWidget {
  final String? rideId;
  final String? driverId;
  final String? driverName;
  final String? driverVehicle;
  final double? driverRating;
  final String? driverPhone;
  final String? driverPhoto;
  final LatLng? pickupLocation;
  final LatLng? destinationLocation;
  final String? pickupAddress;
  final String? destinationAddress;

  const TripInProgressScreen({
    super.key,
    this.rideId,
    this.driverId,
    this.driverName,
    this.driverVehicle,
    this.driverRating,
    this.driverPhone,
    this.driverPhoto,
    this.pickupLocation,
    this.destinationLocation,
    this.pickupAddress,
    this.destinationAddress,
  });

  @override
  State<TripInProgressScreen> createState() => _TripInProgressScreenState();
}

class _TripInProgressScreenState extends State<TripInProgressScreen> {
  TripPhase _phase = TripPhase.driverOnTheWay;
  int _remainingSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _simulateTripFlow();
  }

  void _simulateTripFlow() {
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() => _phase = TripPhase.driverArrived);
        _startBoardingCountdown();
      }
    });
  }

  void _startBoardingCountdown() {
    _remainingSeconds = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _remainingSeconds--;
      });
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _startActualTrip();
      }
    });
  }

  void _startActualTrip() {
    setState(() => _phase = TripPhase.inProgress);

    Future.delayed(const Duration(seconds: 15), () {
      if (mounted) {
        setState(() => _phase = TripPhase.completed);
      }
    });
  }

  void _onBoard() {
    _timer?.cancel();
    _startActualTrip();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final driverName = widget.driverName ?? 'Khaireh Abdo Sikieh';
    final driverVehicle = widget.driverVehicle ?? 'Toyota Vitz';
    final driverRating = widget.driverRating ?? 4.8;

    return Scaffold(
      body: Stack(
        children: [
          _buildMap(),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: _buildStatusBanner(),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: _buildBottomPanel(
                driverName,
                driverVehicle,
                driverRating,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    LatLng target;
    double zoom = 14.5;

    switch (_phase) {
      case TripPhase.driverOnTheWay:
      case TripPhase.driverArrived:
        target = widget.pickupLocation ?? const LatLng(11.5985, 43.1510);
        break;
      case TripPhase.inProgress:
      case TripPhase.completed:
        target = widget.destinationLocation ?? const LatLng(11.5985, 43.1510);
        break;
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: target,
        zoom: zoom,
      ),
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,
      polylines: _buildPolylines(),
    );
  }

  Set<Polyline> _buildPolylines() {
    if (widget.pickupLocation == null || widget.destinationLocation == null) {
      return {};
    }

    return {
      Polyline(
        polylineId: const PolylineId('trip_route'),
        points: [
          widget.pickupLocation!,
          widget.destinationLocation!,
        ],
        color: InggoColors.primary,
        width: 5,
      ),
    };
  }

  Widget _buildStatusBanner() {
    String statusText;
    Color bgColor;
    IconData icon;

    switch (_phase) {
      case TripPhase.driverOnTheWay:
        statusText = 'Chauffeur en route...';
        bgColor = InggoColors.primaryLight;
        icon = Icons.directions_car_rounded;
        break;
      case TripPhase.driverArrived:
        statusText = 'Chauffeur arrivé !';
        bgColor = InggoColors.success;
        icon = Icons.place_rounded;
        break;
      case TripPhase.inProgress:
        statusText = 'En route vers la destination';
        bgColor = const Color(0xFF2196F3);
        icon = Icons.navigation_rounded;
        break;
      case TripPhase.completed:
        statusText = 'Vous êtes arrivé !';
        bgColor = InggoColors.success;
        icon = Icons.check_circle_rounded;
        break;
    }

    return Container(
      margin: const EdgeInsets.all(InggoSpacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: InggoSpacing.md,
        vertical: InggoSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(InggoSpacing.sm),
        boxShadow: InggoShadows.level2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: _phase == TripPhase.driverOnTheWay
                  ? InggoColors.text1
                  : Colors.white,
              size: 20),
          const SizedBox(width: InggoSpacing.sm),
          Text(
            statusText,
            style: InggoTextStyles.buttonSmall.copyWith(
              color: _phase == TripPhase.driverOnTheWay
                  ? InggoColors.text1
                  : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(
      String driverName, String driverVehicle, double driverRating) {
    if (_phase == TripPhase.completed) {
      return Container(
        padding: const EdgeInsets.all(InggoSpacing.xl),
        decoration: BoxDecoration(
          color: InggoColors.surface,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(InggoSpacing.lg)),
          boxShadow: InggoShadows.level3,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: InggoColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 32,
                color: InggoColors.text1,
              ),
            ),
            const SizedBox(height: InggoSpacing.lg),
            Text(
              'Vous êtes arrivé',
              style: InggoTextStyles.h2,
            ),
            const SizedBox(height: InggoSpacing.xxl),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => context.go('/end-of-trip'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: InggoColors.primary,
                  foregroundColor: InggoColors.text1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(InggoSpacing.sm),
                  ),
                ),
                child: Text(
                  'Terminer',
                  style: InggoTextStyles.button,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(InggoSpacing.xl),
      decoration: BoxDecoration(
        color: InggoColors.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(InggoSpacing.lg)),
        boxShadow: InggoShadows.level3,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDriverInfo(driverName, driverVehicle, driverRating),
          const SizedBox(height: InggoSpacing.lg),
          _buildActionButtons(),
          if (_phase == TripPhase.driverArrived) ...[
            const SizedBox(height: InggoSpacing.md),
            Text(
              'Temps pour embarquer: $_remainingSeconds s',
              style: InggoTextStyles.caption,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDriverInfo(String name, String vehicle, double rating) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: InggoColors.primary, width: 2.5),
          ),
          child: CircleAvatar(
            radius: 28,
            backgroundColor: InggoColors.background,
            backgroundImage: widget.driverPhoto != null
                ? NetworkImage(widget.driverPhoto!)
                : null,
            child: widget.driverPhoto == null
                ? const Icon(Icons.person_rounded,
                    size: 28, color: InggoColors.text2)
                : null,
          ),
        ),
        const SizedBox(width: InggoSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: InggoTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: InggoSpacing.xs),
              Row(
                children: [
                  _buildRatingBadge(rating),
                  const SizedBox(width: InggoSpacing.sm),
                  Expanded(
                    child: Text(
                      '· $vehicle',
                      style: InggoTextStyles.caption,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingBadge(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: InggoSpacing.sm,
        vertical: InggoSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: InggoColors.primaryLight,
        borderRadius: BorderRadius.circular(InggoSpacing.xs),
        border: Border.all(color: InggoColors.primaryBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 14, color: InggoColors.primary),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: InggoTextStyles.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: InggoColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_phase == TripPhase.inProgress || _phase == TripPhase.completed) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Message',
            color: InggoColors.background,
            borderColor: InggoColors.border2,
            onTap: () {},
          ),
        ),
        const SizedBox(width: InggoSpacing.sm),
        Expanded(
          child: _ActionButton(
            icon: Icons.phone_rounded,
            label: 'Appeler',
            color: InggoColors.primaryLight,
            borderColor: InggoColors.primaryBorder,
            onTap: () {},
          ),
        ),
        if (_phase == TripPhase.driverArrived) ...[
          const SizedBox(width: InggoSpacing.sm),
          Expanded(
            child: _ActionButton(
              icon: Icons.check_circle_outline_rounded,
              label: 'À bord',
              color: InggoColors.success,
              borderColor: InggoColors.success,
              textColor: Colors.white,
              onTap: _onBoard,
            ),
          ),
        ],
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color borderColor;
  final Color textColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.borderColor,
    this.textColor = InggoColors.text1,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(InggoSpacing.sm),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: textColor),
            const SizedBox(width: InggoSpacing.sm),
            Text(
              label,
              style: InggoTextStyles.buttonSmall.copyWith(
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
