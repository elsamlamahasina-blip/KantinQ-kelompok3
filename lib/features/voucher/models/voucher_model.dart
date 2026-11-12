class VoucherModel {
  final String id;
  final String code;
  final String title;
  final String description;
  final String? canteenId;
  final String? canteenName;
  final double discountAmount;
  final double minPurchase;
  final int quota;
  final int usedCount;
  final bool isActive;

  const VoucherModel({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    this.canteenId,
    this.canteenName,
    required this.discountAmount,
    this.minPurchase = 0,
    this.quota = 50,
    this.usedCount = 0,
    this.isActive = true,
  });

  bool get isGlobal => canteenId == null || canteenId!.isEmpty;
  int get remainingQuota => quota > usedCount ? quota - usedCount : 0;
  bool get hasQuota => remainingQuota > 0;
  bool get isUsable => isActive && hasQuota;

  VoucherModel copyWith({
    String? code,
    String? title,
    String? description,
    String? canteenId,
    String? canteenName,
    double? discountAmount,
    double? minPurchase,
    int? quota,
    int? usedCount,
    bool? isActive,
  }) {
    return VoucherModel(
      id: id,
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      canteenId: canteenId ?? this.canteenId,
      canteenName: canteenName ?? this.canteenName,
      discountAmount: discountAmount ?? this.discountAmount,
      minPurchase: minPurchase ?? this.minPurchase,
      quota: quota ?? this.quota,
      usedCount: usedCount ?? this.usedCount,
      isActive: isActive ?? this.isActive,
    );
  }
}

