import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/state/app_state.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../home/widgets/wallet_card.dart';
import '../widgets/top_up_sheet.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  void _openTopUpSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const TopUpSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallet = AppState.instance.walletController;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dompet KantinQ Pay'),
      ),
      body: AnimatedBuilder(
        animation: wallet,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Wallet Balance Card
                WalletCard(
                  balance: wallet.balance,
                  onTopUpPressed: () => _openTopUpSheet(context),
                  onHistoryPressed: () {},
                ),

                const SizedBox(height: AppDimens.lg),

                // Transaction History Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Riwayat Transaksi Dompet',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimens.sm),
                    Text(
                      '${wallet.transactions.length} Transaksi',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.sm),

                // Transactions List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: wallet.transactions.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppDimens.sm),
                  itemBuilder: (context, index) {
                    final tx = wallet.transactions[index];
                    return Container(
                      padding: const EdgeInsets.all(AppDimens.sm),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                        border: Border.all(color: AppColors.outline),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: tx.isIncome
                                  ? AppColors.secondaryContainer
                                  : AppColors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              tx.isIncome
                                  ? Icons.arrow_downward_rounded
                                  : Icons.arrow_upward_rounded,
                              color: tx.isIncome ? AppColors.secondary : AppColors.primary,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: AppDimens.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tx.title,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  tx.description,
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormatter.formatDateTime(tx.timestamp),
                                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${tx.isIncome ? "+" : "-"}${CurrencyFormatter.format(tx.amount)}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: tx.isIncome ? AppColors.secondary : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
