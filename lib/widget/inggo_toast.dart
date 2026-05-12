import 'package:flutter/material.dart';
import '../core/constants/constants.dart';

class InggoToast {
  InggoToast._();

  // --- BuildContext API (use in sync code only) ---

  static void show(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: AppColors.textWhite,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textWhite)),
            ),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void error(BuildContext context, String message) =>
      show(context, message, isError: true);

  static void success(BuildContext context, String message) =>
      show(context, message);

  static void info(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.textWhite, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textWhite)),
            ),
          ],
        ),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // --- ScaffoldMessengerState API (use after async gaps) ---
  // Capture ScaffoldMessenger.of(context) BEFORE the first await, then
  // call these methods after the gap.  This eliminates
  // use_build_context_synchronously warnings.

  static void showMessenger(
      ScaffoldMessengerState messenger, String message,
      {bool isError = false}) {
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: AppColors.textWhite,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textWhite)),
            ),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void successMessenger(
          ScaffoldMessengerState messenger, String message) =>
      showMessenger(messenger, message);

  static void errorMessenger(
          ScaffoldMessengerState messenger, String message) =>
      showMessenger(messenger, message, isError: true);
}
