import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';

class CategorySelector extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Nasi & Lauk':
        return Icons.lunch_dining_rounded;
      case 'Mie & Bakso':
        return Icons.ramen_dining_rounded;
      case 'Dimsum & Snack':
        return Icons.set_meal_rounded;
      case 'Minuman':
        return Icons.local_cafe_rounded;
      case 'Snack & Cemilan':
        return Icons.bakery_dining_rounded;
      case 'Paket Hemat':
        return Icons.savings_rounded;
      default:
        return Icons.restaurant_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppDimens.xs),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;

          return InkWell(
            onTap: () => onCategorySelected(category),
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.md,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.outline,
                  width: 1,
                ),
                boxShadow: isSelected ? const [AppColors.softShadow] : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getCategoryIcon(category),
                    size: 15,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
