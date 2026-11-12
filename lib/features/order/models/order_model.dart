import '../../../core/widgets/status_badge.dart';
import '../../cart/models/cart_item_model.dart';

enum OrderType {
  dineIn,
  takeaway,
}

class OrderModel {
  final String id;
  final String queueNumber; // e.g. "#A-14"
  final String canteenId;
  final String canteenName;
  final String customerName;
  final String customerPhone;
  final List<CartItemModel> items;
  final OrderType orderType;
  final String? tableNumber;
  final String paymentMethod;
  final double subtotal;
  final double serviceFee;
  final double discountAmount;
  final double totalAmount;
  OrderStatusType status;
  final DateTime createdAt;
  final DateTime estimatedReadyTime;
  final String qrVerificationCode;
  final String? notes;
  final String? cancellationReason;

  OrderModel({
    required this.id,
    required this.queueNumber,
    required this.canteenId,
    required this.canteenName,
    this.customerName = 'Rian Pratama',
    this.customerPhone = '081234567890',
    required this.items,
    required this.orderType,
    this.tableNumber,
    required this.paymentMethod,
    required this.subtotal,
    this.serviceFee = 1000,
    this.discountAmount = 0,
    required this.totalAmount,
    this.status = OrderStatusType.waiting,
    required this.createdAt,
    required this.estimatedReadyTime,
    required this.qrVerificationCode,
    this.notes,
    this.cancellationReason,
  });

  String get orderTypeLabel {
    return orderType == OrderType.dineIn ? 'Makan di Tempat' : 'Bawa Pulang (Takeaway)';
  }

  bool get isActive {
    return status == OrderStatusType.waiting ||
        status == OrderStatusType.cooking ||
        status == OrderStatusType.ready;
  }

  bool get isCanceled => status == OrderStatusType.canceled;

  OrderModel copyWith({
    String? queueNumber,
    String? canteenId,
    String? canteenName,
    String? customerName,
    String? customerPhone,
    List<CartItemModel>? items,
    OrderType? orderType,
    String? tableNumber,
    String? paymentMethod,
    double? subtotal,
    double? serviceFee,
    double? discountAmount,
    double? totalAmount,
    OrderStatusType? status,
    DateTime? estimatedReadyTime,
    String? qrVerificationCode,
    String? notes,
    String? cancellationReason,
  }) {
    return OrderModel(
      id: id,
      queueNumber: queueNumber ?? this.queueNumber,
      canteenId: canteenId ?? this.canteenId,
      canteenName: canteenName ?? this.canteenName,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      items: items ?? this.items,
      orderType: orderType ?? this.orderType,
      tableNumber: tableNumber ?? this.tableNumber,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      subtotal: subtotal ?? this.subtotal,
      serviceFee: serviceFee ?? this.serviceFee,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      createdAt: createdAt,
      estimatedReadyTime: estimatedReadyTime ?? this.estimatedReadyTime,
      qrVerificationCode: qrVerificationCode ?? this.qrVerificationCode,
      notes: notes ?? this.notes,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }
}
