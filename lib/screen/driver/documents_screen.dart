import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../provider/driver_documents_provider.dart';

class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(driverDocumentsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
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
                      'Mes Documents',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),

              // Document list
              docsAsync.when(
                data: (docs) {
                  if (docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Aucun document trouvé.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Color(0xFFF5F5F5)),
                      ),
                      child: Column(
                        children: List.generate(docs.length, (i) {
                          final doc = docs[i];
                          return _docRow(context, doc, i, docs.length);
                        }),
                      ),
                    ),
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (err, st) => Center(child: Text('Erreur: $err')),
              ),

              const SizedBox(height: 20),
              // Equipments
              const Padding(
                padding: EdgeInsets.fromLTRB(30, 0, 30, 10),
                child: Text(
                  'ÉQUIPEMENTS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF757575),
                    letterSpacing: 1,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Color(0xFFF5F5F5)),
                  ),
                  child: Column(
                    children: [
                      _equipRow('Casque Personnel', 'Propriétaire'),
                      _equipRow(
                        'Gilet Inggo & Casque Passager',
                        'Fourni par InnGroup',
                      ),
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

  // ─────────────────── Rows ───────────────────

  Widget _docRow(
    BuildContext context,
    DriverDocWithStatus doc,
    int index,
    int total,
  ) {
    return GestureDetector(
      onTap: () => _openDocDetails(context, doc),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: index < total - 1
              ? const Border(bottom: BorderSide(color: Color(0xFFF5F5F5)))
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                doc.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            _statusBadge(doc.status),
          ],
        ),
      ),
    );
  }

  static Widget _equipRow(String name, String sub) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
      ),
      child: Row(
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
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: Color(0xFF43A047), size: 22),
        ],
      ),
    );
  }

  // ─────────────────── Badge ───────────────────

  Widget _statusBadge(DocVerificationStatus status) {
    Color bg, fg;
    String label;
    switch (status) {
      case DocVerificationStatus.valid:
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF2E7D32);
        label = 'VALIDÉ';
        break;
      case DocVerificationStatus.pending:
        bg = const Color(0xFFFFF3E0);
        fg = const Color(0xFFEF6C00);
        label = 'EN ATTENTE';
        break;
      case DocVerificationStatus.error:
        bg = const Color(0xFFFFEBEE);
        fg = const Color(0xFFC62828);
        label = 'MANQUANT';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }

  // ─────────────────── Dialog ───────────────────

  void _openDocDetails(BuildContext context, DriverDocWithStatus doc) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          doc.name,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(                  color: Color(0xFFCCCCCC),
                  style: BorderStyle.solid,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              child: doc.publicUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        doc.publicUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image,
                                size: 48, color: Color(0xFFAAAAAA)),
                            SizedBox(height: 10),
                            Text('Image non disponible',
                                style: TextStyle(color: Color(0xFFAAAAAA))),
                          ],
                        ),
                      ),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image,
                            size: 48, color: Color(0xFFAAAAAA)),
                        SizedBox(height: 10),
                        Text('Aperçu du document',
                            style: TextStyle(color: Color(0xFFAAAAAA))),
                      ],
                    ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Statut',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF757575),
                  ),
                ),
                _statusBadge(doc.status),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  // ─────────────────── Back ───────────────────

  static Widget _backBtn(BuildContext ctx) {
    return GestureDetector(
      onTap: () => Navigator.pop(ctx),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Color(0xFFDDDDDD)),
        ),
        child:
            const Icon(Icons.arrow_back, color: Color(0xFF121212), size: 20),
      ),
    );
  }
}
