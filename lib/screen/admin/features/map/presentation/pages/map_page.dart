import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../app/theme/admin_theme.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  StreamSubscription? _driversSubscription;
  StreamSubscription? _ridesSubscription;

  bool _isFullscreen = false;
  List<Map<String, dynamic>> _idleDrivers = [];
  List<Map<String, dynamic>> _activeRides = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _subscribeToUpdates();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final drivers =
          await _supabase.from('drivers').select().eq('status', 'active');

      final activeRides1 =
          await _supabase.from('rides').select().eq('status', 'accepted');

      final activeRides2 =
          await _supabase.from('rides').select().eq('status', 'in_progress');

      final allRides = [...activeRides1, ...activeRides2];

      setState(() {
        _idleDrivers = List<Map<String, dynamic>>.from(drivers);
        _activeRides = List<Map<String, dynamic>>.from(allRides);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _subscribeToUpdates() {
    _driversSubscription = _supabase
        .from('drivers')
        .stream(primaryKey: ['id'])
        .eq('status', 'active')
        .listen((data) {
          if (mounted) {
            setState(() {
              _idleDrivers = List<Map<String, dynamic>>.from(data);
            });
          }
        });

    _ridesSubscription = _supabase
        .from('rides')
        .stream(primaryKey: ['id'])
        .eq('status', 'accepted')
        .listen((data) {
          if (mounted) {
            setState(() {
              _activeRides = List<Map<String, dynamic>>.from(data);
            });
          }
        });
  }

  @override
  void dispose() {
    _driversSubscription?.cancel();
    _ridesSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AdminTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AdminTheme.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Supervision en Temps Réel',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    _legendItem(AdminTheme.primary, 'Chauffeur Libre'),
                    const SizedBox(width: 20),
                    _legendItem(AdminTheme.success, 'Chauffeur Occupé'),
                    const SizedBox(width: 20),
                    _legendItem(AdminTheme.info, 'Client en attente'),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadData,
                    ),
                    IconButton(
                      icon: Icon(_isFullscreen
                          ? Icons.fullscreen_exit
                          : Icons.fullscreen),
                      onPressed: () =>
                          setState(() => _isFullscreen = !_isFullscreen),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE5E3DF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AdminTheme.border),
              ),
              child: Stack(
                children: [
                  CustomPaint(
                    size: Size.infinite,
                    painter: _MapGridPainter(),
                  ),
                  if (_idleDrivers.isEmpty && _activeRides.isEmpty)
                    const Center(
                      child: Text(
                        'Aucune donnée en temps réel',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ..._idleDrivers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final driver = entry.value;
                    final x = 100.0 + (index * 80) % 400;
                    final y = 100.0 + (index * 60) % 200;
                    return _buildMarker(
                      x,
                      y,
                      driver['full_name'] ?? 'Chauffeur',
                      driver['phone'] ?? '',
                      driver['vehicle'] ?? '',
                      driver['license_plate'] ?? '',
                      driver['current_location'] ?? 'Position inconnue',
                      'idle',
                    );
                  }),
                  ..._activeRides.asMap().entries.map((entry) {
                    final index = entry.key;
                    final ride = entry.value;
                    final cx = 50.0 + (index * 100) % 350;
                    final cy = 50.0 + (index * 80) % 250;
                    final dx = cx + 30;
                    final dy = cy + 40;
                    return Stack(
                      children: [
                        CustomPaint(
                          size: Size.infinite,
                          painter: _ConnectionLinePainter(cx, cy, dx, dy),
                        ),
                        _buildMarker(
                          cx,
                          cy,
                          ride['user_id']?.toString().substring(0, 8) ??
                              'Client',
                          '',
                          '',
                          '',
                          ride['pickup_address'] ?? '',
                          'client',
                        ),
                        _buildMarker(
                          dx,
                          dy,
                          ride['driver_id']?.toString().substring(0, 8) ??
                              'Chauffeur',
                          '',
                          '',
                          '',
                          ride['dropoff_address'] ?? '',
                          'busy',
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildMarker(double x, double y, String name, String phone,
      String moto, String plate, String location, String type) {
    Color color;
    IconData icon;
    if (type == 'client') {
      color = AdminTheme.info;
      icon = Icons.person;
    } else if (type == 'busy') {
      color = AdminTheme.success;
      icon = Icons.two_wheeler;
    } else {
      color = AdminTheme.primary;
      icon = Icons.two_wheeler;
    }

    return Positioned(
      left: x - 20,
      top: y - 20,
      child: GestureDetector(
        onTap: () => _showDriverInfo(name, phone, moto, plate, location),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  void _showDriverInfo(
      String name, String phone, String moto, String plate, String location) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name\n$phone\n$location'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..strokeWidth = 1;

    for (double i = 0; i < size.width; i += 50) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 50) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ConnectionLinePainter extends CustomPainter {
  final double x1, y1, x2, y2;
  _ConnectionLinePainter(this.x1, this.y1, this.x2, this.y2);

  @override
  void paint(Canvas canvas, Size size) {
    final dashPaint = Paint()
      ..color = AdminTheme.secondary.withValues(alpha: 0.4)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(x1, y1);
    path.lineTo(x2, y2);

    canvas.drawPath(
      Path.combine(PathOperation.difference, path, Path()),
      dashPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
