import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../app/theme/admin_theme.dart';
import '../../../../core/services/driver_service.dart';
import '../../data/models/driver_model.dart';

class DriversPage extends ConsumerStatefulWidget {
  const DriversPage({super.key});

  @override
  ConsumerState<DriversPage> createState() => _DriversPageState();
}

class _DriversPageState extends ConsumerState<DriversPage> {
  String _searchQuery = '';
  String _statusFilter = 'all';
  List<DriverModel> _drivers = [];
  List<Map<String, dynamic>> _pendingRegistrations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  Future<void> _loadDrivers() async {
    setState(() => _isLoading = true);
    try {
      final drivers = await DriverService.getAllDrivers();
      final pending = await DriverService.getPendingDrivers();
      setState(() {
        _drivers = drivers;
        _pendingRegistrations = pending;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<dynamic> get _allEntries {
    final filteredDrivers = _drivers.where((driver) {
      final matchesStatus =
          _statusFilter == 'all' || driver.status == _statusFilter;
      final matchesSearch = _searchQuery.isEmpty ||
          driver.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          driver.phone.contains(_searchQuery) ||
          driver.plate.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesStatus && matchesSearch;
    }).toList();

    if (_statusFilter == 'all' || _statusFilter == 'pending') {
      final filteredPending = _pendingRegistrations.where((p) {
        final name = p['name'] ?? '';
        final phone = p['phone'] ?? '';
        return _searchQuery.isEmpty ||
            name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            phone.contains(_searchQuery);
      }).toList();
      return [...filteredPending, ...filteredDrivers];
    }

    return filteredDrivers;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with filters
          Row(
            children: [
              Expanded(
                child: Container(
                  width: 250,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: AdminTheme.background,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: const InputDecoration(
                      hintText: 'Nom, Plaque, Tél...',
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              ElevatedButton.icon(
                onPressed: () => _showAddDriverDialog(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Ajouter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminTheme.secondary,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 15),
              DropdownButton<String>(
                value: _statusFilter,
                onChanged: (value) => setState(() => _statusFilter = value!),
                items: const [
                  DropdownMenuItem(
                      value: 'all', child: Text('Tous les statuts')),
                  DropdownMenuItem(value: 'pending', child: Text('En attente')),
                  DropdownMenuItem(value: 'active', child: Text('Actif')),
                  DropdownMenuItem(value: 'suspended', child: Text('Suspendu')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Table
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AdminTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AdminTheme.border),
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _allEntries.isEmpty
                      ? const Center(child: Text('Aucun conducteur trouvé'))
                      : SingleChildScrollView(
                          child: Table(
                            columnWidths: const {
                              0: FlexColumnWidth(0.5),
                              1: FlexColumnWidth(2),
                              2: FlexColumnWidth(1.2),
                              3: FlexColumnWidth(1.5),
                              4: FlexColumnWidth(1.5),
                              5: FlexColumnWidth(1),
                              6: FlexColumnWidth(1),
                              7: FlexColumnWidth(1.5),
                            },
                            children: [
                              TableRow(
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFAFAFA),
                                  border: Border(
                                      bottom:
                                          BorderSide(color: AdminTheme.border)),
                                ),
                                children: [
                                  _tableHeader('ID'),
                                  _tableHeader('Conducteur'),
                                  _tableHeader('Téléphone'),
                                  _tableHeader('Adresse'),
                                  _tableHeader('Véhicule'),
                                  _tableHeader('Plaque'),
                                  _tableHeader('Statut'),
                                  _tableHeader('Actions'),
                                ],
                              ),
                              ..._allEntries.map((entry) {
                                if (entry is DriverModel) {
                                  return _buildDriverRow(entry);
                                } else {
                                  return _buildPendingRegistrationRow(entry);
                                }
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

  Widget _tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  Widget _tableCell(dynamic child) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: child is String ? Text(child) : child,
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    switch (status) {
      case 'active':
        bgColor = AdminTheme.success.withValues(alpha: 0.15);
        textColor = AdminTheme.success;
        break;
      case 'pending':
        bgColor = AdminTheme.warning.withValues(alpha: 0.15);
        textColor = const Color(0xFFD4AC0D);
        break;
      case 'suspended':
        bgColor = AdminTheme.danger.withValues(alpha: 0.15);
        textColor = AdminTheme.danger;
        break;
      default:
        bgColor = Colors.grey.withValues(alpha: 0.15);
        textColor = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status == 'active'
            ? 'Actif'
            : (status == 'pending' ? 'En attente' : 'Suspendu'),
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }

  TableRow _buildDriverRow(DriverModel driver) {
    return TableRow(
      children: [
        _tableCell('#${driver.id.substring(0, 4)}'),
        _tableCell(
          Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: AdminTheme.primaryLight,
                child: Text(
                  driver.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  driver.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        _tableCell(driver.phone),
        _tableCell(driver.address ?? '--'),
        _tableCell(driver.vehicle),
        _tableCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              driver.plate,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
        _tableCell(_buildStatusBadge(driver.status)),
        _tableCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility, size: 20),
                color: AdminTheme.info,
                onPressed: () => _showDriverDetails(driver),
              ),
              if (driver.status == 'active')
                IconButton(
                  icon: const Icon(Icons.block, size: 20),
                  color: AdminTheme.danger,
                  onPressed: () => _suspendDriver(driver),
                )
              else if (driver.status == 'suspended')
                IconButton(
                  icon: const Icon(Icons.lock_open, size: 20),
                  color: AdminTheme.success,
                  onPressed: () => _reactivateDriver(driver),
                ),
            ],
          ),
        ),
      ],
    );
  }

  TableRow _buildPendingRegistrationRow(Map<String, dynamic> data) {
    final name = data['name'] ?? 'Inconnu';
    final phone = data['phone'] ?? '--';

    return TableRow(
      decoration: BoxDecoration(
        color: AdminTheme.warning.withValues(alpha: 0.05),
      ),
      children: [
        _tableCell('NEW'),
        _tableCell(
          Row(
            children: [
              const CircleAvatar(
                radius: 15,
                backgroundColor: Colors.orange,
                child: Icon(Icons.person, size: 15, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        _tableCell(phone),
        _tableCell('--'),
        _tableCell('À vérifier'),
        _tableCell('--'),
        _tableCell(_buildStatusBadge('pending')),
        _tableCell(
          ElevatedButton(
            onPressed: () => _showPendingDriverDetails(data),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              visualDensity: VisualDensity.compact,
            ),
            child: const Text('Vérifier', style: TextStyle(fontSize: 11)),
          ),
        ),
      ],
    );
  }

  void _showPendingDriverDetails(Map<String, dynamic> data) {
    final vehicleCtrl = TextEditingController();
    final plateCtrl = TextEditingController();
    final docs = data['driver_documents'] as List?;
    final doc = docs != null && docs.isNotEmpty ? docs[0] : null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Vérification : ${data['name']}'),
        content: SizedBox(
          width: 800,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column 1: Info & Validation
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _detailRow('Téléphone', data['phone'] ?? '--'),
                      _detailRow('Email', data['email'] ?? '--'),
                      _detailRow('Sexe', data['sexe'] ?? '--'),
                      const Divider(),
                      const Text('Informations Véhicule',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: vehicleCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Modèle Moto (ex: Yamaha FZ)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: plateCtrl,
                        decoration: const InputDecoration(
                          labelText: 'N° de Plaque',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (vehicleCtrl.text.isEmpty ||
                                    plateCtrl.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Saisissez les infos')),
                                  );
                                  return;
                                }
                                await DriverService.approveDriver(
                                  userId: data['id'],
                                  name: data['name'],
                                  phone: data['phone'],
                                  vehicle: vehicleCtrl.text,
                                  plate: plateCtrl.text,
                                );
                                _loadDrivers();
                                if (context.mounted) Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AdminTheme.success),
                              child: const Text('Approuver'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                await DriverService.rejectDriver(data['id']);
                                _loadDrivers();
                                if (context.mounted) Navigator.pop(context);
                              },
                              style: OutlinedButton.styleFrom(
                                  foregroundColor: AdminTheme.danger),
                              child: const Text('Refuser'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const VerticalDivider(width: 30),
              // Column 2: Documents
              Expanded(
                flex: 2,
                child: doc == null
                    ? const Center(child: Text('Aucun document trouvé'))
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildDocPreview('Carte d\'identité', doc['cni_url']),
                            _buildDocPreview(
                                'Permis de conduire', doc['permis_url']),
                            _buildDocPreview('Assurance', doc['assurance_url']),
                            _buildDocPreview('Photo Moto', doc['moto_url']),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocPreview(String label, String? path) {
    if (path == null) return const SizedBox.shrink();
    final url = Supabase.instance.client.storage.from('driver-docs').getPublicUrl(path);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              url,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 100,
                color: Colors.grey[200],
                child: const Center(child: Text('Image non disponible')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDriverDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final vehicleController = TextEditingController();
    final plateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un Conducteur'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameController,
                  decoration:
                      const InputDecoration(labelText: 'Nom Complet *')),
              const SizedBox(height: 10),
              TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Téléphone *')),
              const SizedBox(height: 10),
              TextField(
                  controller: vehicleController,
                  decoration: const InputDecoration(labelText: 'Véhicule *')),
              const SizedBox(height: 10),
              TextField(
                  controller: plateController,
                  decoration: const InputDecoration(labelText: 'Plaque *')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  phoneController.text.isNotEmpty) {
                await DriverService.createDriver(
                  name: nameController.text,
                  phone: phoneController.text,
                  vehicle: vehicleController.text,
                  plate: plateController.text,
                );
                _loadDrivers();
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showDriverDetails(DriverModel driver) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(driver.name),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Téléphone', driver.phone),
              _detailRow('Email', driver.email ?? '--'),
              _detailRow('Adresse', driver.address ?? '--'),
              _detailRow('Véhicule', driver.vehicle),
              _detailRow('Plaque', driver.plate),
              _detailRow('Statut', driver.status),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer')),
          if (driver.status == 'pending') ...[
            ElevatedButton(
              onPressed: () async {
                await DriverService.updateDriverStatus(driver.id, 'active');
                _loadDrivers();
                if (context.mounted) Navigator.pop(context);
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: AdminTheme.success),
              child: const Text('Valider'),
            ),
            ElevatedButton(
              onPressed: () async {
                await DriverService.updateDriverStatus(driver.id, 'rejected');
                _loadDrivers();
                if (context.mounted) Navigator.pop(context);
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: AdminTheme.danger),
              child: const Text('Refuser'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Future<void> _suspendDriver(DriverModel driver) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: Text('Voulez-vous vraiment suspendre ${driver.name} ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirmer')),
        ],
      ),
    );
    if (confirm == true) {
      await DriverService.updateDriverStatus(driver.id, 'suspended');
      _loadDrivers();
    }
  }

  Future<void> _reactivateDriver(DriverModel driver) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: Text('Voulez-vous réactiver le compte de ${driver.name} ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirmer')),
        ],
      ),
    );
    if (confirm == true) {
      await DriverService.updateDriverStatus(driver.id, 'active');
      _loadDrivers();
    }
  }
}
