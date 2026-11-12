import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/state/app_state.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/status_badge.dart';
import '../../order/models/order_model.dart';

class MerchantOrderDetailSheet extends StatelessWidget {
  final OrderModel order;

  const MerchantOrderDetailSheet({
    super.key,
    required this.order,
  });

  void _showCancelDialog(BuildContext context) {
    String selectedReason = 'Bahan baku habis mendadak';
    final reasons = [
      'Bahan baku habis mendadak',
      'Stan sedang overload antrean',
      'Stan tutup lebih awal',
      'Permintaan khusus tidak dapat dipenuhi',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tolak / Batalkan Pesanan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pilih alasan pembatalan untuk pesanan ${order.queueNumber}:', style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 8),
              ...reasons.map((r) => InkWell(
                    onTap: () => setState(() => selectedReason = r),
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                      child: Row(
                        children: [
                          Icon(
                            selectedReason == r ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: selectedReason == r ? AppColors.primary : AppColors.textMuted,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(r, style: const TextStyle(fontSize: 12))),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final orderCtrl = AppState.instance.orderController;
                final canteenCtrl = AppState.instance.canteenController;

                orderCtrl.cancelOrder(order.id, reason: selectedReason, bySeller: true);
                canteenCtrl.restoreStockForOrder(order.items);

                Navigator.pop(ctx); // Close dialog
                Navigator.pop(context); // Close sheet
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Pesanan ${order.queueNumber} telah dibatalkan.'),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Batalkan Pesanan'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmMarkReady(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Makanan Siap?'),
        content: Text(
          'Apakah seluruh menu untuk ${order.queueNumber} telah selesai dimasak dan siap di etalase pengambilan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Belum'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Siap Diambil'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      AppState.instance.orderController.updateOrderStatus(order.id, OrderStatusType.ready);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pesanan ${order.queueNumber} siap diambil pembeli!'),
          backgroundColor: AppColors.secondary,
        ),
      );
    }
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
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.queueNumber,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          'Waktu: ${DateFormatter.formatDateTime(order.createdAt)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimens.xs),
                  StatusBadge(status: order.status),
                ],
              ),

              const Divider(height: 24),

              // Customer Details
              Container(
                padding: const EdgeInsets.all(AppDimens.sm),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person_rounded, size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            order.customerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            order.customerPhone,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.room_service_outlined, size: 16, color: AppColors.secondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${order.orderTypeLabel} ${order.tableNumber != null ? "(${order.tableNumber})" : ""}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                    if (order.notes != null && order.notes!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.warningContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Catatan Pesanan: "${order.notes}"',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.warning),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: AppDimens.md),

              const Text(
                'Rincian Menu Pesanan:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Items List
              ...order.items.map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(AppDimens.sm),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${item.quantity}x',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.menuItem.name,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            if (item.selectedSpicyLevel != null)
                              Text('• Level: ${item.selectedSpicyLevel}', style: const TextStyle(fontSize: 11, color: AppColors.primary)),
                            if (item.selectedToppings.isNotEmpty)
                              Text('• Topping: ${item.selectedToppings.map((t) => t.name).join(", ")}', style: const TextStyle(fontSize: 11, color: AppColors.secondary)),
                            if (item.specialNotes != null && item.specialNotes!.isNotEmpty)
                              Text('• Catatan: "${item.specialNotes}"', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.warning)),
                          ],
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(item.totalPrice),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: AppDimens.sm),

              // Total & Payment
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Metode Bayar: ${order.paymentMethod}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(width: AppDimens.sm),
                  Flexible(
                    child: Text(
                      'Total: ${CurrencyFormatter.format(order.totalAmount)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimens.lg),

              // Action Buttons Based on Status
              if (order.status == OrderStatusType.waiting) ...[
                AppButton(
                  text: 'Mulai Masak / Proses',
                  icon: const Icon(Icons.soup_kitchen_rounded, size: 18),
                  onPressed: () {
                    AppState.instance.orderController.updateOrderStatus(order.id, OrderStatusType.cooking);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Pesanan ${order.queueNumber} sekarang Sedang Dimasak!'),
                        backgroundColor: AppColors.warning,
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppDimens.xs),
                AppButton(
                  text: 'Tolak / Batalkan Pesanan',
                  variant: AppButtonVariant.danger,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () => _showCancelDialog(context),
                ),
              ] else if (order.status == OrderStatusType.cooking) ...[
                AppButton(
                  text: 'Makanan Siap Diambil (Selesai Masak)',
                  variant: AppButtonVariant.secondary,
                  icon: const Icon(Icons.check_circle_rounded, size: 18),
                  onPressed: () => _confirmMarkReady(context),
                ),
                const SizedBox(height: AppDimens.xs),
                AppButton(
                  text: 'Batalkan Pesanan',
                  variant: AppButtonVariant.danger,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () => _showCancelDialog(context),
                ),
              ] else if (order.status == OrderStatusType.ready) ...[
                AppButton(
                  text: 'Serahkan Makanan ke Pembeli (Tuntas)',
                  icon: const Icon(Icons.task_alt_rounded, size: 18),
                  onPressed: () {
                    AppState.instance.orderController.updateOrderStatus(order.id, OrderStatusType.completed);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Pesanan ${order.queueNumber} tuntas diserahkan!'),
                        backgroundColor: AppColors.secondary,
                      ),
                    );
                  },
                ),
              ] else if (order.isCanceled) ...[
                Container(
                  padding: const EdgeInsets.all(AppDimens.sm),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Pesanan telah Dibatalkan: ${order.cancellationReason}',
                      style: const TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(AppDimens.sm),
                  decoration: BoxDecoration(
                    color: AppColors.successContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'Pesanan telah Selesai dan diserahkan kepada pembeli.',
                      style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
