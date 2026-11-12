import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/state/app_state.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_button.dart';

class TopUpSheet extends StatefulWidget {
  const TopUpSheet({super.key});

  @override
  State<TopUpSheet> createState() => _TopUpSheetState();
}

class _TopUpSheetState extends State<TopUpSheet> {
  double _selectedAmount = 50000;
  String _selectedMethod = 'BCA Virtual Account';
  bool _isProcessing = false;

  final List<double> _nominalOptions = [10000, 20000, 50000, 100000, 200000];

  final List<Map<String, dynamic>> _methods = [
    {
      'name': 'BCA Virtual Account',
      'icon': Icons.account_balance_rounded,
      'fee': 'Gratis',
    },
    {
      'name': 'Mandiri Virtual Account',
      'icon': Icons.account_balance_rounded,
      'fee': 'Gratis',
    },
    {
      'name': 'Kasir Utama Kantin',
      'icon': Icons.storefront_rounded,
      'fee': 'Bayar tunai di kasir',
    },
  ];

  Future<void> _submitTopUp() async {
    setState(() {
      _isProcessing = true;
    });

    final wallet = AppState.instance.walletController;
    await wallet.topUp(
      amount: _selectedAmount,
      paymentMethod: _selectedMethod,
    );

    if (!mounted) return;
    setState(() {
      _isProcessing = false;
    });

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Top Up ${CurrencyFormatter.format(_selectedAmount)} berhasil!'),
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusXl)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Isi Saldo KantinQ Pay',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: AppDimens.sm),

              const Text(
                'Pilih Nominal Top Up',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppDimens.xs),

              // Nominal Options Grid
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _nominalOptions.map((amount) {
                  final isSelected = _selectedAmount == amount;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedAmount = amount;
                      });
                    },
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryContainer : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        CurrencyFormatter.format(amount),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppDimens.md),

              const Text(
                'Metode Pembayaran Top Up',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppDimens.xs),

              // Payment Methods
              ..._methods.map((method) {
                final isSelected = _selectedMethod == method['name'];
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedMethod = method['name'] as String;
                    });
                  },
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(AppDimens.sm),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.outline,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(method['icon'] as IconData, color: AppColors.primary, size: 22),
                        const SizedBox(width: AppDimens.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                method['name'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                method['fee'] as String,
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.outline,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? const Center(child: Icon(Icons.circle, size: 8, color: Colors.white))
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: AppDimens.lg),

              AppButton(
                text: 'Konfirmasi Top Up • ${CurrencyFormatter.format(_selectedAmount)}',
                isLoading: _isProcessing,
                onPressed: _submitTopUp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
