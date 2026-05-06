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

  @override
  void initState() {
    super.initState();
    _updateMarkers();
  }

  @override
  void didUpdateWidget(covariant MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only rebuild markers if location data actually changed
    if (oldWidget.pickupLat != widget.pickupLat ||
        oldWidget.pickupLng != widget.pickupLng ||
        oldWidget.dropoffLat != widget.dropoffLat ||
        oldWidget.dropoffLng != widget.dropoffLng ||
        oldWidget.driverLat != widget.driverLat ||
        oldWidget.driverLng != widget.driverLng) {
      _updateMarkers();
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
    setState(() => _markers = markers);
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
        onMapCreated: (controller) => _mapController = controller,
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
