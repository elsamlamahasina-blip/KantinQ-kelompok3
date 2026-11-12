import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/menu_image_view.dart';
import '../models/menu_item_model.dart';

class MenuCustomizationSheet extends StatefulWidget {
  final MenuItemModel menuItem;
  final Function({
    required int quantity,
    required String? selectedSpicyLevel,
    required List<MenuTopping> selectedToppings,
    required String? specialNotes,
  }) onAddToCart;

  const MenuCustomizationSheet({
    super.key,
    required this.menuItem,
    required this.onAddToCart,
  });

  @override
  State<MenuCustomizationSheet> createState() => _MenuCustomizationSheetState();
}

class _MenuCustomizationSheetState extends State<MenuCustomizationSheet> {
  int _quantity = 1;
  String? _selectedSpicyLevel;
  final List<MenuTopping> _selectedToppings = [];
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final levels = widget.menuItem.availableSpicyLevels;
    if (levels.isNotEmpty) {
      _selectedSpicyLevel = levels.length > 1 ? levels[1] : levels.first;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  double get _totalPrice {
    double unit = widget.menuItem.price;
    for (final topping in _selectedToppings) {
      unit += topping.price;
    }
    return unit * _quantity;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimens.radiusXl)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Image & Close Button
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                      child: SizedBox(
                        height: 160,
                        width: double.infinity,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            MenuImageView(
                              imageUrl: widget.menuItem.imageUrl,
                              imageBytes: widget.menuItem.imageBytes,
                              fallbackIcon: Icons.restaurant_rounded,
                              fallbackIconSize: 48,
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: InkWell(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppDimens.md),

                    // Title & Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.menuItem.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.menuItem.canteenName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          CurrencyFormatter.format(widget.menuItem.price),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimens.xs),

                    // Rating & Prep Time
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.accent, size: 16),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            '${widget.menuItem.rating} (${widget.menuItem.reviewCount}+ ulasan)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                        ),
                        const SizedBox(width: AppDimens.md),
                        const Icon(Icons.timer_outlined, color: AppColors.textSecondary, size: 14),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            'Estimasi ${widget.menuItem.prepTimeMinutes} mnt',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimens.sm),
                    Text(
                      widget.menuItem.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppDimens.sm),
                      child: Divider(),
                    ),

                    // Spicy Level Option
                    if (widget.menuItem.availableSpicyLevels.isNotEmpty) ...[
                      const Text(
                        'Pilih Tingkat Kepedasan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppDimens.xs),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.menuItem.availableSpicyLevels.map((level) {
                          final isSelected = _selectedSpicyLevel == level;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedSpicyLevel = level;
                              });
                            },
                            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primaryContainer : AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.local_fire_department_rounded,
                                    size: 14,
                                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    level,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppDimens.md),
                    ],

                    // Topping Options
                    if (widget.menuItem.availableToppings.isNotEmpty) ...[
                      const Text(
                        'Tambah Topping (Opsional)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppDimens.xs),
                      Column(
                        children: widget.menuItem.availableToppings.map((topping) {
                          final isChecked = _selectedToppings.any((t) => t.name == topping.name);
                          return CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            activeColor: AppColors.primary,
                            title: Text(
                              topping.name,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              '+${CurrencyFormatter.format(topping.price)}',
                              style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                            ),
                            value: isChecked,
                            onChanged: (bool? val) {
                              setState(() {
                                if (val == true) {
                                  _selectedToppings.add(topping);
                                } else {
                                  _selectedToppings.removeWhere((t) => t.name == topping.name);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppDimens.xs),
                    ],

                    // Stock info banner
                    if (widget.menuItem.isOutOfStock)
                      Container(
                        margin: const EdgeInsets.only(bottom: AppDimens.md),
                        padding: const EdgeInsets.all(AppDimens.sm),
                        decoration: BoxDecoration(
                          color: AppColors.errorContainer,
                          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline_rounded, color: AppColors.error, size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Maaf, menu ini sedang habis dan tidak dapat dipesan saat ini.',
                                style: TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (widget.menuItem.stock <= 5)
                      Container(
                        margin: const EdgeInsets.only(bottom: AppDimens.md),
                        padding: const EdgeInsets.symmetric(horizontal: AppDimens.sm, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.warningContainer,
                          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                          border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.flash_on_rounded, color: AppColors.warning, size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Stok menipis! Hanya tersisa ${widget.menuItem.stock} porsi lagi.',
                                style: const TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Special Notes
                    AppTextField(
                      controller: _notesController,
                      label: 'Catatan Khusus Penjual (Opsional)',
                      hint: 'Contoh: Jangan pakai daun bawang, kuah dipisah...',
                      maxLines: 2,
                    ),

                    const SizedBox(height: AppDimens.md),
                  ],
                ),
              ),
            ),

            // Bottom Sticky Bar (Quantity & Add to Cart CTA)
            Container(
              padding: const EdgeInsets.all(AppDimens.md),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.outline)),
                boxShadow: [AppColors.softShadow],
              ),
              child: Row(
                children: [
                  // Quantity Counter
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_rounded, size: 18),
                          onPressed: (!widget.menuItem.isOutOfStock && _quantity > 1)
                              ? () {
                                  setState(() {
                                    _quantity--;
                                  });
                                }
                              : null,
                          color: AppColors.textPrimary,
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        ),
                        Text(
                          '${widget.menuItem.isOutOfStock ? 0 : _quantity}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_rounded, size: 18),
                          onPressed: (!widget.menuItem.isOutOfStock && _quantity < widget.menuItem.stock)
                              ? () {
                                  setState(() {
                                    _quantity++;
                                  });
                                }
                              : null,
                          color: AppColors.primary,
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: AppDimens.md),

                  // Add To Cart Button
                  Expanded(
                    child: AppButton(
                      text: widget.menuItem.isOutOfStock
                          ? 'Menu Sedang Habis'
                          : 'Tambah • ${CurrencyFormatter.format(_totalPrice)}',
                      onPressed: widget.menuItem.isOutOfStock
                          ? null
                          : () {
                              widget.onAddToCart(
                                quantity: _quantity,
                                selectedSpicyLevel: _selectedSpicyLevel,
                                selectedToppings: _selectedToppings,
                                specialNotes: _notesController.text.trim().isNotEmpty
                                    ? _notesController.text.trim()
                                    : null,
                              );
                              Navigator.pop(context);
                            },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
