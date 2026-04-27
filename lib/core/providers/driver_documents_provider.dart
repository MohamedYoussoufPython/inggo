import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_provider.dart';

class DriverDocumentModel {
  final String driverId;
  final String? cniUrl;
  final String? permisUrl;
  final String? assuranceUrl;
  final String? motoUrl;

  DriverDocumentModel({
    required this.driverId,
    this.cniUrl,
    this.permisUrl,
    this.assuranceUrl,
    this.motoUrl,
  });

  factory DriverDocumentModel.fromJson(Map<String, dynamic> json) {
    return DriverDocumentModel(
      driverId: json['driver_id'] as String,
      cniUrl: json['cni_url'] as String?,
      permisUrl: json['permis_url'] as String?,
      assuranceUrl: json['assurance_url'] as String?,
      motoUrl: json['moto_url'] as String?,
    );
  }

  /// Get a list of document entries with their name and storage path
  List<MapEntry<String, String?>> get entries => [
        MapEntry('Carte d\'Identité (CNI)', cniUrl),
        MapEntry('Permis de Conduire', permisUrl),
        MapEntry('Assurance Moto', assuranceUrl),
        MapEntry('Photo Moto', motoUrl),
      ];
}

enum DocVerificationStatus { valid, pending, error }

class DriverDocWithStatus {
  final String name;
  final String? storagePath;
  final DocVerificationStatus status;
  final String? publicUrl;

  DriverDocWithStatus({
    required this.name,
    this.storagePath,
    this.status = DocVerificationStatus.pending,
    this.publicUrl,
  });
}

final driverDocumentsProvider =
    FutureProvider<List<DriverDocWithStatus>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final user = supabase.auth.currentUser;

  if (user == null) return [];

  final data = await supabase
      .from('driver_documents')
      .select()
      .eq('driver_id', user.id)
      .maybeSingle();

  if (data == null) return [];

  final doc = DriverDocumentModel.fromJson(data);
  final results = <DriverDocWithStatus>[];

  for (final entry in doc.entries) {
    final path = entry.value;
    String? publicUrl;
    DocVerificationStatus status = DocVerificationStatus.pending;

    if (path != null && path.isNotEmpty) {
      try {
        publicUrl = supabase.storage.from('driver-docs').getPublicUrl(path);
        status = DocVerificationStatus.valid;
      } catch (_) {
        status = DocVerificationStatus.error;
      }
    } else {
      status = DocVerificationStatus.error;
    }

    results.add(DriverDocWithStatus(
      name: entry.key,
      storagePath: path,
      status: status,
      publicUrl: publicUrl,
    ));
  }

  return results;
});
