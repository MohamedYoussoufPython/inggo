import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/inggo_theme.dart';
import '../../provider/history_provider.dart';
import '../../models/ride_model.dart';
import '../shared/widgets/profile_scaffold.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ridesAsync = ref.watch(historyProvider);

    return ProfileScaffold(
      title: 'Mes Courses',
      body: ridesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: InggoColors.primary),
        ),
        error: (err, stack) => Center(
          child: Text('Erreur: $err',
              style: const TextStyle(color: InggoColors.error)),
        ),
        data: (rides) {
          if (rides.isEmpty) {
            return const Center(
              child: Text(
                'Aucune course.',
                style: TextStyle(
                  fontSize: 15,
                  color: InggoColors.text3,
                  fontFamily: 'Roboto',
                ),
              ),
            );
          }
          final sortedRides = [...rides]
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            itemCount: sortedRides.length,
            itemBuilder: (context, index) {
              return _RideCard(ride: sortedRides[index]);
            },
          );
        },
      ),
    );
  }
}

class _RideCard extends StatelessWidget {
  final RideModel ride;

  const _RideCard({required this.ride});

  @override
  Widget build(BuildContext context) {
    final isCancel = ride.isCancelled;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header : date + statut
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Date
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 14, color: Color(0xFF757575)),
                  const SizedBox(width: 6),
                  Text(
                    ride.date,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF757575),
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
              // Badge statut
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isCancel
                      ? const Color(0xFFFFF0F0)
                      : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isCancel ? 'ANNULÉE' : 'TERMINÉE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isCancel
                        ? const Color(0xFFFF4D4D)
                        : const Color(0xFF4CAF50),
                    letterSpacing: 0.5,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Body : icône + trajet + prix
          Row(
            children: [
              // Icône box
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isCancel ? Icons.close : Icons.two_wheeler,
                  size: 20,
                  color: const Color(0xFF121212),
                ),
              ),
              const SizedBox(width: 15),
              // Info trajet
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${ride.pickup} → ${ride.dropoff}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF121212),
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Chauffeur : ${ride.driver}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF757575),
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
              // Prix
              Text(
                ride.price,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF121212),
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
