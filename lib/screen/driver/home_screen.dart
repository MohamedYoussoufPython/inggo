import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../theme/inggo_theme.dart';
import '../../provider/driver_provider.dart';
import '../../provider/driver_earnings_provider.dart';
import '../../provider/driver_rides_provider.dart';

class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {
  static const LatLng _djiboutiCenter = LatLng(11.5985, 43.1510);
  GoogleMapController? _mapController;



  Set<Marker> _buildMarkers() {
    return {
      Marker(
        markerId: const MarkerId('driver_location'),
        position: _djiboutiCenter,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        infoWindow: const InfoWindow(title: 'Vous'),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: _djiboutiCenter,
            zoom: 14.5,
          ),
          onMapCreated: (controller) {
            _mapController = controller;
          },
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
          markers: _buildMarkers(),
        ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: InggoColors.primary.withValues(alpha: 0.2),
                  ),
                  child: Center(
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFFFC107),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x40FFC107),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: const Border.all(color: InggoColors.border1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Consumer(
                            builder: (context, ref, child) {
                              final earnings = ref.watch(todayEarningsProvider);
                              return Text(
                                earnings.toString(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'FDJ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF757575),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'BÉNÉFICE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF757575),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: InggoColors.border1,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Consumer(
                        builder: (context, ref, child) {
                          final ridesAsync = ref.watch(driverRidesProvider);
                          int todayClients = 0;
                          if (ridesAsync.value != null) {
                            final today = DateTime.now();
                            todayClients = ridesAsync.value!.where((r) {
                              final date = DateTime.fromMillisecondsSinceEpoch(r.timestamp);
                              return date.year == today.year && date.month == today.month && date.day == today.day;
                            }).length;
                          }
                          return Text(
                            todayClients.toString(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'CLIENTS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF757575),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: InggoColors.border1,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Consumer(
                            builder: (context, ref, child) {
                              final driver = ref.watch(driverProvider).value;
                              return Text(
                                (driver?.rating ?? 5.0).toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.star,
                            size: 18,
                            color: Color(0xFFFFC107),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'NOTE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF757575),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
