import 'package:flutter/material.dart';
import 'navigation_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  bool isOnline = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              _buildHomeTab(),
              _buildEarningsTab(),
              _buildReviewsTab(),
              _buildAccountTab(),
            ],
          ),
          _buildHeader(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFFFC107),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Revenus'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Avis'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Compte'),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFFFFFFF),
              child: ClipOval(
                child: Image.network(
                  'https://randomuser.me/api/portraits/men/85.jpg',
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => isOnline = !isOnline),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isOnline
                      ? const Color(0xFF43A047)
                      : const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isOnline
                            ? const Color(0xFFFFFFFF)
                            : const Color(0xFFD32F2F),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isOnline ? 'EN LIGNE' : 'HORS LIGNE',
                      style: const TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Stack(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.notifications),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD32F2F),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return Stack(
      children: [
        Container(
          color: Colors.grey.shade200,
          child: const Center(
            child: Text('Carte Interactive (Leaflet/Google Maps)'),
          ),
        ),
        if (isOnline)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat('4 500', 'FDJ', 'Bénéfice'),
                      Container(
                          width: 1, height: 30, color: Colors.grey.shade300),
                      _buildStat('12', '', 'Clients'),
                      Container(
                          width: 1, height: 30, color: Colors.grey.shade300),
                      _buildStat('4.9', '⭐', 'Note'),
                    ],
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NavigationScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text('Simuler une course'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStat(String value, String unit, String label) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            if (unit.isNotEmpty)
              Text(
                ' $unit',
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF757575),
          ),
        ),
      ],
    );
  }

  Widget _buildEarningsTab() {
    return ListView(
      padding: const EdgeInsets.only(top: 100, left: 24, right: 24, bottom: 24),
      children: [
        const Text(
          'Mes Revenus',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 20),
        _buildEarningCard('Aujourd\'hui', '4 500 FDJ', const Color(0xFF43A047)),
        _buildEarningCard(
            'Cette Semaine', '31 500 FDJ', const Color(0xFF121212)),
        _buildEarningCard('Ce Mois', '85 000 FDJ', const Color(0xFF121212)),
      ],
    );
  }

  Widget _buildEarningCard(String label, String amount, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          Text(
            amount,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w900, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    return ListView(
      padding: const EdgeInsets.only(top: 100, left: 24, right: 24, bottom: 24),
      children: [
        const Text(
          'Mes Avis',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF0F0F0)),
          ),
          child: const Column(
            children: [
              Text(
                '4.9',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900),
              ),
              Text('⭐⭐⭐⭐⭐'),
              SizedBox(height: 10),
              Text(
                'Basé sur 150 courses',
                style: TextStyle(fontSize: 12, color: Color(0xFF757575)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountTab() {
    return ListView(
      padding: const EdgeInsets.only(top: 100, left: 24, right: 24, bottom: 24),
      children: [
        const Text(
          'Mon Compte',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 30),
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                child: ClipOval(
                  child: Image.network(
                    'https://randomuser.me/api/portraits/men/85.jpg',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Khaireh Abdi',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 5),
              const Text(
                'Yamaha FZ • 336D91',
                style: TextStyle(fontSize: 13, color: Color(0xFF757575)),
              ),
              const SizedBox(height: 5),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '4.9',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.star, size: 16, color: Color(0xFFFFC107)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        _buildMenuItem(Icons.history, 'Historique des courses'),
        _buildMenuItem(Icons.description, 'Documents'),
        _buildMenuItem(Icons.two_wheeler, 'Véhicule'),
        _buildMenuItem(Icons.settings, 'Paramètres'),
        _buildMenuItem(Icons.help_outline, 'Aide & Support'),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.shade100),
          ),
          child: ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFFD32F2F)),
            title: const Text(
              'Déconnexion',
              style: TextStyle(
                  color: Color(0xFFD32F2F), fontWeight: FontWeight.w700),
            ),
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFFFFC107)),
        ),
        title: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {},
      ),
    );
  }
}
