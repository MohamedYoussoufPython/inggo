import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../app/theme/admin_theme.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final SupabaseClient _supabase = Supabase.instance.client;

  final _commissionController = TextEditingController(text: '40');
  final _priceController = TextEditingController(text: '250');
  final _emailController =
      TextEditingController(text: 'admin@inngroupsarl.com');
  bool _maintenanceMode = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final settings = await _supabase.from('settings').select().maybeSingle();

      if (settings != null) {
        _commissionController.text = (settings['commission'] ?? 40).toString();
        _priceController.text = (settings['base_price'] ?? 250).toString();
        _maintenanceMode = settings['maintenance_mode'] ?? false;
        if (settings['admin_email'] != null) {
          _emailController.text = settings['admin_email'];
        }
      }
    } catch (e) {}
    setState(() => _isLoading = false);
  }

  Future<void> _saveSettings() async {
    try {
      await _supabase.from('settings').upsert({
        'id': 1,
        'commission': int.tryParse(_commissionController.text) ?? 40,
        'base_price': int.tryParse(_priceController.text) ?? 250,
        'admin_email': _emailController.text,
        'maintenance_mode': _maintenanceMode,
        'updated_at': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paramètres sauvegardés!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  @override
  void dispose() {
    _commissionController.dispose();
    _priceController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Paramètres Généraux',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  _buildSettingCard(
                    'Commission par Course (FDJ)',
                    'Montant récupéré par Inggo sur chaque course',
                    _commissionController,
                    prefix: '',
                  ),
                  const SizedBox(height: 20),
                  _buildSettingCard(
                    'Prix de Base (FDJ)',
                    'Prix minimum pour une course',
                    _priceController,
                    prefix: '',
                  ),
                  const SizedBox(height: 20),
                  _buildSettingCard(
                    'Email Administrateur',
                    'Adresse email pour les notifications',
                    _emailController,
                    prefix: '',
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Configuration Avancée',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AdminTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AdminTheme.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Mode Maintenance',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _maintenanceMode
                                  ? 'L\'application est actuellement en maintenance'
                                  : 'L\'application est en ligne',
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.grey),
                            ),
                          ],
                        ),
                        Switch(
                          value: _maintenanceMode,
                          onChanged: (value) {
                            setState(() => _maintenanceMode = value);
                            _saveSettings();
                          },
                          activeThumbColor: AdminTheme.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 30),
          Expanded(
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
                    'Actions Rapides',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveSettings,
                      icon: const Icon(Icons.save),
                      label: const Text('Enregistrer'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _loadSettings,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réinitialiser'),
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

  Widget _buildSettingCard(
      String title, String description, TextEditingController controller,
      {String prefix = ''}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(description,
              style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 15),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixText: prefix,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
