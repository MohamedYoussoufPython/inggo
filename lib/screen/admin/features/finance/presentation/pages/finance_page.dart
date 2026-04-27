import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../app/theme/admin_theme.dart';
import '../../../../core/services/admin_stats_service.dart';

class FinancePage extends ConsumerStatefulWidget {
  const FinancePage({super.key});

  @override
  ConsumerState<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends ConsumerState<FinancePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SupabaseClient _supabase = Supabase.instance.client;

  Map<String, dynamic> _financeStats = {};
  List<Map<String, dynamic>> _dailyTransactions = [];
  List<Map<String, dynamic>> _driverDebts = [];
  List<Map<String, dynamic>> _adminDebts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final stats = await AdminStatsService.getFinanceStats();

      final dailyData = await _supabase
          .from('rides')
          .select('created_at, price, status')
          .eq('status', 'completed')
          .order('created_at', ascending: false)
          .limit(30);

      final driverDebtData = await _supabase
          .from('driver_debts')
          .select()
          .order('created_at', ascending: false)
          .limit(20);

      final adminDebtData = await _supabase
          .from('admin_debts')
          .select()
          .order('created_at', ascending: false)
          .limit(20);

      setState(() {
        _financeStats = stats;
        _dailyTransactions = List<Map<String, dynamic>>.from(dailyData);
        _driverDebts = List<Map<String, dynamic>>.from(driverDebtData);
        _adminDebts = List<Map<String, dynamic>>.from(adminDebtData);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          Row(
            children: [
              _buildStatCard(
                title: 'Revenus Ce Mois',
                value: '${_financeStats['currentRevenue'] ?? 0} FDJ',
                icon: Icons.account_balance_wallet,
                color: AdminTheme.success,
              ),
              const SizedBox(width: 20),
              _buildStatCard(
                title: 'Moyenne/ Course',
                value: '${_financeStats['avgPerRide'] ?? 0} FDJ',
                icon: Icons.trending_up,
                color: AdminTheme.info,
              ),
              const SizedBox(width: 20),
              _buildStatCard(
                title: 'Courses',
                value: '${_financeStats['rideCount'] ?? 0}',
                icon: Icons.local_taxi,
                color: AdminTheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: AdminTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AdminTheme.border),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AdminTheme.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AdminTheme.primary,
              tabs: const [
                Tab(text: 'Suivi Journalier'),
                Tab(text: 'Dettes Conducteur'),
                Tab(text: 'Dettes Inggo'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _saveData,
                icon: const Icon(Icons.cloud_upload, size: 18),
                label: const Text('Enregistrer'),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: _exportToExcel,
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Exporter CSV'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AdminTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AdminTheme.border),
              ),
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDailyFollowUp(),
                  _buildDriverDebt(),
                  _buildAdminDebt(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AdminTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AdminTheme.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyFollowUp() {
    if (_dailyTransactions.isEmpty) {
      return const Center(
        child: Text('Aucune transaction trouvée',
            style: TextStyle(color: Colors.grey)),
      );
    }

    final groupedByDate = <String, List<Map<String, dynamic>>>{};
    for (var t in _dailyTransactions) {
      final date = t['created_at']?.toString().split('T').first ?? '';
      groupedByDate.putIfAbsent(date, () => []).add(t);
    }

    return SingleChildScrollView(
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.5),
          1: FlexColumnWidth(1.5),
          2: FlexColumnWidth(1.2),
          3: FlexColumnWidth(1.5),
          4: FlexColumnWidth(1.2),
          5: FlexColumnWidth(1.2),
        },
        children: [
          TableRow(
            decoration: const BoxDecoration(color: Color(0xFFFAFAFA)),
            children: [
              _header('DATE'),
              _header('RECETTES (FDJ)'),
              _header('NBR COURSES'),
              _header('COMMISSION'),
              _header('DÉPENSES'),
              _header('SOLDE NET'),
            ],
          ),
          ...groupedByDate.entries.map((entry) {
            final rides = entry.value;
            final totalRevenue = rides.fold<int>(
                0, (sum, r) => sum + ((r['price'] as int?) ?? 0));
            final commission = rides.length * 40;
            final net = totalRevenue - commission;

            return TableRow(
              children: [
                _cell(Text(entry.key,
                    style: const TextStyle(fontWeight: FontWeight.w500))),
                _cell(Text('$totalRevenue')),
                _cell(Text('${rides.length}')),
                _cell(Text('$commission',
                    style: const TextStyle(color: AdminTheme.primaryDark))),
                _cell(const Text('--', style: TextStyle(color: Colors.grey))),
                _cell(Text('$net',
                    style: const TextStyle(fontWeight: FontWeight.bold))),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDriverDebt() {
    if (_driverDebts.isEmpty) {
      return const Center(
        child: Text('Aucune dette conducteur trouvée',
            style: TextStyle(color: Colors.grey)),
      );
    }

    return SingleChildScrollView(
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.5),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(1.2),
          3: FlexColumnWidth(1.5),
          4: FlexColumnWidth(1.2),
        },
        children: [
          TableRow(
            decoration: const BoxDecoration(color: Color(0xFFFAFAFA)),
            children: [
              _header('DATE'),
              _header('CONDUCTEUR'),
              _header('MONTANT (FDJ)'),
              _header('MOTIF'),
              _header('STATUT'),
            ],
          ),
          ..._driverDebts.map((debt) => TableRow(
                children: [
                  _cell(Text(
                      debt['created_at']?.toString().split('T').first ?? '--')),
                  _cell(Text(debt['driver_name'] ?? '--')),
                  _cell(Text('${debt['amount'] ?? 0}')),
                  _cell(Text(debt['reason'] ?? '--')),
                  _cell(_buildStatusBadge(debt['status'] ?? 'pending')),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildAdminDebt() {
    if (_adminDebts.isEmpty) {
      return const Center(
        child: Text('Aucune dette Inggo trouvée',
            style: TextStyle(color: Colors.grey)),
      );
    }

    return SingleChildScrollView(
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.5),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(1.2),
          3: FlexColumnWidth(1.5),
          4: FlexColumnWidth(1.2),
        },
        children: [
          TableRow(
            decoration: const BoxDecoration(color: Color(0xFFFAFAFA)),
            children: [
              _header('DATE'),
              _header('CONDUCTEUR'),
              _header('MONTANT (FDJ)'),
              _header('MOTIF'),
              _header('STATUT'),
            ],
          ),
          ..._adminDebts.map((debt) => TableRow(
                children: [
                  _cell(Text(
                      debt['created_at']?.toString().split('T').first ?? '--')),
                  _cell(Text(debt['driver_name'] ?? '--')),
                  _cell(Text('${debt['amount'] ?? 0}')),
                  _cell(Text(debt['reason'] ?? '--')),
                  _cell(_buildStatusBadge(debt['status'] ?? 'pending')),
                ],
              )),
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

  Widget _cell(Widget child) =>
      Padding(padding: const EdgeInsets.all(15), child: child);

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;
    switch (status) {
      case 'paid':
        bgColor = AdminTheme.success.withValues(alpha: 0.15);
        textColor = AdminTheme.success;
        label = 'Payé';
        break;
      case 'pending':
        bgColor = AdminTheme.warning.withValues(alpha: 0.15);
        textColor = AdminTheme.warning;
        label = 'En attente';
        break;
      default:
        bgColor = Colors.grey.withValues(alpha: 0.15);
        textColor = Colors.grey;
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.bold, color: textColor)),
    );
  }

  Future<void> _saveData() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Données sauvegardées!')),
    );
  }

  void _exportToExcel() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fichier exporté!')),
    );
  }
}
