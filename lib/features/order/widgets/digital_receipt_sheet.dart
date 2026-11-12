import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/ticket_shape_clipper.dart';
import '../models/order_model.dart';

class DigitalReceiptSheet extends StatelessWidget {
  final OrderModel order;

  const DigitalReceiptSheet({
    super.key,
    required this.order,
  });

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
              // Header
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
                      'Struk Transaksi Digital',
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
              const SizedBox(height: AppDimens.xs),

              // Canteen & ID
              Text(
                order.canteenName,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'No. Pesanan: ${order.id}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              Text(
                'Waktu: ${DateFormatter.formatDateTime(order.createdAt)}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              Text(
                'Tipe: ${order.orderTypeLabel} ${order.tableNumber != null ? "(${order.tableNumber})" : ""}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              Text(
                'Metode Bayar: ${order.paymentMethod}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),

              const SizedBox(height: AppDimens.md),
              SizedBox(
                height: 1,
                width: double.infinity,
                child: CustomPaint(
                  painter: DashedLinePainter(color: AppColors.outlineVariant),
                ),
              ),
              const SizedBox(height: AppDimens.md),

              // Items
              ...order.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.quantity}x',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.menuItem.name,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            if (item.selectedSpicyLevel != null)
                              Text(item.selectedSpicyLevel!, style: const TextStyle(fontSize: 10, color: AppColors.warning)),
                            if (item.selectedToppings.isNotEmpty)
                              Text('+ ${item.selectedToppings.map((t) => t.name).join(", ")}',
                                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(item.totalPrice),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: AppDimens.sm),
              SizedBox(
                height: 1,
                width: double.infinity,
                child: CustomPaint(
                  painter: DashedLinePainter(color: AppColors.outlineVariant),
                ),
              ),
              const SizedBox(height: AppDimens.md),

              // Price breakdown
              _ReceiptRow(label: 'Subtotal', value: CurrencyFormatter.format(order.subtotal)),
              const SizedBox(height: 4),
              _ReceiptRow(label: 'Biaya Layanan', value: CurrencyFormatter.format(order.serviceFee)),
              if (order.discountAmount > 0) ...[
                const SizedBox(height: 4),
                _ReceiptRow(
                  label: 'Diskon Promo',
                  value: '-${CurrencyFormatter.format(order.discountAmount)}',
                  valueColor: AppColors.secondary,
                ),
              ],
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(),
              ),
              _ReceiptRow(
                label: 'Total Tagihan',
                value: CurrencyFormatter.format(order.totalAmount),
                isTotal: true,
              ),

              const SizedBox(height: AppDimens.lg),

              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.successContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, color: AppColors.success, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'LUNAS & TERVERIFIKASI',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimens.lg),

              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Bagikan',
                      variant: AppButtonVariant.outline,
                      icon: const Icon(Icons.share_rounded, size: 16),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Struk transaksi berhasil disiapkan untuk dibagikan (WhatsApp / Simpan Gambar).'),
                            backgroundColor: AppColors.secondary,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: AppDimens.sm),
                  Expanded(
                    child: AppButton(
                      text: 'Tutup Struk',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isTotal;

  const _ReceiptRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isTotal ? 14 : 12,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: AppDimens.sm),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: isTotal ? 15 : 12,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? (isTotal ? AppColors.primary : AppColors.textPrimary),
            ),
          ),
        ),
      ],
    );
  }
}
