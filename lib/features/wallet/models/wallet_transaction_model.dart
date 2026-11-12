enum TransactionType {
  topUp,
  payment,
  refund,
}

enum TransactionStatus {
  success,
  pending,
  failed,
}

class WalletTransactionModel {
  final String id;
  final TransactionType type;
  final String title;
  final String description;
  final double amount;
  final DateTime timestamp;
  final TransactionStatus status;
  final String? referenceId;

  const WalletTransactionModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.amount,
    required this.timestamp,
    this.status = TransactionStatus.success,
    this.referenceId,
  });

  bool get isIncome => type == TransactionType.topUp || type == TransactionType.refund;
}
