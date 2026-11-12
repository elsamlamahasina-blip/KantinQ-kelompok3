import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nama_project/core/state/app_state.dart';
import 'package:nama_project/features/auth/models/user_model.dart';
import 'package:nama_project/features/canteen/data/mock_canteen_data.dart';
import 'package:nama_project/features/cart/models/cart_item_model.dart';
import 'package:nama_project/features/order/models/order_model.dart';
import 'package:nama_project/main.dart';

// 1x1 transparent PNG bytes for mock network image requests in widget tests
const List<int> _transparentImage = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
  0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
  0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
  0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
  0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82,
];

class _MockHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest();
}

class _MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  final HttpHeaders headers = _MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => _MockHttpClientResponse();
}

class _MockHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => _transparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_transparentImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

class _MockHttpHeaders extends Fake implements HttpHeaders {
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _MockHttpClient();
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  group('KantinQ Unit & Business Logic Tests', () {
    test('WalletController should top up and deduct correctly', () async {
      final wallet = AppState.instance.walletController;
      final initialBalance = wallet.balance;

      // Test top up
      await wallet.topUp(amount: 25000, paymentMethod: 'BCA Virtual Account');
      expect(wallet.balance, equals(initialBalance + 25000));
      expect(wallet.isBalanceSufficient(initialBalance + 25000), isTrue);

      // Test deduction
      final deductSuccess = await wallet.deduct(
        amount: 20000,
        title: 'Pembayaran Test',
        description: 'Test deduction',
      );
      expect(deductSuccess, isTrue);
      expect(wallet.balance, equals(initialBalance + 5000));
    });

    test('CartController should calculate total, apply voucher, and clear', () {
      final cart = AppState.instance.cartController;
      cart.clearCart();

      expect(cart.items.isEmpty, isTrue);
      expect(cart.totalAmount, equals(0.0));

      final testMenu = MockCanteenData.allMenus.first; // Price: 22000
      cart.addItem(menuItem: testMenu, quantity: 2); // 44000

      expect(cart.items.length, equals(1));
      expect(cart.totalQuantity, equals(2));
      expect(cart.subtotal, equals(44000));
      // Subtotal 44000 + 1000 service fee = 45000
      expect(cart.totalAmount, equals(45000));

      // Test voucher
      final voucherApplied = cart.applyVoucher('KANTINQHEMAT');
      expect(voucherApplied, isTrue);
      expect(cart.discountAmount, equals(5000));
      expect(cart.totalAmount, equals(40000));

      // Test clear
      cart.clearCart();
      expect(cart.items.isEmpty, isTrue);
      expect(cart.totalAmount, equals(0.0));
    });

    test('OrderController should advance order status', () async {
      final orderCtrl = AppState.instance.orderController;
      final cart = AppState.instance.cartController;
      cart.clearCart();

      final testMenu = MockCanteenData.allMenus.first;
      cart.addItem(menuItem: testMenu, quantity: 1);

      final order = await orderCtrl.createOrder(
        canteenId: testMenu.canteenId,
        canteenName: testMenu.canteenName,
        items: cart.items,
        orderType: OrderType.dineIn,
        tableNumber: 'Meja 01',
        paymentMethod: 'KantinQ Pay',
        subtotal: 22000,
        serviceFee: 1000,
        discountAmount: 0,
        totalAmount: 23000,
      );

      expect(order.queueNumber, startsWith('#A-'));
      expect(order.status.name, equals('waiting'));

      // Advance to cooking
      orderCtrl.advanceOrderStatus(order.id);
      expect(order.status.name, equals('cooking'));

      // Advance to ready
      orderCtrl.advanceOrderStatus(order.id);
      expect(order.status.name, equals('ready'));

      // Advance to completed
      orderCtrl.advanceOrderStatus(order.id);
      expect(order.status.name, equals('completed'));
    });

    test('CartController enforces single canteen per cart and allows switching stall', () {
      final cart = AppState.instance.cartController;
      cart.clearCart();

      final menu1 = MockCanteenData.allMenus.firstWhere((m) => m.canteenId == 'c1');
      final menuDimsum = MockCanteenData.allMenus.firstWhere((m) => m.canteenId == 'c4');

      cart.addItem(menuItem: menu1, quantity: 1);
      expect(cart.primaryCanteenId, equals('c1'));
      expect(cart.isDifferentCanteen(menuDimsum.canteenId), isTrue);

      // Switching stall with clearPreviousCanteen replaces previous stall items cleanly
      cart.addItem(
        menuItem: menuDimsum,
        quantity: 2,
        clearPreviousCanteen: true,
      );
      expect(cart.primaryCanteenId, equals('c4'));
      expect(cart.items.length, equals(1));
      expect(cart.totalQuantity, equals(2));
    });

    test('CanteenController should deduct and restore stock on order lifecycle', () {
      final canteenCtrl = AppState.instance.canteenController;
      final menu = canteenCtrl.allMenus.first;
      final initialStock = menu.stock;

      // Deduct stock for order
      canteenCtrl.deductStockForOrder([
        CartItemModel(
          id: 'test_item_1',
          menuItem: menu,
          quantity: 2,
        ),
      ]);
      final updatedMenu = canteenCtrl.allMenus.firstWhere((m) => m.id == menu.id);
      expect(updatedMenu.stock, equals(initialStock - 2));

      // Restore stock on cancellation
      canteenCtrl.restoreStockForOrder([
        CartItemModel(
          id: 'test_item_1',
          menuItem: menu,
          quantity: 2,
        ),
      ]);
      final restoredMenu = canteenCtrl.allMenus.firstWhere((m) => m.id == menu.id);
      expect(restoredMenu.stock, equals(initialStock));
    });

    test('AuthController should support dual-role switching', () {
      final authCtrl = AppState.instance.authController;
      authCtrl.loginAsDemoBuyer();
      expect(authCtrl.currentUser?.role, equals(UserRole.buyer));
      expect(authCtrl.currentUser?.isSeller, isFalse);

      authCtrl.loginAsDemoSeller();
      expect(authCtrl.currentUser?.role, equals(UserRole.seller));
      expect(authCtrl.currentUser?.isSeller, isTrue);
      expect(authCtrl.currentUser?.sellerCanteenId, isNotNull);

      authCtrl.switchRole(UserRole.buyer);
      expect(authCtrl.currentUser?.isSeller, isFalse);
    });
  });

  group('KantinQ Widget & UI Smoke Tests', () {
    testWidgets('KantinQApp shows LoginScreen first when logged out', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(420, 860);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      AppState.instance.authController.logout();

      await tester.pumpWidget(const KantinQApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Masuk ke Akun'), findsOneWidget);
      expect(find.text('Masuk Sekarang'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('KantinQApp displays 4 COD-only bottom navigation tabs when logged in as buyer', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(420, 860);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      AppState.instance.authController.loginAsDemoBuyer();

      await tester.pumpWidget(const KantinQApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Check 4 navigation tabs (COD-only mode without Dompet/QRIS)
      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('Pesanan'), findsOneWidget);
      expect(find.text('Keranjang'), findsWidgets);
      expect(find.text('Profil'), findsOneWidget);
      expect(find.text('Dompet'), findsNothing);
      expect(find.text('KantinQ Pay'), findsNothing);

      // Check COD banner
      expect(find.text('Metode Pembayaran COD'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
