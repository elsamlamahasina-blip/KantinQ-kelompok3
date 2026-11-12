import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../../core/widgets/status_badge.dart';
import '../../cart/models/cart_item_model.dart';
import '../models/order_model.dart';

class OrderController extends ChangeNotifier {
  final List<OrderModel> _orders = [];

  List<OrderModel> get orders => List.unmodifiable(_orders);

  List<OrderModel> get activeOrders =>
      _orders.where((o) => o.isActive).toList();

  List<OrderModel> get pastOrders =>
      _orders.where((o) => !o.isActive).toList();

  OrderModel? get latestActiveOrder {
    final active = activeOrders;
    return active.isNotEmpty ? active.first : null;
  }

  String _generateQueueNumber(String canteenId) {
    final number = 10 + Random().nextInt(80);
    return '#A-$number';
  }

  Future<OrderModel> createOrder({
    required String canteenId,
    required String canteenName,
    String customerName = 'Rian Pratama',
    String customerPhone = '081234567890',
    required List<CartItemModel> items,
    required OrderType orderType,
    String? tableNumber,
    required String paymentMethod,
    required double subtotal,
    required double serviceFee,
    required double discountAmount,
    required double totalAmount,
    String? notes,
  }) async {
    final now = DateTime.now();
    final queueNum = _generateQueueNumber(canteenId);
    final order = OrderModel(
      id: 'ORD_${now.millisecondsSinceEpoch}',
      queueNumber: queueNum,
      canteenId: canteenId,
      canteenName: canteenName,
      customerName: customerName,
      customerPhone: customerPhone,
      items: List.from(items),
      orderType: orderType,
      tableNumber: tableNumber,
      paymentMethod: paymentMethod,
      subtotal: subtotal,
      serviceFee: serviceFee,
      discountAmount: discountAmount,
      totalAmount: totalAmount,
      status: OrderStatusType.waiting,
      createdAt: now,
      estimatedReadyTime: now.add(const Duration(minutes: 12)),
      qrVerificationCode: 'KQ-${queueNum.replaceAll('#', '')}-${now.millisecondsSinceEpoch.toString().substring(8)}',
      notes: notes,
    );

    _orders.insert(0, order);
    notifyListeners();
    return order;
  }

  void updateOrderStatus(String orderId, OrderStatusType newStatus) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      _orders[index].status = newStatus;
      notifyListeners();
    }
  }

  void advanceOrderStatus(String orderId) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      final current = _orders[index].status;
      if (current == OrderStatusType.waiting) {
        _orders[index].status = OrderStatusType.cooking;
      } else if (current == OrderStatusType.cooking) {
        _orders[index].status = OrderStatusType.ready;
      } else if (current == OrderStatusType.ready) {
        _orders[index].status = OrderStatusType.completed;
      }
      notifyListeners();
    }
  }

  void confirmOrderReceived(String orderId) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      _orders[index].status = OrderStatusType.completed;
      notifyListeners();
    }
  }

  bool cancelOrder(
    String orderId, {
    String? reason,
    bool bySeller = false,
  }) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      final order = _orders[index];
      // Customer can only cancel if waiting; Seller can cancel if waiting or cooking
      if (!bySeller && order.status != OrderStatusType.waiting) {
        return false;
      }

      _orders[index] = order.copyWith(
        status: OrderStatusType.canceled,
        cancellationReason: reason ?? (bySeller ? 'Dibatalkan oleh stan kantin' : 'Dibatalkan oleh pembeli'),
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  List<OrderModel> getOrdersForCanteen(String canteenId) {
    return _orders.where((o) => o.canteenId == canteenId).toList();
  }

  List<OrderModel> getActiveOrdersForCanteen(String canteenId) {
    return _orders.where((o) => o.canteenId == canteenId && o.isActive).toList();
  }

  int getTodayOrderCountForCanteen(String canteenId) {
    return _orders.where((o) => o.canteenId == canteenId).length;
  }

  double getTodayRevenueForCanteen(String canteenId) {
    return _orders
        .where((o) => o.canteenId == canteenId && o.status != OrderStatusType.canceled)
        .fold(0.0, (sum, o) => sum + o.totalAmount);
  }

  OrderModel? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((o) => o.id == orderId);
    } catch (_) {
      return null;
    }
  }
}
