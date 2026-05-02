import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/admin_theme.dart';

class AdminShell extends StatefulWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  bool _collapsed = false;

  int _getSelectedIndex(String location) {
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/drivers')) return 1;
    if (location.startsWith('/rides')) return 2;
    if (location.startsWith('/finance')) return 3;
    if (location.startsWith('/users')) return 4;
    if (location.startsWith('/map')) return 5;
    if (location.startsWith('/notifications')) return 6;
    if (location.startsWith('/settings')) return 7;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/drivers');
        break;
      case 2:
        context.go('/rides');
        break;
      case 3:
        context.go('/finance');
        break;
      case 4:
        context.go('/users');
        break;
      case 5:
        context.go('/map');
        break;
      case 6:
        context.go('/notifications');
        break;
      case 7:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = _getSelectedIndex(location);

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _collapsed ? 80 : 260,
            child: Container(
              color: AdminTheme.secondary,
              child: Column(
                children: [
                  // Brand
                  Container(
                    height: 70,
                    padding:
                        EdgeInsets.symmetric(horizontal: _collapsed ? 0 : 25),
                    alignment:
                        _collapsed ? Alignment.center : Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_taxi,
                          color: AdminTheme.primary,
                          size: 28,
                        ),
                        if (!_collapsed) ...[
                          const SizedBox(width: 10),
                          const Text(
                            'INGGO ADMIN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  // Nav Items
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      children: [
                        _NavItem(
                          icon: Icons.dashboard,
                          label: 'Dashboard',
                          isSelected: selectedIndex == 0,
                          collapsed: _collapsed,
                          onTap: () => _onItemTapped(0, context),
                        ),
                        _NavItem(
                          icon: Icons.explore,
                          label: 'Carte Live',
                          isSelected: selectedIndex == 5,
                          collapsed: _collapsed,
                          onTap: () => _onItemTapped(5, context),
                        ),
                        _NavItem(
                          icon: Icons.two_wheeler,
                          label: 'Conducteurs',
                          isSelected: selectedIndex == 1,
                          collapsed: _collapsed,
                          onTap: () => _onItemTapped(1, context),
                          badge: '3',
                        ),
                        _NavItem(
                          icon: Icons.map,
                          label: 'Courses',
                          isSelected: selectedIndex == 2,
                          collapsed: _collapsed,
                          onTap: () => _onItemTapped(2, context),
                        ),
                        _NavItem(
                          icon: Icons.payments,
                          label: 'Finance',
                          isSelected: selectedIndex == 3,
                          collapsed: _collapsed,
                          onTap: () => _onItemTapped(3, context),
                        ),
                        _NavItem(
                          icon: Icons.group,
                          label: 'Utilisateurs',
                          isSelected: selectedIndex == 4,
                          collapsed: _collapsed,
                          onTap: () => _onItemTapped(4, context),
                        ),
                        _NavItem(
                          icon: Icons.campaign,
                          label: 'Notifications Push',
                          isSelected: selectedIndex == 6,
                          collapsed: _collapsed,
                          onTap: () => _onItemTapped(6, context),
                        ),
                        _NavItem(
                          icon: Icons.settings,
                          label: 'Paramètres',
                          isSelected: selectedIndex == 7,
                          collapsed: _collapsed,
                          onTap: () => _onItemTapped(7, context),
                        ),
                      ],
                    ),
                  ),
                  // User Profile
                  Container(
                    padding: EdgeInsets.all(_collapsed ? 10 : 20),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.white10)),
                    ),
                    child: _collapsed
                        ? const CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(
                                'https://randomuser.me/api/portraits/men/1.jpg'),
                          )
                        : const Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(
                                    'https://randomuser.me/api/portraits/men/1.jpg'),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Admin Principal',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      'Super Admin',
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Bar
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  decoration: BoxDecoration(
                    color: AdminTheme.surface,
                    border: Border(
                      bottom: BorderSide(
                          color: AdminTheme.border.withValues(alpha: 0.5)),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _collapsed ? Icons.menu : Icons.menu_open,
                          color: AdminTheme.textMain,
                        ),
                        onPressed: () {
                          setState(() {
                            _collapsed = !_collapsed;
                          });
                        },
                      ),
                      const SizedBox(width: 20),
                      Text(
                        _getPageTitle(location),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // Search
                      Container(
                        width: 300,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: AdminTheme.background,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            hintText: 'Rechercher...',
                            border: InputBorder.none,
                            icon: Icon(Icons.search, color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined),
                            onPressed: () {},
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AdminTheme.danger,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Page Content
                Expanded(
                  child: widget.child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPageTitle(String location) {
    if (location.startsWith('/dashboard')) return 'Tableau de Bord';
    if (location.startsWith('/drivers')) return 'Gestion des Conducteurs';
    if (location.startsWith('/rides')) return 'Suivi des Courses';
    if (location.startsWith('/finance')) return 'Finance & Commissions';
    if (location.startsWith('/users')) return 'Gestion Utilisateurs';
    if (location.startsWith('/map')) return 'Carte Temps Réel';
    if (location.startsWith('/notifications')) {
      return 'Campagnes Push & Messages';
    }
    if (location.startsWith('/settings')) return 'Paramètres Généraux';
    return 'Tableau de Bord';
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool collapsed;
  final VoidCallback onTap;
  final String? badge;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.collapsed,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 54,
          padding: EdgeInsets.symmetric(horizontal: collapsed ? 0 : 25),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withValues(alpha: 0.1) : null,
            border: Border(
              left: BorderSide(
                color: isSelected ? AdminTheme.primary : Colors.transparent,
                width: 4,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment:
                collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: isSelected ? AdminTheme.primary : Colors.white70,
                size: 24,
              ),
              if (!collapsed) ...[
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AdminTheme.danger,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
