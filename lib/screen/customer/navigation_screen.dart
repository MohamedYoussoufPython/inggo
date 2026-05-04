import 'package:flutter/material.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  String state = 'navigating';
  int currentMinutes = 5;
  int userRating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.grey.shade200,
            child: const Center(
              child: Text('Carte Navigation (Leaflet/Google Maps)'),
            ),
          ),
          _buildNavHeader(),
          _buildBottomSheet(),
          if (state == 'completed') _buildRatingOverlay(),
        ],
      ),
    );
  }

  Widget _buildNavHeader() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: state == 'arrived'
                ? const Color(0xFF43A047)
                : const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 15,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: state == 'arrived'
                      ? const Color(0xFFFFFFFF)
                      : const Color(0xFFFFC107),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  state == 'arrived' ? Icons.place : Icons.navigation,
                  color: state == 'arrived'
                      ? const Color(0xFF43A047)
                      : const Color(0xFF121212),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state == 'arrived'
                          ? 'Vous êtes arrivé !'
                          : 'Navigation active',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: state == 'arrived'
                            ? const Color(0xFFFFFFFF)
                            : const Color(0xFF121212),
                      ),
                    ),
                    Text(
                      'Arrivée dans $currentMinutes min',
                      style: TextStyle(
                        fontSize: 11,
                        color: state == 'arrived'
                            ? const Color(0xFFFFFFFF)
                            : const Color(0xFF757575),
                      ),
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

  Widget _buildBottomSheet() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const CircleAvatar(
                  radius: 19,
                  child: Icon(Icons.person, size: 20),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amin Mohamed',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        '📍 Balbala',
                        style:
                            TextStyle(fontSize: 11, color: Color(0xFF757575)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.chat, color: Colors.green),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.call, color: Color(0xFF43A047)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(Icons.route, '2.3 km', 'Dist.'),
                  _buildStatItem(
                      Icons.schedule, '$currentMinutes min', 'Temps'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _handleAction,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                backgroundColor: state == 'in_trip'
                    ? const Color(0xFF121212)
                    : const Color(0xFFFFC107),
                foregroundColor: state == 'in_trip'
                    ? const Color(0xFFFFC107)
                    : const Color(0xFF121212),
              ),
              child: Text(
                state == 'navigating'
                    ? 'Je suis arrivé'
                    : state == 'arrived'
                        ? 'Démarrer'
                        : 'Terminer',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFFFC107), size: 18),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF757575)),
        ),
      ],
    );
  }

  Widget _buildRatingOverlay() {
    return Container(
      color: const Color(0xFFFFFFFF),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 48,
                color: Color(0xFF43A047),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Course terminée',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            const Text(
              'Notez Amin Mohamed',
              style: TextStyle(fontSize: 18, color: Color(0xFF757575)),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => IconButton(
                  onPressed: () => setState(() => userRating = index + 1),
                  icon: Icon(
                    Icons.star,
                    size: 48,
                    color: index < userRating
                        ? const Color(0xFFFFC107)
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF121212),
                foregroundColor: const Color(0xFFFFC107),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                child: Text('Retour à l\'accueil'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAction() {
    setState(() {
      if (state == 'navigating') {
        state = 'arrived';
        currentMinutes = 0;
      } else if (state == 'arrived') {
        state = 'in_trip';
        currentMinutes = 12;
      } else if (state == 'in_trip') {
        state = 'completed';
      }
    });
  }
}
