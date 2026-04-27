import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/driver_earnings_provider.dart';

class RevenueScreen extends ConsumerWidget {
  const RevenueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final earningsAsync = ref.watch(driverEarningsProvider);
    final earnings = earningsAsync.value ?? [];

    final now = DateTime.now();
    int todayTotal = 0;
    int weekTotal = 0;
    int monthTotal = 0;
    int yearTotal = 0;

    for (final e in earnings) {
      if (e.earnedAt.year == now.year) {
        yearTotal += e.netAmount;
        if (e.earnedAt.month == now.month) {
          monthTotal += e.netAmount;
          if (e.earnedAt.day == now.day) {
            todayTotal += e.netAmount;
          }
        }
        if (now.difference(e.earnedAt).inDays < 7) {
          weekTotal += e.netAmount;
        }
      }
    }

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
                  'Mes Revenus',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                ),
              ),

              // Section: Aperçu CA
              _sectionHeader('Aperçu Chiffre d\'Affaires'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: [
                    _StatCard(
                      label: "Aujourd'hui",
                      value: '$todayTotal',
                      color: const Color(0xFF43A047),
                    ),
                    _StatCard(label: 'Cette Semaine', value: '$weekTotal'),
                    _StatCard(label: 'Ce Mois', value: '$monthTotal'),
                    _StatCard(
                        label: 'Cette Année (${now.year})',
                        value: '$yearTotal'),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              _sectionHeader('Activité Récente'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: earnings.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text("Aucune activité récente.",
                            style: TextStyle(color: Colors.grey)),
                      )
                    : Column(
                        children: earnings.take(3).map((e) {
                          bool isToday = e.earnedAt.year == now.year &&
                              e.earnedAt.month == now.month &&
                              e.earnedAt.day == now.day;
                          return _ActivityRow(
                            title: isToday
                                ? "Aujourd'hui"
                                : "${e.earnedAt.day}/${e.earnedAt.month}/${e.earnedAt.year}",
                            sub: 'Course',
                            amount: '+ ${e.netAmount} FDJ',
                            amountColor:
                                isToday ? const Color(0xFF43A047) : null,
                            isLast: e == earnings.take(3).last,
                          );
                        }).toList(),
                      ),
              ),

              const SizedBox(height: 20),
              _sectionHeader('Historique'),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    _ActivityRow(
                      title: 'Décembre 2025',
                      sub: 'Mois complet',
                      amount: '135 000 FDJ',
                    ),
                    _ActivityRow(
                      title: 'Novembre 2025',
                      sub: 'Mois complet',
                      amount: '128 000 FDJ',
                    ),
                    Divider(height: 20, color: Color(0xFFEEEEEE)),
                    _ActivityRow(
                      title: 'Année 2025',
                      sub: 'Total annuel',
                      amount: '1 580 000 FDJ',
                      amountBold: true,
                    ),
                    _ActivityRow(
                      title: 'Année 2024',
                      sub: 'Total annuel',
                      amount: '1 420 000 FDJ',
                      amountBold: true,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 5),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF757575),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _StatCard({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF757575),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: color ?? const Color(0xFF121212),
                ),
              ),
              const SizedBox(width: 2),
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
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final String title;
  final String sub;
  final String amount;
  final Color? amountColor;
  final bool amountBold;
  final bool isLast;

  const _ActivityRow({
    required this.title,
    required this.sub,
    required this.amount,
    this.amountColor,
    this.amountBold = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
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
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                sub,
                style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
              ),
            ],
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 15,
              fontWeight: amountBold ? FontWeight.w900 : FontWeight.w900,
              color: amountColor ?? const Color(0xFF121212),
            ),
          ),
        ],
      ),
    );
  }
}
