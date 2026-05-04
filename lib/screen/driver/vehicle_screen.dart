import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widget/inggo_input.dart';
import '../../provider/driver_provider.dart';

class VehicleScreen extends ConsumerStatefulWidget {
  const VehicleScreen({super.key});

  @override
  ConsumerState<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends ConsumerState<VehicleScreen> {
  String _brand = '';
  String _model = '';
  String _year = '';
  String _color = '';
  String _plate = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final driver = ref.read(driverProvider).value;
      if (driver != null) {
        setState(() {
          _plate = driver.licensePlate ?? '';
          final parts = (driver.vehicle ?? '').split(' - ');
          _brand = parts.isNotEmpty ? parts[0] : '';
          _model = parts.length > 1 ? parts[1] : '';
          _year = parts.length > 2 ? parts[2] : '';
          _color = parts.length > 3 ? parts[3] : '';
        });
      }
    });
  }

  void _editVehicle() {
    final brandCtrl = TextEditingController(text: _brand);
    final modelCtrl = TextEditingController(text: _model);
    final yearCtrl = TextEditingController(text: _year);
    final colorCtrl = TextEditingController(text: _color);
    final plateCtrl = TextEditingController(text: _plate);

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Modifier le véhicule',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 20),
                InggoInput(
                  label: 'Marque',
                  placeholder: 'Marque',
                  controller: brandCtrl,
                ),
                const SizedBox(height: 12),
                InggoInput(
                  label: 'Modèle',
                  placeholder: 'Modèle',
                  controller: modelCtrl,
                ),
                const SizedBox(height: 12),
                InggoInput(
                  label: 'Année',
                  placeholder: '2023',
                  controller: yearCtrl,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                InggoInput(
                  label: 'Couleur',
                  placeholder: 'Couleur',
                  controller: colorCtrl,
                ),
                const SizedBox(height: 12),
                InggoInput(
                  label: "Plaque d'immatriculation",
                  placeholder: '336D91',
                  controller: plateCtrl,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annuler'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _brand = brandCtrl.text;
                            _model = modelCtrl.text;
                            _year = yearCtrl.text;
                            _color = colorCtrl.text;
                            _plate = plateCtrl.text;
                          });
                          final vehicleStr = '$_brand - $_model - $_year - $_color';
                          ref.read(driverProvider.notifier).updateVehicleInfo(vehicleStr, _plate);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC107),
                          foregroundColor: const Color(0xFF121212),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Sauvegarder',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                child: Row(
                  children: [
                    _backBtn(context),
                    const SizedBox(width: 15),
                    const Text(
                      'Mon Véhicule',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),

              // Hero image
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEEEEE),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.two_wheeler,
                          size: 80,
                          color: Color(0xFFBBBBBB),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC107),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: const Icon(
                            Icons.photo_camera,
                            size: 20,
                            color: Color(0xFF121212),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Info card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF5F5F5)),
                  ),
                  child: Column(
                    children: [
                      _infoRow('Marque', _brand),
                      _infoRow('Modèle', _model),
                      _infoRow('Année', _year),
                      _infoRow('Couleur', _color),
                      _infoRow(
                        "Plaque d'immatriculation",
                        _plate,
                        isPlate: true,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),

              // Edit button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
                child: GestureDetector(
                  onTap: _editVehicle,
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC107),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFC107).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Modifier les informations',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF121212),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value, {
    bool isPlate = false,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
          ),
          if (isPlate)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            )
          else
            Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
        ],
      ),
    );
  }

  static Widget _backBtn(BuildContext ctx) {
    return GestureDetector(
      onTap: () => Navigator.pop(ctx),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFDDDDDD)),
        ),
        child: const Icon(Icons.arrow_back, color: Color(0xFF121212), size: 20),
      ),
    );
  }
}
