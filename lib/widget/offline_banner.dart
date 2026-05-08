import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/constants/constants.dart';

class OfflineBanner extends StatelessWidget {
  final bool isOnline;
  const OfflineBanner({super.key, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    if (isOnline) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      color: AppColors.error,
      child: Row(
        children: [
          Icon(Icons.wifi_off, color: AppColors.textWhite, size: 18.w),
          SizedBox(width: 8.w),
          Expanded(
            child: Text('Pas de connexion internet',
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.textWhite)),
          ),
        ],
      ),
    );
  }
}
