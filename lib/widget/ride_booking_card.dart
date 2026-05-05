import 'package:flutter/material.dart';

class RideBookingCard extends StatelessWidget {
  final TextEditingController startController;
  final TextEditingController destinationController;
  final VoidCallback onMapSelectStart;
  final VoidCallback onMapSelectDestination;
  final VoidCallback onUseCurrentLocation;
  final VoidCallback onSwapLocations;
  final VoidCallback onNext;

  const RideBookingCard({
    super.key,
    required this.startController,
    required this.destinationController,
    required this.onMapSelectStart,
    required this.onMapSelectDestination,
    required this.onUseCurrentLocation,
    required this.onSwapLocations,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final padding = MediaQuery.of(context).padding;

    final horizontalPadding = width * 0.05;
    final verticalPadding = size.height * 0.022;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, -6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        verticalPadding,
        horizontalPadding,
        padding.bottom + verticalPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: width * 0.10,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8E8E8),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Text(
            'Where to go ?',
            style: TextStyle(
              fontSize: width * 0.068,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          SizedBox(height: size.height * 0.022),

          // Bloc inputs départ/destination
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.045,
              vertical: size.height * 0.02,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(16),
              border: const Border.all(                color: Color(0xFFE8E8E8),
                width: 1.5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Colonne icônes + ligne pointillée
                Column(
                  children: [
                    const SizedBox(height: 8),
                    Transform.rotate(
                      angle: 0.785398,
                      child: Icon(
                        Icons.navigation,
                        color: const Color(0xFFFFC700),
                        size: width * 0.055,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 60,
                      child: CustomPaint(
                        painter: DashedLinePainter(),
                        size: const Size(3, 60),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(
                      Icons.location_pin,
                      color: const Color(0xFF1A1A1A),
                      size: width * 0.055,
                    ),
                  ],
                ),
                SizedBox(width: width * 0.038),

                // Inputs
                Expanded(
                  child: Column(
                    children: [
                      _LocationInputRow(
                        label: 'PICK UP',
                        controller: startController,
                        hintText: 'Enter Pickup Location',
                        screenWidth: width,
                        onMapSelect: onMapSelectStart,
                        onUseLocation: onUseCurrentLocation,
                        showLocationButton: true,
                      ),

                      // Divider
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: size.height * 0.012,
                          horizontal: width * 0.02,
                        ),
                        child: Container(
                          height: 1,
                          color: const Color(0xFFE8E8E8),
                        ),
                      ),

                      _LocationInputRow(
                        label: 'Dropoff',
                        controller: destinationController,
                        hintText: 'Enter Drop off Location',
                        screenWidth: width,
                        onMapSelect: onMapSelectDestination,
                        showLocationButton: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: size.height * 0.024),

          // Bouton NEXT
          Container(
            width: double.infinity,
            height: size.height * 0.068,
            decoration: BoxDecoration(
              color: const Color(0xFFFFC700),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFC700).withValues(alpha: 0.30),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (startController.text.isEmpty ||
                      destinationController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Please select both locations',
                                style: TextStyle(
                                  fontSize: width * 0.036,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: const Color(0xFF1A1A1A),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        margin: EdgeInsets.only(
                          bottom: size.height * 0.02,
                          left: 40,
                          right: 40,
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    return;
                  }
                  debugPrint(
                      'Next: ${startController.text} -> ${destinationController.text}');
                  onNext();
                },
                borderRadius: BorderRadius.circular(14),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Next',
                        style: TextStyle(
                          color: const Color(0xFF1A1A1A),
                          fontSize: width * 0.042,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: const Color(0xFF1A1A1A),
                        size: width * 0.05,
                      ),
                    ],
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

// ─────────────────────────────────────────
//  Location Input Row
// ─────────────────────────────────────────

class _LocationInputRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final double screenWidth;
  final VoidCallback onMapSelect;
  final VoidCallback? onUseLocation;
  final bool showLocationButton;

  const _LocationInputRow({
    required this.label,
    required this.controller,
    required this.hintText,
    required this.screenWidth,
    required this.onMapSelect,
    this.onUseLocation,
    this.showLocationButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: screenWidth * 0.03,
                  color: const Color(0xFF999999),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: controller,
                style: TextStyle(
                  fontSize: screenWidth * 0.039,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                  height: 1.3,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                    fontSize: screenWidth * 0.039,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF999999),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            ],
          ),
        ),

        // Boutons action
        Row(
          children: [
            _ActionButton(
              icon: Icons.map_outlined,
              onTap: onMapSelect,
              screenWidth: screenWidth,
            ),
            if (showLocationButton) ...[
              SizedBox(width: screenWidth * 0.022),
              _ActionButton(
                icon: Icons.my_location_rounded,
                onTap: onUseLocation ?? () {},
                screenWidth: screenWidth,
                isAccent: true,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
//  Action Button
// ─────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double screenWidth;
  final bool isAccent;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    required this.screenWidth,
    this.isAccent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: screenWidth * 0.1,
          height: screenWidth * 0.1,
          decoration: BoxDecoration(
            color: isAccent ? const Color(0xFFFFF8E1) : const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color:
                  isAccent ? const Color(0xFFFFE070) : const Color(0xFFE8E8E8),
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            color: isAccent ? const Color(0xFFB38A00) : const Color(0xFF555555),
            size: screenWidth * 0.048,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  Dashed Line Painter
// ─────────────────────────────────────────

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashHeight = 4.0;
    const dashSpace = 8.0;
    double startY = 0;

    final paint = Paint()
      ..color = const Color(0xFFD0D0D0)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
