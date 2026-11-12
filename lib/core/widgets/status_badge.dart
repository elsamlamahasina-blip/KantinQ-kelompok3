import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';

enum OrderStatusType {
  waiting,
  cooking,
  ready,
  completed,
  canceled,
}

class StatusBadge extends StatelessWidget {
  final OrderStatusType status;
  final String? customLabel;

  const StatusBadge({
    super.key,
    required this.status,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;
    String label;

    switch (status) {
      case OrderStatusType.waiting:
        bg = AppColors.infoContainer;
        fg = AppColors.info;
        icon = Icons.access_time_filled_rounded;
        label = 'Menunggu';
        break;
      case OrderStatusType.cooking:
        bg = AppColors.warningContainer;
        fg = AppColors.warning;
        icon = Icons.soup_kitchen_rounded;
        label = 'Sedang Dimasak';
        break;
      case OrderStatusType.ready:
        bg = AppColors.secondaryContainer;
        fg = AppColors.secondary;
        icon = Icons.check_circle_rounded;
        label = 'Siap Diambil';
        break;
      case OrderStatusType.completed:
        bg = AppColors.successContainer;
        fg = AppColors.success;
        icon = Icons.task_alt_rounded;
        label = 'Selesai';
        break;
      case OrderStatusType.canceled:
        bg = AppColors.errorContainer;
        fg = AppColors.error;
        icon = Icons.cancel_rounded;
        label = 'Dibatalkan';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.sm,
        vertical: AppDimens.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: AppDimens.xxs),
          Text(
            customLabel ?? label,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
