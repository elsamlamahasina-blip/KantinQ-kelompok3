import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Shared image renderer supporting uploaded in-memory bytes, base64 data URIs,
/// and network URLs with uniform loading and fallback visuals.
class MenuImageView extends StatelessWidget {
  final String imageUrl;
  final Uint8List? imageBytes;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData fallbackIcon;
  final double fallbackIconSize;

  const MenuImageView({
    super.key,
    required this.imageUrl,
    this.imageBytes,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.fastfood_rounded,
    this.fallbackIconSize = 36,
  });

  @override
  Widget build(BuildContext context) {
    final bytes = imageBytes;
    if (bytes != null && bytes.isNotEmpty) {
      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => _buildFallback(),
      );
    }

    final trimmed = imageUrl.trim();
    if (trimmed.isEmpty) {
      return _buildFallback();
    }

    if (trimmed.startsWith('data:image')) {
      final commaIndex = trimmed.indexOf(',');
      if (commaIndex != -1) {
        try {
          final decoded = base64Decode(trimmed.substring(commaIndex + 1));
          return Image.memory(
            decoded,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, _, _) => _buildFallback(),
          );
        } catch (_) {
          return _buildFallback();
        }
      }
    }

    return Image.network(
      trimmed,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) => _buildFallback(),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          width: width,
          height: height,
          color: AppColors.surfaceVariant,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      color: AppColors.primaryContainer,
      alignment: Alignment.center,
      child: Icon(
        fallbackIcon,
        size: fallbackIconSize,
        color: AppColors.primary,
      ),
    );
  }
}

