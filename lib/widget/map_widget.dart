import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../core/constants/constants.dart';

class MapWidget extends StatefulWidget {
  final double initialLat;
  final double initialLng;
  final double? pickupLat;
  final double? pickupLng;
  final double? dropoffLat;
  final double? dropoffLng;
  final double? driverLat;
  final double? driverLng;
  final bool enableTap;
  final ValueChanged<LatLng>? onTapPosition;
  final double zoom;

  const MapWidget({
    super.key,
    this.initialLat = AppConstants.defaultLat,
    this.initialLng = AppConstants.defaultLng,
    this.pickupLat,
    this.pickupLng,
    this.dropoffLat,
    this.dropoffLng,
    this.driverLat,
    this.driverLng,
    this.enableTap = false,
    this.onTapPosition,
    this.zoom = 14.0,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _updateMarkers();
  }

  @override
  void didUpdateWidget(covariant MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Rebuild markers and polyline if location data changed
    if (oldWidget.pickupLat != widget.pickupLat ||
        oldWidget.pickupLng != widget.pickupLng ||
        oldWidget.dropoffLat != widget.dropoffLat ||
        oldWidget.dropoffLng != widget.dropoffLng ||
        oldWidget.driverLat != widget.driverLat ||
        oldWidget.driverLng != widget.driverLng) {
      _updateMarkers();
    }

    // Animate camera to follow driver when their position updates
    if (widget.driverLat != null &&
        widget.driverLng != null &&
        (oldWidget.driverLat != widget.driverLat ||
            oldWidget.driverLng != widget.driverLng)) {
      _animateToDriver();
    }
  }

  void _updateMarkers() {
    final markers = <Marker>{};

    if (widget.pickupLat != null && widget.pickupLng != null) {
      markers.add(Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(widget.pickupLat!, widget.pickupLng!),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        infoWindow: const InfoWindow(title: 'Départ'),
      ));
    }
    if (widget.dropoffLat != null && widget.dropoffLng != null) {
      markers.add(Marker(
        markerId: const MarkerId('dropoff'),
        position: LatLng(widget.dropoffLat!, widget.dropoffLng!),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Destination'),
      ));
    }
    // Driver live marker — green to distinguish from pickup/dropoff
    if (widget.driverLat != null && widget.driverLng != null) {
      markers.add(Marker(
        markerId: const MarkerId('driver'),
        position: LatLng(widget.driverLat!, widget.driverLng!),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Votre chauffeur'),
      ));
    }

    // Draw polyline between pickup and dropoff if both are available
    final polylines = <Polyline>{};
    if (widget.pickupLat != null &&
        widget.pickupLng != null &&
        widget.dropoffLat != null &&
        widget.dropoffLng != null) {
      polylines.add(Polyline(
        polylineId: const PolylineId('route'),
        points: [
          LatLng(widget.pickupLat!, widget.pickupLng!),
          LatLng(widget.dropoffLat!, widget.dropoffLng!),
        ],
        color: AppColors.primary,
        width: 4,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ));
    }

    setState(() {
      _markers = markers;
      _polylines = polylines;
    });
  }

  /// Animate the camera to follow the driver marker
  void _animateToDriver() {
    if (_mapController == null || widget.driverLat == null || widget.driverLng == null) {
      return;
    }
    _mapController!.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(widget.driverLat!, widget.driverLng!),
      ),
    );
  }

  /// Fit all markers in view with padding
  void _fitAllMarkers() {
    if (_mapController == null) return;

    final points = <LatLng>[];
    if (widget.pickupLat != null && widget.pickupLng != null) {
      points.add(LatLng(widget.pickupLat!, widget.pickupLng!));
    }
    if (widget.dropoffLat != null && widget.dropoffLng != null) {
      points.add(LatLng(widget.dropoffLat!, widget.dropoffLng!));
    }
    if (widget.driverLat != null && widget.driverLng != null) {
      points.add(LatLng(widget.driverLat!, widget.driverLng!));
    }

    if (points.length >= 2) {
      final bounds = LatLngBounds(
        southwest: LatLng(
          points.map((p) => p.latitude).reduce((a, b) => a < b ? a : b),
          points.map((p) => p.longitude).reduce((a, b) => a < b ? a : b),
        ),
        northeast: LatLng(
          points.map((p) => p.latitude).reduce((a, b) => a > b ? a : b),
          points.map((p) => p.longitude).reduce((a, b) => a > b ? a : b),
        ),
      );
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 80),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.initialLat, widget.initialLng),
          zoom: widget.zoom,
        ),
        markers: _markers,
        polylines: _polylines,
        onMapCreated: (controller) {
          _mapController = controller;
          // Fit all markers once the map is ready
          if (_markers.length >= 2) {
            Future.delayed(const Duration(milliseconds: 300), _fitAllMarkers);
          }
        },
        onTap: widget.enableTap
            ? (latLng) {
                widget.onTapPosition?.call(latLng);
                setState(() {
                  _markers.add(Marker(
                    markerId: const MarkerId('selected'),
                    position: latLng,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueYellow),
                  ));
                });
              }
            : null,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        compassEnabled: true,
      ),
    );
  }
}
