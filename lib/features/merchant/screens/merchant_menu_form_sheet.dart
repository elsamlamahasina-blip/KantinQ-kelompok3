import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/state/app_state.dart';
import '../../../core/utils/image_picker_helper.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/menu_image_view.dart';
import '../../canteen/models/menu_item_model.dart';

class MerchantMenuFormSheet extends StatefulWidget {
  final String canteenId;
  final String canteenName;
  final MenuItemModel? itemToEdit;

  const MerchantMenuFormSheet({
    super.key,
    required this.canteenId,
    required this.canteenName,
    this.itemToEdit,
  });

  @override
  State<MerchantMenuFormSheet> createState() => _MerchantMenuFormSheetState();
}

class _MerchantMenuFormSheetState extends State<MerchantMenuFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _prepTimeController;
  late final TextEditingController _descController;
  late final TextEditingController _imageUrlController;
  late String _selectedCategory;
  late String _imageUrl;
  Uint8List? _imageBytes;
  String? _pickedFileName;
  bool _clearImageBytes = false;
  bool _showUrlField = false;

  final List<String> _categories = [
    'Nasi & Lauk',
    'Mie & Bakso',
    'Dimsum & Snack',
    'Snack & Cemilan',
    'Minuman',
    'Paket Hemat',
  ];

  final List<String> _presetImages = [
    'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1603133872878-684f208fb84b?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1572656631137-7935297eff55?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1585032226651-759b368d7246?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1515823064-d6e0c04616a7?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1517256064527-09c73fc73e38?auto=format&fit=crop&w=600&q=80',
  ];

  @override
  void initState() {
    super.initState();
    final item = widget.itemToEdit;
    _nameController = TextEditingController(text: item?.name ?? '');
    _priceController = TextEditingController(text: item != null ? item.price.toInt().toString() : '15000');
    _stockController = TextEditingController(text: item != null ? item.stock.toString() : '20');
    _prepTimeController = TextEditingController(text: item != null ? item.prepTimeMinutes.toString() : '8');
    _descController = TextEditingController(text: item?.description ?? '');
    _selectedCategory = item?.category ?? _categories.first;
    if (!_categories.contains(_selectedCategory)) {
      _categories.add(_selectedCategory);
    }
    _imageUrl = item?.imageUrl ?? _presetImages.first;
    _imageBytes = item?.imageBytes;
    _imageUrlController = TextEditingController(text: _imageUrl);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _prepTimeController.dispose();
    _descController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _onPickDeviceImage() async {
    if (!isDeviceImagePickerSupported) {
      setState(() {
        _showUrlField = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pilih foto dari galeri preset atau tempel URL gambar di bawah ini.'),
          ),
        );
      }
      return;
    }

    final picked = await pickImageBytes();
    if (!mounted || picked == null) return;

    setState(() {
      _imageBytes = picked.bytes;
      _pickedFileName = picked.name;
      _clearImageBytes = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gambar "${picked.name}" berhasil ditambahkan!'),
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final hasBytes = _imageBytes != null && _imageBytes!.isNotEmpty;
      final cleanUrl = _imageUrlController.text.trim();
      if (!hasBytes && cleanUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tambahkan gambar menu terlebih dahulu (upload foto atau pilih galeri).'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      final canteenCtrl = AppState.instance.canteenController;
      final price = double.tryParse(_priceController.text.trim()) ?? 15000;
      final stock = int.tryParse(_stockController.text.trim()) ?? 20;
      final prepTime = int.tryParse(_prepTimeController.text.trim()) ?? 8;
      final finalUrl = cleanUrl.isNotEmpty ? cleanUrl : _imageUrl;

      if (widget.itemToEdit != null) {
        // Edit existing menu
        final updated = widget.itemToEdit!.copyWith(
          name: _nameController.text.trim(),
          category: _selectedCategory,
          price: price,
          stock: stock,
          isAvailable: stock > 0,
          prepTimeMinutes: prepTime,
          description: _descController.text.trim(),
          imageUrl: finalUrl,
          imageBytes: _imageBytes,
          clearImageBytes: _clearImageBytes && _imageBytes == null,
        );
        canteenCtrl.updateMenuItem(updated);
      } else {
        // Add new menu
        final newItem = MenuItemModel(
          id: 'menu_${DateTime.now().millisecondsSinceEpoch}',
          canteenId: widget.canteenId,
          canteenName: widget.canteenName,
          name: _nameController.text.trim(),
          category: _selectedCategory,
          price: price,
          stock: stock,
          isAvailable: stock > 0,
          prepTimeMinutes: prepTime,
          description: _descController.text.trim(),
          imageUrl: finalUrl,
          imageBytes: _imageBytes,
        );
        canteenCtrl.addMenuItem(newItem);
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.itemToEdit != null
              ? 'Menu "${_nameController.text}" berhasil diperbarui!'
              : 'Menu baru berhasil ditambahkan ke katalog stan!'),
          backgroundColor: AppColors.secondary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.itemToEdit != null;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusXl)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.lg),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          isEditing ? 'Ubah Data Menu' : 'Tambah Menu Baru',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: AppDimens.xs),

                  // Menu Name
                  AppTextField(
                    controller: _nameController,
                    label: 'Nama Makanan / Minuman',
                    hint: 'Contoh: Nasi Goreng Spesial',
                    validator: (val) => val == null || val.trim().isEmpty ? 'Nama menu wajib diisi' : null,
                  ),
                  const SizedBox(height: AppDimens.sm),

                  // Category Selector
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kategori Menu',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _categories.map((cat) {
                          final isSelected = _selectedCategory == cat;
                          return ChoiceChip(
                            label: Text(cat, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : AppColors.textPrimary)),
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.surfaceVariant,
                            onSelected: (_) {
                              setState(() {
                                _selectedCategory = cat;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.sm),

                  // Price & Stock row
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _priceController,
                          label: 'Harga (Rp)',
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Icons.payments_outlined, size: 18),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Harga wajib';
                            if (double.tryParse(val) == null) return 'Angka tidak valid';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: AppDimens.sm),
                      Expanded(
                        child: AppTextField(
                          controller: _stockController,
                          label: 'Stok Porsi',
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Icons.inventory_2_outlined, size: 18),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Stok wajib';
                            if (int.tryParse(val) == null) return 'Angka tidak valid';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.sm),

                  // Prep Time
                  AppTextField(
                    controller: _prepTimeController,
                    label: 'Perkiraan Waktu Memasak (Menit)',
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.timer_outlined, size: 18),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Waktu wajib';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimens.sm),

                  // Description
                  AppTextField(
                    controller: _descController,
                    label: 'Deskripsi Singkat',
                    hint: 'Jelaskan bahan dan rasa hidangan...',
                    maxLines: 2,
                  ),
                  const SizedBox(height: AppDimens.sm),

                  // Image Selection & "+ Tambah Gambar" Feature
                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        const Text(
                          'Foto Makanan / Menu:',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _showUrlField = !_showUrlField;
                            });
                          },
                          icon: Icon(
                            _showUrlField ? Icons.keyboard_arrow_up_rounded : Icons.link_rounded,
                            size: 16,
                          ),
                          label: Text(
                            _showUrlField ? 'Tutup URL' : 'Tempel URL Gambar',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    child: SizedBox(
                      height: 140,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          MenuImageView(
                            imageUrl: _imageUrl,
                            imageBytes: _imageBytes,
                            fallbackIcon: Icons.add_photo_alternate_rounded,
                            fallbackIconSize: 42,
                          ),
                          Positioned(
                            left: 8,
                            bottom: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _imageBytes != null
                                    ? 'Upload Lokal${_pickedFileName != null ? ': $_pickedFileName' : ''}'
                                    : 'Pratinjau Gambar Menu',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 8,
                            bottom: 8,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_imageBytes != null)
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _imageBytes = null;
                                        _pickedFileName = null;
                                        _clearImageBytes = true;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 6),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: AppColors.error,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Reset',
                                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                InkWell(
                                  onTap: _onPickDeviceImage,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.add_a_photo_rounded, color: Colors.white, size: 13),
                                        SizedBox(width: 4),
                                        Text(
                                          '+ Tambah Gambar',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_showUrlField) ...[
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: _imageUrlController,
                      label: 'URL Gambar Menu (https://...)',
                      hint: 'https://images.unsplash.com/photo-...',
                      prefixIcon: const Icon(Icons.image_outlined, size: 18),
                      onChanged: (val) {
                        setState(() {
                          _imageUrl = val.trim();
                          _imageBytes = null;
                          _clearImageBytes = true;
                        });
                      },
                    ),
                  ],
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 68,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _presetImages.length + 1,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, idx) {
                        if (idx == 0) {
                          return InkWell(
                            onTap: _onPickDeviceImage,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 72,
                              height: 68,
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate_rounded, color: AppColors.primary, size: 22),
                                  SizedBox(height: 2),
                                  Text(
                                    'Tambah\nGambar',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryDark,
                                      height: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final img = _presetImages[idx - 1];
                        final isSelected = _imageBytes == null && _imageUrl == img;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _imageUrl = img;
                              _imageUrlController.text = img;
                              _imageBytes = null;
                              _pickedFileName = null;
                              _clearImageBytes = true;
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.outline,
                                width: isSelected ? 2.5 : 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: MenuImageView(
                                imageUrl: img,
                                width: 68,
                                height: 68,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: AppDimens.lg),

                  // Save Button
                  AppButton(
                    text: isEditing ? 'Simpan Perubahan Menu' : 'Tambahkan ke Katalog Stan',
                    icon: const Icon(Icons.check_rounded, size: 18),
                    onPressed: _onSave,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
