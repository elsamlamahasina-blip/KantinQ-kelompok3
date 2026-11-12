import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/state/app_state.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../voucher/models/voucher_model.dart';

class MerchantVoucherFormSheet extends StatefulWidget {
  final String canteenId;
  final String canteenName;
  final VoucherModel? voucherToEdit;

  const MerchantVoucherFormSheet({
    super.key,
    required this.canteenId,
    required this.canteenName,
    this.voucherToEdit,
  });

  @override
  State<MerchantVoucherFormSheet> createState() => _MerchantVoucherFormSheetState();
}

class _MerchantVoucherFormSheetState extends State<MerchantVoucherFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  late final TextEditingController _titleController;
  late final TextEditingController _discountController;
  late final TextEditingController _minPurchaseController;
  late final TextEditingController _quotaController;
  late final TextEditingController _descController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final v = widget.voucherToEdit;
    _codeController = TextEditingController(text: v?.code ?? '');
    _titleController = TextEditingController(text: v?.title ?? '');
    _discountController = TextEditingController(
      text: v != null ? v.discountAmount.toInt().toString() : '5000',
    );
    _minPurchaseController = TextEditingController(
      text: v != null ? v.minPurchase.toInt().toString() : '15000',
    );
    _quotaController = TextEditingController(
      text: v != null ? v.quota.toString() : '50',
    );
    _descController = TextEditingController(text: v?.description ?? '');
    _isActive = v?.isActive ?? true;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _discountController.dispose();
    _minPurchaseController.dispose();
    _quotaController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final voucherCtrl = AppState.instance.voucherController;
    final cleanCode = _codeController.text.trim().toUpperCase().replaceAll(' ', '');
    final title = _titleController.text.trim();
    final discount = double.parse(_discountController.text.trim());
    final minPurchase = double.tryParse(_minPurchaseController.text.trim()) ?? 0;
    final quota = int.parse(_quotaController.text.trim());

    final customDesc = _descController.text.trim();
    final description = customDesc.isNotEmpty
        ? customDesc
        : 'Potongan ${CurrencyFormatter.format(discount)} di ${widget.canteenName}${minPurchase > 0 ? ' min. belanja ${CurrencyFormatter.format(minPurchase)}' : ''}.';

    final ({bool success, String message}) result;
    if (widget.voucherToEdit != null) {
      final updated = widget.voucherToEdit!.copyWith(
        code: cleanCode,
        title: title,
        description: description,
        discountAmount: discount,
        minPurchase: minPurchase,
        quota: quota,
        isActive: _isActive,
      );
      result = voucherCtrl.updateVoucher(updated);
    } else {
      final created = VoucherModel(
        id: 'v_${widget.canteenId}_${DateTime.now().millisecondsSinceEpoch}',
        code: cleanCode,
        title: title,
        description: description,
        canteenId: widget.canteenId,
        canteenName: widget.canteenName,
        discountAmount: discount,
        minPurchase: minPurchase,
        quota: quota,
        isActive: _isActive,
      );
      result = voucherCtrl.addVoucher(created);
    }

    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.voucherToEdit != null;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Material(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            clipBehavior: Clip.antiAlias,
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
                          isEditing ? 'Ubah Promo Voucher' : 'Buat Voucher Promo Stan',
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
                  AppTextField(
                    controller: _codeController,
                    label: 'Kode Voucher (Huruf/Angka tanpa spasi)',
                    hint: 'Contoh: HEMAT5RB',
                    prefixIcon: const Icon(Icons.confirmation_number_outlined, size: 18),
                    validator: (val) {
                      final cleaned = (val ?? '').trim().replaceAll(' ', '');
                      if (cleaned.length < 3) {
                        return 'Kode minimal 3 karakter';
                      }
                      if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(cleaned)) {
                        return 'Hanya huruf, angka, _ atau -';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimens.sm),
                  AppTextField(
                    controller: _titleController,
                    label: 'Nama Program Promo',
                    hint: 'Contoh: Diskon Istirahat Siang',
                    validator: (val) =>
                        val == null || val.trim().isEmpty ? 'Nama promo wajib diisi' : null,
                  ),
                  const SizedBox(height: AppDimens.sm),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _discountController,
                          label: 'Potongan (Rp)',
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            final parsed = double.tryParse((val ?? '').trim());
                            if (parsed == null || parsed < 1000) {
                              return 'Min. Rp 1.000';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: AppDimens.sm),
                      Expanded(
                        child: AppTextField(
                          controller: _minPurchaseController,
                          label: 'Min. Belanja (Rp)',
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            final parsed = double.tryParse((val ?? '').trim());
                            if (parsed == null || parsed < 0) {
                              return 'Tidak valid';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.sm),
                  AppTextField(
                    controller: _quotaController,
                    label: 'Kuota Pemakaian',
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.groups_outlined, size: 18),
                    validator: (val) {
                      final parsed = int.tryParse((val ?? '').trim());
                      final usedCount = widget.voucherToEdit?.usedCount ?? 0;
                      if (parsed == null || parsed < 1) {
                        return 'Minimal kuota 1';
                      }
                      if (parsed < usedCount) {
                        return 'Minimal $usedCount (sudah terpakai)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimens.sm),
                  AppTextField(
                    controller: _descController,
                    label: 'Keterangan Promo (Opsional)',
                    hint: 'Otomatis dibuat jika dikosongkan...',
                    maxLines: 2,
                  ),
                  const SizedBox(height: AppDimens.xs),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    activeTrackColor: AppColors.primary,
                    title: const Text(
                      'Aktifkan Voucher Untuk Pembeli',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    value: _isActive,
                    onChanged: (val) {
                      setState(() {
                        _isActive = val;
                      });
                    },
                  ),
                  const SizedBox(height: AppDimens.sm),
                  AppButton(
                    text: isEditing ? 'Simpan Perubahan Voucher' : 'Terbitkan Voucher Stan',
                    icon: const Icon(Icons.local_offer_rounded, size: 18),
                    onPressed: _onSave,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          ),
        ),
      ),
    );
  }
}

