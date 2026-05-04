import 'package:flutter/material.dart';

class PaymentMethodCard extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onConfirm;

  const PaymentMethodCard({
    super.key,
    required this.onBack,
    required this.onConfirm,
  });

  @override
  State<PaymentMethodCard> createState() => _PaymentMethodCardState();
}

class _PaymentMethodCardState extends State<PaymentMethodCard> {
  String selectedMethod = 'Cash';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final padding = MediaQuery.of(context).padding;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        width * 0.05,
        size.height * 0.02,
        width * 0.05,
        padding.bottom + size.height * 0.02,
      ),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: width * 0.10,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E8E8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header avec bouton retour
            Row(
              children: [
                GestureDetector(
                  onTap: widget.onBack,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(10),
                      border: const Border.all(                        color: const Color(0xFFE8E8E8),
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Payment Method',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Options de paiement horizontales
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  _PaymentOption(
                    title: 'Cash',
                    icon: const Icon(
                      Icons.payments_outlined,
                      color: Color(0xFF1A1A1A),
                      size: 28,
                    ),
                    isSelected: selectedMethod == 'Cash',
                    onTap: () => setState(() => selectedMethod = 'Cash'),
                  ),
                  const SizedBox(width: 16),
                  _PaymentOption(
                    title: 'Waafi',
                    icon: const Text(
                      'WF',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    isSelected: selectedMethod == 'Waafi',
                    onTap: () => setState(() => selectedMethod = 'Waafi'),
                  ),
                  const SizedBox(width: 16),
                  _PaymentOption(
                    title: 'D-Money',
                    icon: const Icon(
                      Icons.smartphone_rounded,
                      color: Color(0xFF1A1A1A),
                      size: 28,
                    ),
                    isSelected: selectedMethod == 'D-Money',
                    onTap: () => setState(() => selectedMethod = 'D-Money'),
                  ),
                  const SizedBox(width: 16),
                  _PaymentOption(
                    title: 'Cac Pay',
                    icon: const Text(
                      'Cac',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    isSelected: selectedMethod == 'Cac Pay',
                    onTap: () => setState(() => selectedMethod = 'Cac Pay'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Bouton Confirm
            GestureDetector(
              onTap: widget.onConfirm,
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC700),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFC700).withValues(alpha: 0.30),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Confirm & Book',
                    style: TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  Payment Option
// ─────────────────────────────────────────

class _PaymentOption extends StatelessWidget {
  final String title;
  final Widget icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 90,
        height: 90,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF8E1) : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                isSelected ? const Color(0xFFFFC700) : const Color(0xFFE8E8E8),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: const Border.all(color: Color(0xFFE8E8E8)),
              ),
              child: icon,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 12,
                color: isSelected
                    ? const Color(0xFF1A1A1A)
                    : const Color(0xFF555555),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
