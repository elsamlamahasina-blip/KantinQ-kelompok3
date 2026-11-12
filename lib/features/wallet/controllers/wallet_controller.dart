import 'package:flutter/foundation.dart';
import '../models/wallet_transaction_model.dart';

class WalletController extends ChangeNotifier {
  double _balance = 75000.0;
  final List<WalletTransactionModel> _transactions = [
    WalletTransactionModel(
      id: 'tx_init_1',
      type: TransactionType.topUp,
      title: 'Top Up via BCA Virtual Account',
      description: 'Pengisian saldo KantinQ Pay berhasil',
      amount: 50000,
      timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
      status: TransactionStatus.success,
    ),
    WalletTransactionModel(
      id: 'tx_init_2',
      type: TransactionType.payment,
      title: 'Pembayaran KantinQ',
      description: 'Pesanan #A-08 — Nasi Soto Ayam',
      amount: 19000,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      status: TransactionStatus.success,
      referenceId: 'ORD_9821',
    ),
    WalletTransactionModel(
      id: 'tx_init_3',
      type: TransactionType.topUp,
      title: 'Top Up via Virtual Account BCA',
      description: 'Pengisian saldo KantinQ Pay',
      amount: 44000,
      timestamp: DateTime.now().subtract(const Duration(hours: 12)),
      status: TransactionStatus.success,
    ),
  ];

  bool _isProcessing = false;

  double get balance => _balance;
  List<WalletTransactionModel> get transactions => List.unmodifiable(_transactions);
  bool get isProcessing => _isProcessing;

  bool isBalanceSufficient(double amount) => _balance >= amount;

  Future<bool> topUp({
    required double amount,
    required String paymentMethod,
  }) async {
    _isProcessing = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    _balance += amount;
    _transactions.insert(
      0,
      WalletTransactionModel(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        type: TransactionType.topUp,
        title: 'Top Up via $paymentMethod',
        description: 'Pengisian saldo KantinQ Pay berhasil',
        amount: amount,
        timestamp: DateTime.now(),
        status: TransactionStatus.success,
      ),
    );

    _isProcessing = false;
    notifyListeners();
    return true;
  }

  Future<bool> deduct({
    required double amount,
    required String title,
    required String description,
    String? referenceId,
  }) async {
    if (!isBalanceSufficient(amount)) {
      return false;
    }

    _isProcessing = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));

    _balance -= amount;
    _transactions.insert(
      0,
      WalletTransactionModel(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        type: TransactionType.payment,
        title: title,
        description: description,
        amount: amount,
        timestamp: DateTime.now(),
        status: TransactionStatus.success,
        referenceId: referenceId,
      ),
    );

    _isProcessing = false;
    notifyListeners();
    return true;
  }
}
