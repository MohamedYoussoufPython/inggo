import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../provider/driver_reviews_provider.dart';
import '../../provider/driver_provider.dart';
import '../../provider/driver_rides_provider.dart';

class ReviewsScreen extends ConsumerWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(driverReviewsProvider);
    final reviews = reviewsAsync.value ?? [];

    final driver = ref.watch(driverProvider).value;
    final rating = driver?.rating ?? 5.0;

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
      } else if (diff == 1 || (diff == 0 && now.day != d.day)) {
        yesterdayCount++;
      } else if (diff == 2) {
        beforeCount++;
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
                  'Mes Avis',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                ),
              ),

              // Global rating card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: const Border.all(color: Color(0xFFF5F5F5)),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          5,
                          (_) => const Icon(
                            Icons.star,
                            color: Color(0xFFFFC107),
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Basé sur ${rides.length} courses',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF757575),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              _sectionHeader('Clients Transportés'),

              // Client count rows
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: const Border.all(color: Color(0xFFF5F5F5)),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _CountRow(
                        title: "Aujourd'hui",
                        sub: '7 Janv.',
                        count: todayCount,
                        highlight: true,
                      ),
                      _CountRow(
                        title: 'Hier',
                        sub: '6 Janv.',
                        count: yesterdayCount,
                      ),
                      _CountRow(
                        title: 'Avant-hier',
                        sub: '5 Janv.',
                        count: beforeCount,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              _sectionHeader('Commentaires récents'),

              // Comments
              if (reviews.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text('Aucun commentaire.',
                      style: TextStyle(color: Colors.grey)),
                )
              else
                ...reviews.map((r) {
                  return Column(children: [
                    _commentCard(r.reviewerName ?? 'Client anonyme',
                        r.comment ?? 'Aucun commentaire', r.rating.toInt()),
                    const SizedBox(height: 10),
                  ]);
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
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

  Widget _commentCard(String name, String comment, int stars) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border.all(color: Color(0xFFF5F5F5)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    comment,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  '$stars',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.star, size: 14, color: Color(0xFFFFC107)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CountRow extends StatelessWidget {
  final String title;
  final String sub;
  final int count;
  final bool highlight;
  final bool isLast;

  const _CountRow({
    required this.title,
    required this.sub,
    required this.count,
    this.highlight = false,
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
              const SizedBox(height: 2),
              Text(
                sub,
                style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
              ),
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
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF757575),
              ),
            ),
        ],
      ),
    );
  }
}
