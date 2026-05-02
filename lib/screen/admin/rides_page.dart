import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../app/theme/admin_theme.dart';

class RidesPage extends ConsumerStatefulWidget {
  const RidesPage({super.key});

  @override
  ConsumerState<RidesPage> createState() => _RidesPageState();
}

class _RidesPageState extends ConsumerState<RidesPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _rides = [];
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadRides();
  }

  Future<void> _loadRides() async {
    setState(() => _isLoading = true);
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final monthStart = DateTime(now.year, now.month, 1);

      final todayRides = await _supabase
          .from('rides')
          .select('id')
          .gte('created_at', today.toIso8601String())
          .neq('status', 'cancelled');

      final monthRides = await _supabase
          .from('rides')
          .select('id')
          .gte('created_at', monthStart.toIso8601String())
          .neq('status', 'cancelled');

      final yearRides =
          await _supabase.from('rides').select('id').neq('status', 'cancelled');

      final cancelledRides =
          await _supabase.from('rides').select('id').eq('status', 'cancelled');

      _stats = {
        'todayCount': todayRides.length,
        'monthCount': monthRides.length,
        'yearCount': yearRides.length,
        'cancelRate': yearRides.isNotEmpty
            ? (cancelledRides.length / yearRides.length * 100)
                .toStringAsFixed(1)
            : '0',
      };

      final response = await _supabase
          .from('rides')
          .select()
          .order('created_at', ascending: false)
          .limit(50);

      setState(() {
        _rides = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
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
          Row(
            children: [
              _StatCard(
                title: "Courses Aujourd'hui",
                value: '${_stats['todayCount'] ?? 0}',
                subtitle: '+12% vs hier',
                icon: Icons.today,
                color: AdminTheme.info,
              ),
              const SizedBox(width: 20),
              _StatCard(
                title: 'Courses Ce Mois',
                value: '${_stats['monthCount'] ?? 0}',
                subtitle: 'Février 2026',
                icon: Icons.calendar_month,
                color: AdminTheme.primary,
              ),
              const SizedBox(width: 20),
              _StatCard(
                title: 'Cette Année',
                value: '${_stats['yearCount'] ?? 0}',
                subtitle: 'Année 2026',
                icon: Icons.event,
                color: AdminTheme.success,
              ),
              const SizedBox(width: 20),
              _StatCard(
                title: 'Taux Annulation',
                value: '${_stats['cancelRate'] ?? 0}%',
                subtitle: 'En baisse',
                icon: Icons.block,
                color: AdminTheme.danger,
              ),
            ],
          ),
          const SizedBox(height: 30),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AdminTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AdminTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Historique des Courses',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _loadRides,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(1),
                          1: FlexColumnWidth(2),
                          2: FlexColumnWidth(2),
                          3: FlexColumnWidth(2),
                          4: FlexColumnWidth(1),
                          5: FlexColumnWidth(1),
                        },
                        children: [
                          TableRow(
                            decoration: const BoxDecoration(
                              color: Color(0xFFFAFAFA),
                            ),
                            children: [
                              _header('ID Course'),
                              _header('Client'),
                              _header('Conducteur'),
                              _header('Départ -> Arrivée'),
                              _header('Prix'),
                              _header('Statut'),
                            ],
                          ),
                          ..._rides.map((ride) => TableRow(
                                children: [
                                  _cell('R-${ride['id']}'),
                                  _cell(ride['user_id']
                                          ?.toString()
                                          .substring(0, 8) ??
                                      'N/A'),
                                  _cell(ride['driver_id']
                                          ?.toString()
                                          .substring(0, 8) ??
                                      '--'),
                                  _cell(
                                      '${ride['pickup_address'] ?? ''} -> ${ride['dropoff_address'] ?? ''}'),
                                  _cell(ride['price'] != null
                                      ? '${ride['price']} FDJ'
                                      : '--'),
                                  _cell(_buildStatusBadge(
                                      ride['status'] ?? 'unknown')),
                                ],
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(String text) => Padding(
        padding: const EdgeInsets.all(15),
        child: Text(text,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
      );

  Widget _cell(dynamic content) {
    if (content is Widget) {
      return Padding(
        padding: const EdgeInsets.all(15),
        child: content,
      );
    }
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Text(content.toString()),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;
    switch (status) {
      case 'completed':
        bgColor = AdminTheme.success.withValues(alpha: 0.15);
        textColor = AdminTheme.success;
        label = 'Terminée';
        break;
      case 'cancelled':
        bgColor = AdminTheme.danger.withValues(alpha: 0.15);
        textColor = AdminTheme.danger;
        label = 'Annulée';
        break;
      case 'searching':
        bgColor = AdminTheme.info.withValues(alpha: 0.15);
        textColor = AdminTheme.info;
        label = 'En recherche';
        break;
      case 'accepted':
      case 'in_progress':
        bgColor = AdminTheme.primary.withValues(alpha: 0.15);
        textColor = AdminTheme.primary;
        label = 'En cours';
        break;
      default:
        bgColor = Colors.grey.withValues(alpha: 0.15);
        textColor = Colors.grey;
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.bold, color: textColor)),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AdminTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AdminTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(value,
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
