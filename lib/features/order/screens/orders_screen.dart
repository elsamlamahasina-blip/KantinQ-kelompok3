import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/state/app_state.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/status_badge.dart';
import '../../cart/screens/cart_screen.dart';
import '../models/order_model.dart';
import '../widgets/digital_receipt_sheet.dart';
import 'order_tracking_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderCtrl = AppState.instance.orderController;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Pesanan & Antrean'),
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            indicatorWeight: 3,
            tabs: [
              AnimatedBuilder(
                animation: orderCtrl,
                builder: (context, _) {
                  final activeCount = orderCtrl.activeOrders.length;
                  return Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Flexible(
                          child: Text(
                            'Antrean Aktif',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (activeCount > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$activeCount',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
              const Tab(text: 'Riwayat Selesai'),
            ],
          ),
        ),
        body: AnimatedBuilder(
          animation: orderCtrl,
          builder: (context, _) {
            final activeOrders = orderCtrl.activeOrders;
            final pastOrders = orderCtrl.pastOrders;

            return TabBarView(
              children: [
                // Tab 1: Active Queue
                activeOrders.isEmpty
                    ? const EmptyStateView(
                        icon: Icons.receipt_long_rounded,
                        title: 'Tidak Ada Antrean Aktif',
                        message: 'Pesanan makanan yang sedang diproses di kantin akan muncul di sini.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppDimens.md),
                        itemCount: activeOrders.length,
                        separatorBuilder: (_, _) => const SizedBox(height: AppDimens.sm),
                        itemBuilder: (context, index) {
                          final order = activeOrders[index];
                          return _ActiveOrderCard(order: order);
                        },
                      ),

                // Tab 2: Past Orders History
                pastOrders.isEmpty
                    ? const EmptyStateView(
                        icon: Icons.history_rounded,
                        title: 'Belum Ada Riwayat',
                        message: 'Pesanan yang telah selesai akan tersimpan rapi di riwayat ini.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppDimens.md),
                        itemCount: pastOrders.length,
                        separatorBuilder: (_, _) => const SizedBox(height: AppDimens.sm),
                        itemBuilder: (context, index) {
                          final order = pastOrders[index];
                          return _PastOrderCard(order: order);
                        },
                      ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ActiveOrderCard extends StatelessWidget {
  final OrderModel order;

  const _ActiveOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.primaryLight, width: 1.5),
        boxShadow: const [AppColors.softShadow],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderTrackingScreen(orderId: order.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            order.queueNumber,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimens.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.canteenName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                order.orderTypeLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimens.xs),
                  StatusBadge(status: order.status),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(),
              ),
              Text(
                order.items.map((i) => "${i.quantity}x ${i.menuItem.name}").join(", "),
                style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      CurrencyFormatter.format(order.totalAmount),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: AppDimens.sm),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Pantau Antrean',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primary),
                    ],
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

class _PastOrderCard extends StatelessWidget {
  final OrderModel order;

  const _PastOrderCard({required this.order});

  void _executeReorder(BuildContext context, dynamic cart) {
    for (final item in order.items) {
      cart.addItem(
        menuItem: item.menuItem,
        quantity: item.quantity,
        selectedSpicyLevel: item.selectedSpicyLevel,
        selectedToppings: item.selectedToppings,
        specialNotes: item.specialNotes,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Semua menu telah dimasukkan kembali ke keranjang!'),
        backgroundColor: AppColors.secondary,
        action: SnackBarAction(
          label: 'Ke Keranjang',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            );
          },
        ),
      ),
    );
  }

  void _reorder(BuildContext context) {
    final cart = AppState.instance.cartController;
    if (cart.isDifferentCanteen(order.canteenId)) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ganti Stan Kantin?'),
          content: Text(
            'Keranjang Anda berisi menu dari stan "${cart.currentCanteenName}".\n\n'
            'Apakah Anda ingin mengosongkan keranjang dan memesan ulang dari "${order.canteenName}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                cart.clear();
                _executeReorder(context, cart);
              },
              child: const Text('Ganti Stan'),
            ),
          ],
        ),
      );
      return;
    }

    _executeReorder(context, cart);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.outline),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderTrackingScreen(orderId: order.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.md),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    order.canteenName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: AppDimens.xs),
                StatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              DateFormatter.formatDateTime(order.createdAt),
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(),
            ),
            Text(
              order.items.map((i) => "${i.quantity}x ${i.menuItem.name}").join(", "),
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppDimens.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    CurrencyFormatter.format(order.totalAmount),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(width: AppDimens.xs),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => DigitalReceiptSheet(order: order),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: const Text('Struk', style: TextStyle(fontSize: 11)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _reorder(context),
                      style: ElevatedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: const Text('Pesan Lagi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
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
