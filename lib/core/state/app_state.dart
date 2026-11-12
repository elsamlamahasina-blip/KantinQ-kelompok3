import 'package:flutter/material.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/canteen/controllers/canteen_controller.dart';
import '../../features/cart/controllers/cart_controller.dart';
import '../../features/order/controllers/order_controller.dart';
import '../../features/voucher/controllers/voucher_controller.dart';
import '../../features/wallet/controllers/wallet_controller.dart';

class AppState {
  static final AppState instance = AppState._internal();

  final AuthController authController = AuthController();
  final CanteenController canteenController = CanteenController();
  final CartController cartController = CartController();
  final OrderController orderController = OrderController();
  final VoucherController voucherController = VoucherController();
  final WalletController walletController = WalletController();

  AppState._internal();
}

class AppStateScope extends InheritedWidget {
  final AppState state;

  const AppStateScope({
    super.key,
    required this.state,
    required super.child,
  });

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    return scope?.state ?? AppState.instance;
  }

  @override
  bool updateShouldNotify(covariant AppStateScope oldWidget) => false;
}
