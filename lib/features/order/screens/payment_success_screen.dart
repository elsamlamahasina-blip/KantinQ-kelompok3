import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/ticket_shape_clipper.dart';
import '../models/order_model.dart';
import 'order_tracking_screen.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final OrderModel order;

  const PaymentSuccessScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Success Checkmark Icon
                Container(
                  width: 76,
                  height: 76,
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x3300897B),
                        blurRadius: 24,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
                const SizedBox(height: AppDimens.md),

                const Text(
                  'Pesanan Berhasil Dibuat!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Pesanan Anda telah diteruskan ke dapur stan kantin',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppDimens.lg),

                // Perforated Ticket Card
                ClipPath(
                  clipper: TicketClipper(
                    punchRadius: 14,
                    punchPositionPercent: 0.65,
                    cornerRadius: 18,
                  ),
                  child: Container(
                    width: double.infinity,
                    color: AppColors.surface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Upper Ticket
                        Padding(
                          padding: const EdgeInsets.all(AppDimens.lg),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'NOMOR ANTREAN ANDA',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppDimens.xs),
                              Text(
                                order.queueNumber,
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                  letterSpacing: -1,
                                ),
                              ),
                              Text(
                                order.canteenName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${order.orderTypeLabel} ${order.tableNumber != null ? "• ${order.tableNumber}" : ""}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: AppDimens.md),

                              // Estimated Ready Time
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryContainer,
                                  borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.timer_rounded, color: AppColors.secondary, size: 16),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        'Estimasi Siap: ${DateFormatter.formatTimeOnly(order.estimatedReadyTime)}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppColors.secondaryDark,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Dashed Perforation
                        SizedBox(
                          height: 1,
                          width: double.infinity,
                          child: CustomPaint(
                            painter: DashedLinePainter(
                              color: AppColors.outlineVariant,
                              dashWidth: 6,
                              dashSpace: 4,
                            ),
                          ),
                        ),

                        // Lower Ticket
                        Padding(
                          padding: const EdgeInsets.all(AppDimens.lg),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total Pembayaran', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  const SizedBox(width: AppDimens.sm),
                                  Flexible(
                                    child: Text(
                                      CurrencyFormatter.format(order.totalAmount),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Metode Pembayaran', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  const SizedBox(width: AppDimens.sm),
                                  Flexible(
                                    child: Text(
                                      order.paymentMethod,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('ID Transaksi', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  const SizedBox(width: AppDimens.sm),
                                  Flexible(
                                    child: Text(
                                      order.id,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppDimens.xl),

                // Action Buttons
                AppButton(
                  text: 'Pantau Antrean Dapur Sekarang',
                  icon: const Icon(Icons.receipt_long_rounded, size: 18),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderTrackingScreen(orderId: order.id),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppDimens.sm),
                AppButton(
                  text: 'Kembali ke Beranda',
                  variant: AppButtonVariant.outline,
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
