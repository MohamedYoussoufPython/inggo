import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../app/theme/admin_theme.dart';

class UsersPage extends ConsumerStatefulWidget {
  const UsersPage({super.key});

  @override
  ConsumerState<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends ConsumerState<UsersPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        _users = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredUsers {
    if (_searchQuery.isEmpty) return _users;
    return _users.where((user) {
      final name = (user['full_name'] ?? '').toString().toLowerCase();
      final email = (user['email'] ?? '').toString().toLowerCase();
      final phone = (user['phone'] ?? '').toString();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) ||
          email.contains(query) ||
          phone.contains(query);
    }).toList();
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
              Container(
                width: 300,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: AdminTheme.background,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: const InputDecoration(
                    hintText: 'Rechercher (Nom, Tél...)',
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.grey),
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadUsers,
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
              child: SingleChildScrollView(
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(0.5),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(0.8),
                    3: FlexColumnWidth(1),
                    4: FlexColumnWidth(1.5),
                    5: FlexColumnWidth(1),
                    6: FlexColumnWidth(1),
                    7: FlexColumnWidth(0.8),
                    8: FlexColumnWidth(1),
                  },
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(color: Color(0xFFFAFAFA)),
                      children: [
                        _header('ID'),
                        _header('Utilisateur'),
                        _header('Sexe'),
                        _header('Pays'),
                        _header('Adresse'),
                        _header('Téléphone'),
                        _header('Inscrit le'),
                        _header('Statut'),
                        _header('Actions'),
                      ],
                    ),
                    ..._filteredUsers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final user = entry.value;
                      return TableRow(
                        children: [
                          _cell('#${index + 1}'),
                          _cell(
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 15,
                                  backgroundColor: AdminTheme.primaryLight,
                                  child: Text(
                                    (user['full_name'] ?? 'U')
                                        .toString()
                                        .substring(0, 1),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(user['full_name'] ?? 'Inconnu',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600)),
                                      Text(user['email'] ?? '',
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _cell(user['sexe'] == 'M'
                              ? 'Homme'
                              : (user['sexe'] == 'F' ? 'Femme' : '-')),
                          _cell(user['pays'] ?? 'Djibouti'),
                          _cell(user['address'] ?? '-'),
                          _cell(user['phone'] ?? '-'),
                          _cell(
                              user['created_at']?.toString().split('T').first ??
                                  '-'),
                          _cell(_buildStatusBadge(user['is_active'] ?? true)),
                          _cell(
                            user['is_active'] == true
                                ? ElevatedButton(
                                    onPressed: () =>
                                        _toggleUserStatus(user['id'], false),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AdminTheme.danger,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                    ),
                                    child: const Text('Bloquer',
                                        style: TextStyle(fontSize: 12)),
                                  )
                                : ElevatedButton(
                                    onPressed: () =>
                                        _toggleUserStatus(user['id'], true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AdminTheme.success,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                    ),
                                    child: const Text('Débloquer',
                                        style: TextStyle(fontSize: 12)),
                                  ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
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

  Widget _cell(dynamic child) => Padding(
        padding: const EdgeInsets.all(15),
        child: child is String ? Text(child) : child,
      );

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? AdminTheme.success.withValues(alpha: 0.15)
            : AdminTheme.danger.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'Actif' : 'Bloqué',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isActive ? AdminTheme.success : AdminTheme.danger,
        ),
      ),
    );
  }

  Future<void> _toggleUserStatus(String userId, bool isActive) async {
    try {
      await _supabase
          .from('profiles')
          .update({'is_active': isActive}).eq('id', userId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(isActive ? 'Utilisateur débloqué' : 'Utilisateur bloqué')),
      );

      _loadUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }
}
