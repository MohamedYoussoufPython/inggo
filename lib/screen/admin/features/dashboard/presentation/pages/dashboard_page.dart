import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/admin_theme.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/admin_stats_service.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>>? _recentRides;
  List<Map<String, dynamic>>? _pendingDrivers;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final stats = await AdminStatsService.getDashboardStats();
    final rides = await AdminStatsService.getRecentRides(limit: 5);
    final drivers = await AdminStatsService.getPendingDrivers(limit: 5);
    if (mounted) {
      setState(() {
        _stats = stats;
        _recentRides = rides;
        _pendingDrivers = drivers;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final stats = [
      {
        'title': 'Chiffre d\'Affaires',
        'value': '${_stats?['revenue'] ?? 0} FDJ',
        'trend': 'Ce mois',
        'isUp': true,
        'icon': Icons.attach_money,
        'color': AdminTheme.success
      },
      {
        'title': 'Conducteurs Actifs',
        'value': '${_stats?['activeDrivers'] ?? 0}',
        'trend': 'En ligne',
        'isUp': true,
        'icon': Icons.sports_motorsports,
        'color': AdminTheme.primary
      },
      {
        'title': 'Conducteurs Inactifs',
        'value': '${_stats?['pendingDrivers'] ?? 0}',
        'trend': 'En attente',
        'isUp': null,
        'icon': Icons.portable_wifi_off,
        'color': Colors.grey
      },
      {
        'title': 'Courses Totales',
        'value': '${_stats?['totalRides'] ?? 0}',
        'trend': '+${_stats?['weeklyRides'] ?? 0} cette semaine',
        'isUp': true,
        'icon': Icons.route,
        'color': AdminTheme.info
      },
      {
        'title': 'Utilisateurs',
        'value': '${_stats?['totalUsers'] ?? 0}',
        'trend': 'Clients',
        'isUp': true,
        'icon': Icons.people,
        'color': Colors.purple
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 2.5,
            ),
            itemCount: stats.length,
            itemBuilder: (context, index) {
              final stat = stats[index];
              return _StatCard(
                title: stat['title'] as String,
                value: stat['value'] as String,
                trend: stat['trend'] as String,
                isUp: stat['isUp'] as bool?,
                icon: stat['icon'] as IconData,
                color: stat['color'] as Color,
              );
            },
          ),
          const SizedBox(height: 30),
          // Chart placeholder
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AdminTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AdminTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Activité des Courses (7 derniers jours)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.show_chart,
                            size: 60,
                            color: AdminTheme.primary.withValues(alpha: 0.5)),
                        const SizedBox(height: 10),
                        const Text('Graphique des courses',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          // Recent registrations
          Container(
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
                    const Text(
                      'Inscriptions Récentes',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () => context.go('/drivers'),
                      child: const Text('Voir tout'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Table(
                    children: [
                      TableRow(
                        children: [
                          _header('Conducteur'),
                          _header('Véhicule'),
                          _header('Date'),
                          _header('Statut'),
                          _header('Action'),
                        ],
                      ),
                      ...(_pendingDrivers ?? []).map((d) => TableRow(
                            children: [
                              _cell(d['full_name']?.toString() ?? 'Inconnu', fontWeight: FontWeight.w600),
                              _cell(d['vehicle']?.toString() ?? ''),
                              _cell(d['created_at']?.toString().split('T').first ?? ''),
                              _cell(_getStatusBadge(d['status']?.toString() ?? 'pending')),
                              _cell(d['status'] == 'pending'
                                  ? ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        backgroundColor: AdminTheme.info,
                                      ),
                                      child: const Text('Vérifier',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white)),
                                    )
                                  : const SizedBox()),
                            ],
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(String text) => Padding(
        padding: const EdgeInsets.all(12),
        child: Text(text,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
      );

  Widget _cell(dynamic child, {FontWeight? fontWeight}) => Padding(
        padding: const EdgeInsets.all(12),
        child: child is String
            ? Text(child, style: TextStyle(fontWeight: fontWeight))
            : child,
      );

  Widget _getStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;
    switch (status) {
      case 'active':
        bgColor = AdminTheme.success.withValues(alpha: 0.15);
        textColor = AdminTheme.success;
        label = 'Actif';
        break;
      case 'pending':
        bgColor = AdminTheme.warning.withValues(alpha: 0.15);
        textColor = const Color(0xFFD4AC0D);
        label = 'En attente';
        break;
      case 'suspended':
        bgColor = AdminTheme.danger.withValues(alpha: 0.15);
        textColor = AdminTheme.danger;
        label = 'Suspendu';
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
  final String trend;
  final bool? isUp;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.trend,
    required this.isUp,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AdminTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 0.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Row(
              children: [
                if (isUp != null)
                  Icon(
                    isUp! ? Icons.trending_up : Icons.trending_down,
                    size: 14,
                    color: isUp! ? AdminTheme.success : AdminTheme.danger,
                  ),
                const SizedBox(width: 2),
                Flexible(
                  child: Text(
                    trend,
                    style: TextStyle(
                      fontSize: 11,
                      color: isUp == true
                          ? AdminTheme.success
                          : (isUp == false ? AdminTheme.danger : Colors.grey),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
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
