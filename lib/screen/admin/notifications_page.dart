import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../app/theme/admin_theme.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  String _selectedTarget = 'all';
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase
          .from('admin_notifications')
          .select()
          .order('created_at', ascending: false)
          .limit(50);

      setState(() {
        _history = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendNotification() async {
    if (_titleController.text.isEmpty || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Veuillez remplir le titre et le message')),
      );
      return;
    }

    try {
      await _supabase.from('admin_notifications').insert({
        'title': _titleController.text,
        'message': _messageController.text,
        'target': _selectedTarget,
        'status': 'sent',
        'sent_by': 'admin',
      });

      await _sendPushNotification();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification envoyée avec succès !')),
        );

        _titleController.clear();
        _messageController.clear();
        _loadHistory();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _sendPushNotification() async {
    try {
      String? targetUserId;
      if (_selectedTarget == 'drivers') {
        final drivers = await _supabase.from('drivers').select('id');
        for (var driver in drivers) {
          await _supabase.from('notifications').insert({
            'user_id': driver['id'],
            'title': _titleController.text,
            'description': _messageController.text,
            'type': 'promo',
            'occurred_at': DateTime.now().toIso8601String(),
          });
        }
      } else if (_selectedTarget == 'clients') {
        final users = await _supabase.from('profiles').select('id');
        for (var user in users) {
          await _supabase.from('notifications').insert({
            'user_id': user['id'],
            'title': _titleController.text,
            'description': _messageController.text,
            'type': 'promo',
            'occurred_at': DateTime.now().toIso8601String(),
          });
        }
      } else {
        final allUsers = await _supabase.from('profiles').select('id');
        for (var user in allUsers) {
          await _supabase.from('notifications').insert({
            'user_id': user['id'],
            'title': _titleController.text,
            'description': _messageController.text,
            'type': 'promo',
            'occurred_at': DateTime.now().toIso8601String(),
          });
        }
        final allDrivers = await _supabase.from('drivers').select('id');
        for (var driver in allDrivers) {
          await _supabase.from('notifications').insert({
            'user_id': driver['id'],
            'title': _titleController.text,
            'description': _messageController.text,
            'type': 'promo',
            'occurred_at': DateTime.now().toIso8601String(),
          });
        }
      }
    } catch (e) {}
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Container(
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
                    'Envoyer une Notification Push',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const Text('Cible (Destinataires)',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedTarget,
                    onChanged: (value) =>
                        setState(() => _selectedTarget = value!),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'all',
                          child: Text(
                              'Tous les utilisateurs (Clients + Conducteurs)')),
                      DropdownMenuItem(
                          value: 'drivers',
                          child: Text('Seulement les Conducteurs')),
                      DropdownMenuItem(
                          value: 'clients',
                          child: Text('Seulement les Clients')),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Titre du Message',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Ex: Info Trafic, Bonus, Promo...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Contenu du Message',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _messageController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Votre message ici...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _sendNotification,
                      icon: const Icon(Icons.send),
                      label: const Text('Envoyer la notification',
                          style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 30),
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: AdminTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AdminTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Historique des envois',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _loadHistory,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _history.isEmpty
                            ? const Center(
                                child: Text('Aucune notification envoyée',
                                    style: TextStyle(color: Colors.grey)),
                              )
                            : SingleChildScrollView(
                                child: Table(
                                  columnWidths: const {
                                    0: FlexColumnWidth(1),
                                    1: FlexColumnWidth(1.2),
                                    2: FlexColumnWidth(2),
                                    3: FlexColumnWidth(1),
                                  },
                                  children: [
                                    TableRow(
                                      decoration: const BoxDecoration(
                                          color: Color(0xFFFAFAFA)),
                                      children: [
                                        _header('Date'),
                                        _header('Cible'),
                                        _header('Titre'),
                                        _header('Statut'),
                                      ],
                                    ),
                                    ..._history.map((item) => TableRow(
                                          children: [
                                            _cell(item['created_at']
                                                    ?.toString()
                                                    .split('T')
                                                    .first ??
                                                '-'),
                                            _cell(_getTargetLabel(
                                                item['target'])),
                                            _cell(item['title'] ?? ''),
                                            _cell(_buildStatusBadge(
                                                item['status'] ?? 'sent')),
                                          ],
                                        )),
                                  ],
                                ),
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTargetLabel(String? target) {
    switch (target) {
      case 'drivers':
        return 'Conducteurs';
      case 'clients':
        return 'Clients';
      default:
        return 'Tous';
    }
  }

  Widget _header(String text) => Padding(
        padding: const EdgeInsets.all(15),
        child: Text(text,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
      );

  Widget _cell(dynamic content) {
    if (content is Widget) {
      return Padding(padding: const EdgeInsets.all(15), child: content);
    }
    return Padding(
        padding: const EdgeInsets.all(15), child: Text(content.toString()));
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AdminTheme.info.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Envoyé',
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.bold, color: AdminTheme.info),
      ),
    );
  }
}
