import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inggo/core/theme/inggo_theme.dart';
import 'package:inggo/core/providers/ride_provider.dart';
import 'package:inggo/widget/inggo_button.dart';
import 'package:inggo/widget/inggo_card.dart';

class EndOfTripScreen extends ConsumerStatefulWidget {
  final double? distance;
  final int? duration;
  final int? price;
  final String? driverName;
  final String? driverAvatar;
  final double? driverRating;
  final int? rideId;
  final String? driverUserId;

  const EndOfTripScreen({
    super.key,
    this.distance,
    this.duration,
    this.price,
    this.driverName,
    this.driverAvatar,
    this.driverRating,
    this.rideId,
    this.driverUserId,
  });

  @override
  ConsumerState<EndOfTripScreen> createState() => _EndOfTripScreenState();
}

class _EndOfTripScreenState extends ConsumerState<EndOfTripScreen> {
  int _rating = 0;
  bool _isLoading = false;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  bool get _isValid => _rating > 0;

  Future<void> _submitAndFinish() async {
    if (!_isValid) return;

    setState(() => _isLoading = true);

    try {
      if (widget.rideId != null && widget.driverUserId != null) {
        await ref.read(rideProvider.notifier).submitReview(
              rideId: widget.rideId!,
              driverUserId: widget.driverUserId!,
              rating: _rating,
              comment: _commentController.text.isNotEmpty
                  ? _commentController.text
                  : null,
            );
      }
    } catch (_) {
      // Ignore review errors, still navigate
    }

    if (mounted) {
      context.go('/booking');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: InggoColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const SizedBox.shrink(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: InggoSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: InggoSpacing.xl),
              _buildSuccessHeader(),
              const SizedBox(height: InggoSpacing.xxl),
              _buildDriverCard(),
              const SizedBox(height: InggoSpacing.lg),
              _buildSummaryCard(),
              const SizedBox(height: InggoSpacing.xl),
              _buildRatingSection(),
              const SizedBox(height: InggoSpacing.lg),
              _buildCommentSection(),
              const SizedBox(height: InggoSpacing.xxl),
              _buildSubmitButton(),
              const SizedBox(height: InggoSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: InggoColors.primary,
            shape: BoxShape.circle,
            boxShadow: InggoShadows.level4,
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 40,
            color: InggoColors.text1,
          ),
        ),
        const SizedBox(height: InggoSpacing.lg),
        Text(
          'Course terminée',
          style: InggoTextStyles.h2,
        ),
        const SizedBox(height: InggoSpacing.xs),
        Text(
          'Merci pour votre confiance',
          style: InggoTextStyles.body,
        ),
      ],
    );
  }

  Widget _buildDriverCard() {
    final driverName = widget.driverName ?? 'Chauffeur';

    return InggoCard(
      padding: const EdgeInsets.all(InggoSpacing.lg),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: InggoColors.primaryLight,
            backgroundImage: widget.driverAvatar != null
                ? NetworkImage(widget.driverAvatar!)
                : null,
            child: widget.driverAvatar == null
                ? Text(
                    driverName.isNotEmpty ? driverName[0].toUpperCase() : 'C',
                    style: InggoTextStyles.h3.copyWith(
                      color: InggoColors.primaryDark,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: InggoSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driverName,
                  style: InggoTextStyles.h3,
                ),
                const SizedBox(height: InggoSpacing.xs),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: InggoColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.driverRating?.toStringAsFixed(1) ?? '4.8',
                      style: InggoTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: InggoSpacing.md,
              vertical: InggoSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: InggoColors.successLight,
              borderRadius: BorderRadius.circular(InggoSpacing.xs),
            ),
            child: Text(
              'Terminé',
              style: InggoTextStyles.caption.copyWith(
                color: InggoColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(InggoSpacing.lg),
      decoration: BoxDecoration(
        color: InggoColors.surface,
        borderRadius: BorderRadius.circular(InggoSpacing.md),
        border: Border.all(color: InggoColors.border1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.straighten_rounded,
                  value: widget.distance?.toStringAsFixed(1) ?? '--',
                  unit: 'km',
                  label: 'Distance',
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: InggoColors.border1,
              ),
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.timer_outlined,
                  value: widget.duration?.toString() ?? '--',
                  unit: 'min',
                  label: 'Durée',
                ),
              ),
            ],
          ),
          const SizedBox(height: InggoSpacing.md),
          const Divider(color: InggoColors.border1),
          const SizedBox(height: InggoSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Prix total',
                style: InggoTextStyles.body,
              ),
              Text(
                '${widget.price ?? 250} FDJ',
                style: InggoTextStyles.h3.copyWith(
                  color: InggoColors.primaryDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String value,
    required String unit,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: InggoColors.text3,
        ),
        const SizedBox(height: InggoSpacing.sm),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: InggoTextStyles.h3,
              ),
              TextSpan(
                text: ' $unit',
                style: InggoTextStyles.caption,
              ),
            ],
          ),
        ),
        const SizedBox(height: InggoSpacing.xs),
        Text(
          label,
          style: InggoTextStyles.caption,
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Column(
      children: [
        Text(
          'Évaluez votre chauffeur',
          style: InggoTextStyles.h3,
        ),
        const SizedBox(height: InggoSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starIndex = index + 1;
            return GestureDetector(
              onTap: () => setState(() => _rating = starIndex),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(InggoSpacing.sm),
                child: Icon(
                  starIndex <= _rating
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: starIndex <= _rating
                      ? InggoColors.warning
                      : InggoColors.border2,
                  size: 36,
                ),
              ),
            );
          }),
        ),
        if (!_isValid)
          Padding(
            padding: const EdgeInsets.only(top: InggoSpacing.sm),
            child: Text(
              'Cliquez sur une étoile pour noter',
              style: InggoTextStyles.caption.copyWith(
                color: InggoColors.text3,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCommentSection() {
    return Container(
      decoration: BoxDecoration(
        color: InggoColors.surface,
        borderRadius: BorderRadius.circular(InggoSpacing.sm),
        border: Border.all(color: InggoColors.border1),
      ),
      child: TextFormField(
        controller: _commentController,
        maxLines: 3,
        style: InggoTextStyles.body.copyWith(color: InggoColors.text1),
        decoration: InputDecoration(
          hintText: 'Votre commentaire (optionnel)',
          hintStyle: InggoTextStyles.body.copyWith(color: InggoColors.text3),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(InggoSpacing.lg),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return InggoButton(
      label: 'Terminer',
      onPressed: _isValid && !_isLoading ? _submitAndFinish : null,
      isLoading: _isLoading,
      icon: _isLoading ? null : Icons.check_rounded,
    );
  }
}
