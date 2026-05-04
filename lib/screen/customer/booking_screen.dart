import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../widget/ride_booking_card.dart';
import '../../widget/payment_method_card.dart';
import 'package:go_router/go_router.dart';
import '../../widget/profil_icon.dart';
import '../../widget/pulsating_location_pin.dart';
import '../../widget/selection_pin.dart';
import '../../widget/notification_icon.dart';
import '../../provider/notifications_provider.dart';
import '../../provider/ride_provider.dart';

class RideBookingScreen extends ConsumerStatefulWidget {
  const RideBookingScreen({super.key});

  @override
  ConsumerState<RideBookingScreen> createState() => _RideBookingScreenState();
}

class _RideBookingScreenState extends ConsumerState<RideBookingScreen> {
  static const LatLng _defaultDjibouti = LatLng(11.5950, 43.1480);

  GoogleMapController? _mapController;
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  final LatLng _userPosition = _defaultDjibouti;
  Offset? _pinScreenPosition;
  String? _selectionMode;
  LatLng _currentMapCenter = _defaultDjibouti;
  String _centerAddress = "Déplacez la carte...";
  bool _showPaymentCard = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _updatePinScreenPosition() async {
    if (_mapController == null) return;
    try {
      final ScreenCoordinate screenCoord =
          await _mapController!.getScreenCoordinate(_userPosition);
      setState(() {
        _pinScreenPosition =
            Offset(screenCoord.x.toDouble(), screenCoord.y.toDouble());
      });
    } catch (e) {
      debugPrint('Erreur calcul position pin: $e');
    }
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _onMapSelectStart() {
    debugPrint("Mode Sélection : Départ");
    setState(() => _selectionMode = "depart");
  }

  void _onMapSelectDestination() {
    debugPrint("Mode Sélection : Destination");
    setState(() => _selectionMode = "destination");
  }

  void _onUseCurrentLocation() {
    debugPrint("Utilisation position actuelle");
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_defaultDjibouti, 15),
    );
    _pickupController.text = "Ma position actuelle";
  }

  void _onSwapLocations() {
    debugPrint("Échange départ/destination");
    setState(() {
      final tempText = _pickupController.text;
      _pickupController.text = _destinationController.text;
      _destinationController.text = tempText;
    });
  }

  // ── Bouton de contrôle carte — style Inggo ─────────────────
  Widget _buildMapControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(22),
          child: Center(
            child: Icon(icon, size: 20, color: const Color(0xFF1A1A1A)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. LA CARTE GOOGLE MAPS
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: _defaultDjibouti,
                zoom: 14.0,
              ),
              markers: const {},
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                Future.delayed(const Duration(milliseconds: 300), () {
                  _updatePinScreenPosition();
                });
              },
              onCameraMove: (CameraPosition position) {
                _currentMapCenter = position.target;
                _updatePinScreenPosition();
              },
              onCameraIdle: () {
                _updatePinScreenPosition();
                setState(() {
                  _centerAddress =
                      "Lat: ${_currentMapCenter.latitude.toStringAsFixed(3)}, Lng: ${_currentMapCenter.longitude.toStringAsFixed(3)}";
                });
              },
            ),
          ),

          // 1b. MARQUEUR PULSANT ANIMÉ
          if (_pinScreenPosition != null)
            Positioned(
              left: _pinScreenPosition!.dx - 40,
              top: _pinScreenPosition!.dy - 40,
              child: const IgnorePointer(child: PulsatingLocationPin()),
            ),

          // 2. LE BOUTON PROFIL
          Positioned(
            top: 18,
            left: 8,
            child: ProfilIcon(onTap: () => context.push('/profile')),
          ),

          NotificationIcon(
            notificationCount: ref.watch(unreadCountProvider),
            onTap: () => context.push('/notifications'),
          ),

          // 3. LE WIDGET LOCATIONCARD
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (Widget child, Animation<double> animation) {
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation);
                return SlideTransition(position: offsetAnimation, child: child);
              },
              child: _showPaymentCard
                  ? PaymentMethodCard(
                      key: const ValueKey('PaymentCard'),
                      onBack: () => setState(() => _showPaymentCard = false),
                      onConfirm: () async {
                        final rideId = await ref.read(rideProvider.notifier).createRide(
                          pickupAddress: _pickupController.text,
                          dropoffAddress: _destinationController.text,
                          pickupLat: _currentMapCenter.latitude,
                          pickupLng: _currentMapCenter.longitude,
                        );
                        if (mounted && rideId != null) {
                          context.go('/searching', extra: {'rideId': rideId});
                        }
                      },
                    )
                  : RideBookingCard(
                      key: const ValueKey('BookingCard'),
                      startController: _pickupController,
                      destinationController: _destinationController,
                      onMapSelectStart: _onMapSelectStart,
                      onMapSelectDestination: _onMapSelectDestination,
                      onUseCurrentLocation: _onUseCurrentLocation,
                      onSwapLocations: _onSwapLocations,
                      onNext: () => setState(() => _showPaymentCard = true),
                    ),
            ),
          ),

          // 4. CONTRÔLES CARTE
          Positioned(
            bottom: 360,
            right: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildMapControlButton(
                  icon: Icons.my_location_rounded,
                  onPressed: () {
                    _mapController?.animateCamera(
                      CameraUpdate.newLatLngZoom(_defaultDjibouti, 15),
                    );
                  },
                ),
              ],
            ),
          ),

          // 5. MODE SÉLECTION SUR LA CARTE
          if (_selectionMode != null)
            Positioned.fill(
              child: Stack(
                children: [
                  // Fond semi-transparent
                  Container(color: Colors.black.withOpacity(0.1)),

                  // Épingle centrale
                  Align(
                    alignment: const Alignment(0, -0.05),
                    child: SelectionPin(
                      isDestination: _selectionMode == "destination",
                    ),
                  ),

                  // Bouton retour
                  Positioned(
                    bottom: 110,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          debugPrint("Annuler la sélection");
                          setState(() => _selectionMode = null);
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFE8E8E8),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.10),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Color(0xFF1A1A1A),
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Capsule d'adresse
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.5 + 50,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 300),
                        padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: const Color(0xFFE8E8E8),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                _centerAddress,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1A1A1A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Bouton valider — jaune Inggo
                            GestureDetector(
                              onTap: () {
                                debugPrint("Valider la sélection !");
                                if (_selectionMode == "destination") {
                                  _destinationController.text = _centerAddress;
                                } else if (_selectionMode == "depart") {
                                  _pickupController.text = _centerAddress;
                                }
                                setState(() => _selectionMode = null);
                              },
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFC700),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFFC700)
                                          .withOpacity(0.30),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Color(0xFF1A1A1A),
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
