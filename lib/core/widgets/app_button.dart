import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';

enum AppButtonVariant { primary, secondary, outline, danger }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final Widget? icon;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.width,
    this.height = AppDimens.buttonHeightMd,
  });

  @override
  Widget build(BuildContext context) {
    Color getBackgroundColor() {
      if (onPressed == null || isLoading) {
        return AppColors.outlineVariant;
      }
      switch (variant) {
        case AppButtonVariant.primary:
          return AppColors.primary;
        case AppButtonVariant.secondary:
          return AppColors.secondary;
        case AppButtonVariant.outline:
          return Colors.transparent;
        case AppButtonVariant.danger:
          return AppColors.error;
      }
    }

    Color getTextColor() {
      if (onPressed == null || isLoading) {
        return AppColors.textMuted;
      }
      switch (variant) {
        case AppButtonVariant.primary:
        case AppButtonVariant.secondary:
        case AppButtonVariant.danger:
          return Colors.white;
        case AppButtonVariant.outline:
          return AppColors.primary;
      }
    }

    BorderSide getBorderSide() {
      if (variant == AppButtonVariant.outline) {
        return BorderSide(
          color: (onPressed == null || isLoading)
              ? AppColors.outlineVariant
              : AppColors.primary,
          width: 1.5,
        );
      }
      return BorderSide.none;
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: (isLoading || onPressed == null) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: getBackgroundColor(),
          foregroundColor: getTextColor(),
          disabledBackgroundColor: AppColors.surfaceVariant,
          disabledForegroundColor: AppColors.textMuted,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            side: getBorderSide(),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(getTextColor()),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: AppDimens.xs),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      style: TextStyle(
                        color: getTextColor(),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
