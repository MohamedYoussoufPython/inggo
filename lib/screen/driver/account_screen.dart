import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../provider/driver_provider.dart';
import '../../provider/driver_rides_provider.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  // Animated counters
  int _todayCount = 0;
  int _yesterdayCount = 0;
  int _beforeCount = 0;
  int _totalCount = 0;

  String _name = '';

  @override
  void initState() {
    super.initState();
  }

  void _editName() {
    final ctrl = TextEditingController(text: _name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Modifier le nom',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: 'Nom complet',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _name = ctrl.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC107),
              foregroundColor: const Color(0xFF121212),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Sauvegarder',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Déconnexion',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Déconnexion',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final driver = ref.watch(driverProvider).value;
    if (driver != null) {
      _name = driver.fullName;
    }

    final ridesAsync = ref.watch(driverRidesProvider);
    final rides = ridesAsync.value ?? [];

    int todayCount = 0;
    int yesterdayCount = 0;
    int beforeCount = 0;

    final now = DateTime.now();
    for (final r in rides) {
      final d = DateTime.fromMillisecondsSinceEpoch(r.timestamp);
      final diff = now.difference(d).inDays;
      if (diff == 0 && now.day == d.day) {
        todayCount++;
      } else if (diff == 1 || (diff == 0 && now.day != d.day))
        yesterdayCount++;
      else if (diff == 2) beforeCount++;
    }

    _todayCount = todayCount;
    _yesterdayCount = yesterdayCount;
    _beforeCount = beforeCount;
    _totalCount = rides.length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 20, bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: Text(
                  'Mon Compte',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                ),
              ),

              // Profile header
              _buildProfileHeader(),
              const SizedBox(height: 20),

              // Performance stats
              _buildPerformanceSection(),
              const SizedBox(height: 20),

              // Menu sections
              _menuSectionTitle('Général'),
              _menuItem(
                Icons.history,
                'Historique des courses',
                'Vos trajets récents',
                const Color(0xFFFFF8E1),
                const Color(0xFFFFC107),
                () => _push('/driver-history'),
              ),
              _menuItem(
                Icons.description,
                'Documents',
                'Permis, Assurance, Carte Grise',
                const Color(0xFFE3F2FD),
                const Color(0xFF1976D2),
                () => _push('/driver-documents'),
              ),
              _menuItem(
                Icons.two_wheeler,
                'Véhicule',
                'Gérer ma moto',
                const Color(0xFFE8F5E9),
                const Color(0xFF388E3C),
                () => _push('/driver-vehicle'),
              ),
              _menuItem(
                Icons.account_balance,
                'Infos Bancaires',
                'Virements & Paiements',
                const Color(0xFFFFF3E0),
                const Color(0xFFF57C00),
                () => _push('/driver-banking'),
              ),

              _menuSectionTitle('Application'),
              _menuItem(
                Icons.settings,
                'Paramètres',
                'Notifications, Son, Navigation',
                const Color(0xFFFFF8E1),
                const Color(0xFFFFC107),
                () => _push('/driver-settings'),
              ),
              _menuItem(
                Icons.help_outline,
                'Aide & Support',
                'FAQ, Contacter Inggo',
                const Color(0xFFE3F2FD),
                const Color(0xFF1976D2),
                () => _push('/driver-support'),
              ),

              // Logout
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: GestureDetector(
                  onTap: _confirmLogout,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      border: Border.all(color: const Color(0xFFFFCDD2)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.logout,
                            color: Color(0xFFD32F2F),
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Text(
                          'Déconnexion',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFD32F2F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Version
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Center(
                  child: Text(
                    'Version 1.0.2',
                    style: TextStyle(fontSize: 11, color: Color(0xFFCCCCCC)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        // Avatar
        Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                size: 50,
                color: Color(0xFF757575),
              ),
            ),
            Positioned(
              bottom: 0,
              right: -5,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.photo_camera,
                    size: 16,
                    color: Color(0xFF121212),
                  ),
                ),
              ),
            ),
          ],
        ).let((w) => Center(child: w)),

        const SizedBox(height: 15),

        // Name + edit
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _editName,
              child: const Icon(Icons.edit, size: 16, color: Color(0xFF757575)),
            ),
          ],
        ),

        const SizedBox(height: 5),

        // Vehicle badge
        Consumer(builder: (context, ref, child) {
          final driverInfo = ref.watch(driverProvider).value;
          final vehicleStr = driverInfo?.vehicle ?? '';
          final plateStr = driverInfo?.licensePlate ?? '';
          final text = vehicleStr.isNotEmpty
              ? '$vehicleStr${plateStr.isNotEmpty ? ' • $plateStr' : ''}'
              : 'Aucun véhicule défini';
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF757575),
              ),
            ),
          );
        }),

        const SizedBox(height: 8),

        // Rating
        Consumer(builder: (context, ref, child) {
          final driverInfo = ref.watch(driverProvider).value;
          final rate = driverInfo?.rating ?? 5.0;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                rate.toStringAsFixed(1),
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.star, size: 16, color: Color(0xFFFFC107)),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildPerformanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _menuSectionTitle('Performance Clients'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFF5F5F5)),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                _perfRow(
                  "Aujourd'hui",
                  '7 Janv.',
                  _todayCount,
                  highlight: true,
                ),
                _perfRow('Hier', '6 Janv.', _yesterdayCount),
                _perfRow('Avant-hier', '5 Janv.', _beforeCount),
                const Divider(height: 20),
                _perfRow(
                  'Total Semaine',
                  '',
                  _totalCount,
                  isTotal: true,
                  isLast: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _perfRow(
    String title,
    String sub,
    int count, {
    bool highlight = false,
    bool isTotal = false,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isTotal
                      ? const Color(0xFF336D91)
                      : const Color(0xFF121212),
                ),
              ),
              if (sub.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ],
          ),
          if (highlight)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC107),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF121212),
                ),
              ),
            )
          else
            Text(
              '$count',
              style: TextStyle(
                fontSize: isTotal ? 18 : 15,
                fontWeight: FontWeight.w700,
                color:
                    isTotal ? const Color(0xFF336D91) : const Color(0xFF757575),
              ),
            ),
        ],
      ),
    );
  }

  Widget _menuSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 20, 30, 10),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF757575),
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _menuItem(
    IconData icon,
    String title,
    String sub,
    Color bgColor,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFF5F5F5)),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sub,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFFCCCCCC),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _push(String path) {
    context.push(path);
  }
}

extension _WidgetExt on Widget {
  Widget let(Widget Function(Widget) transform) => transform(this);
}
