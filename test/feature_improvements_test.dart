import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nama_project/core/state/app_state.dart';
import 'package:nama_project/core/widgets/menu_image_view.dart';
import 'package:nama_project/core/widgets/status_badge.dart';
import 'package:nama_project/features/auth/screens/login_screen.dart';
import 'package:nama_project/features/auth/screens/register_screen.dart';
import 'package:nama_project/features/canteen/data/mock_canteen_data.dart';
import 'package:nama_project/features/canteen/models/menu_item_model.dart';
import 'package:nama_project/features/canteen/screens/canteen_detail_screen.dart';
import 'package:nama_project/features/canteen/widgets/menu_customization_sheet.dart';
import 'package:nama_project/features/cart/models/cart_item_model.dart';
import 'package:nama_project/features/cart/screens/cart_screen.dart';
import 'package:nama_project/features/checkout/screens/checkout_screen.dart';
import 'package:nama_project/features/home/screens/home_screen.dart';
import 'package:nama_project/features/home/widgets/canteen_card.dart';
import 'package:nama_project/features/merchant/screens/merchant_dashboard_screen.dart';
import 'package:nama_project/features/merchant/screens/merchant_menu_form_sheet.dart';
import 'package:nama_project/features/merchant/screens/merchant_order_detail_sheet.dart';
import 'package:nama_project/features/merchant/screens/merchant_voucher_form_sheet.dart';
import 'package:nama_project/features/order/models/order_model.dart';
import 'package:nama_project/features/order/screens/order_tracking_screen.dart';
import 'package:nama_project/features/order/screens/orders_screen.dart';
import 'package:nama_project/features/order/screens/payment_success_screen.dart';
import 'package:nama_project/features/order/widgets/digital_receipt_sheet.dart';
import 'package:nama_project/features/profile/screens/profile_screen.dart';
import 'package:nama_project/features/voucher/controllers/voucher_controller.dart';
import 'package:nama_project/features/voucher/models/voucher_model.dart';

const List<int> _transparentPng = <int>[
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
  int get contentLength => _transparentPng.length;

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
    return Stream<List<int>>.fromIterable([_transparentPng]).listen(
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

  group('Voucher per Canteen & Cart Revalidation Tests', () {
    test('Every canteen seller account (c1-c5) has active pre-seeded vouchers', () {
      final voucherCtrl = VoucherController();
      for (final canteenId in ['c1', 'c2', 'c3', 'c4', 'c5']) {
        final active = voucherCtrl.getActiveVouchersForCanteen(canteenId);
        expect(
          active,
          isNotEmpty,
          reason: 'Canteen $canteenId must have at least one active voucher',
        );
      }
    });

    test('Seller voucher CRUD, duplicate prevention, quota & cross-canteen rules work', () {
      final voucherCtrl = VoucherController();
      final addRes = voucherCtrl.addVoucher(
        const VoucherModel(
          id: 'v_test_c2',
          code: 'PROMOJONI',
          title: 'Promo Joni Test',
          description: 'Test',
          canteenId: 'c2',
          canteenName: 'Stan Bakso & Mie Mas Joni',
          discountAmount: 5000,
          minPurchase: 15000,
          quota: 1,
        ),
      );
      expect(addRes.success, isTrue);

      final duplicateRes = voucherCtrl.addVoucher(
        const VoucherModel(
          id: 'v_dup',
          code: 'promojoni',
          title: 'Dup',
          description: 'Dup',
          canteenId: 'c3',
          discountAmount: 3000,
        ),
      );
      expect(duplicateRes.success, isFalse);

      // Cross-canteen validation blocks c2 voucher for c1 cart
      final wrongStall = voucherCtrl.validateVoucher(
        'PROMOJONI',
        subtotal: 20000,
        cartCanteenId: 'c1',
      );
      expect(wrongStall.isValid, isFalse);

      // Matching canteen succeeds
      final validStall = voucherCtrl.validateVoucher(
        'PROMOJONI',
        subtotal: 20000,
        cartCanteenId: 'c2',
      );
      expect(validStall.isValid, isTrue);
      expect(validStall.discount, equals(5000));

      // Exhaust quota
      voucherCtrl.markVoucherUsed('PROMOJONI');
      final exhausted = voucherCtrl.validateVoucher(
        'PROMOJONI',
        subtotal: 20000,
        cartCanteenId: 'c2',
      );
      expect(exhausted.isValid, isFalse);
    });

    test('CartController revalidates and clears minPurchase voucher when subtotal drops', () {
      final cart = AppState.instance.cartController;
      cart.clearCart();

      final c1Menu = MockCanteenData.allMenus.firstWhere((m) => m.canteenId == 'c1');
      // Add 2 items (assuming >= 20000) so BUSRI5RB (min 20000) applies
      cart.addItem(menuItem: c1Menu, quantity: 2);
      final applied = cart.applyVoucherWithMessage('BUSRI5RB');
      expect(applied.success, isTrue);
      expect(cart.appliedVoucherCode, equals('BUSRI5RB'));
      expect(cart.discountAmount, equals(5000));

      // Drop quantity to 1 item if price < 20000 OR pick cheap c1 item
      cart.clearCart();
      final cheapC1Menu = MockCanteenData.allMenus
          .where((m) => m.canteenId == 'c1' && m.price < 20000)
          .first;
      cart.addItem(menuItem: cheapC1Menu, quantity: 2);
      expect(cart.applyVoucher('BUSRI5RB'), isTrue);
      cart.updateQuantity(cart.items.first.id, 1);
      expect(cart.subtotal, lessThan(20000));
      expect(cart.appliedVoucherCode, isNull);
      expect(cart.discountAmount, equals(0));
      cart.clearCart();
    });
  });

  group('New Menus & Image Bytes Model Tests', () {
    test('All seeded menus have valid imageUrl and new menus exist', () {
      expect(MockCanteenData.allMenus.length, greaterThanOrEqualTo(25));
      for (final menu in MockCanteenData.allMenus) {
        expect(menu.hasImage, isTrue, reason: '${menu.id} ${menu.name} must have an image');
      }
      for (final canteenId in ['c1', 'c2', 'c3', 'c4', 'c5']) {
        expect(
          MockCanteenData.allMenus.where((m) => m.canteenId == canteenId),
          isNotEmpty,
        );
      }
    });

    test('MenuItemModel copyWith preserves and clears imageBytes', () {
      final bytes = Uint8List.fromList(_transparentPng);
      final base = MockCanteenData.allMenus.first.copyWith(imageBytes: bytes);
      expect(base.imageBytes, equals(bytes));
      final cleared = base.copyWith(clearImageBytes: true);
      expect(cleared.imageBytes, isNull);
    });
  });

  group('Layout Overflow & UI Integration Tests', () {
    testWidgets('CanteenCard and HomeScreen render without RenderFlex overflow on narrow viewport', (tester) async {
      tester.view.physicalSize = const Size(360, 760);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      AppState.instance.authController.loginAsDemoBuyer();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                height: 244,
                width: 240,
                child: CanteenCard(
                  canteen: MockCanteenData.canteens.first,
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
    });

    testWidgets('MenuImageView renders uploaded Uint8List bytes cleanly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MenuImageView(
              imageUrl: '',
              imageBytes: Uint8List.fromList(_transparentPng),
              width: 80,
              height: 80,
            ),
          ),
        ),
      );
      expect(find.byType(Image), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Seller dashboard renders "+ Tambah Gambar" menu item and Voucher tab without overflow', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      AppState.instance.authController.loginAsDemoSeller(canteenId: 'c1');
      await tester.pumpWidget(const MaterialApp(home: MerchantDashboardScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Kelola Menu'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('+ Tambah Gambar & Menu Baru'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Voucher'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Voucher Promo Stan'), findsOneWidget);
      expect(find.text('BUSRI5RB'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('LoginScreen displays seller canteen selector when Penjual role is chosen', (tester) async {
      tester.view.physicalSize = const Size(420, 860);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pump();

      await tester.tap(find.text('Penjual (Stan Kantin)'));
      await tester.pumpAndSettle();

      expect(find.text('Pilih Akun Stan Kantin'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Narrow 360x760 audit across buyer screens and sheets has zero overflows or errors', (tester) async {
      tester.view.physicalSize = const Size(360, 760);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      AppState.instance.authController.loginAsDemoBuyer();
      final cart = AppState.instance.cartController;
      cart.clearCart();
      final canteen = MockCanteenData.canteens.first;
      final menu = MockCanteenData.allMenus.firstWhere((m) => m.canteenId == canteen.id);

      // 1. RegisterScreen (Mahasiswa & Penjual Stan)
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));
      await tester.pump();
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Penjual Stan'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // 2. CanteenDetailScreen & MenuCustomizationSheet
      await tester.pumpWidget(MaterialApp(home: CanteenDetailScreen(canteen: canteen)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MenuCustomizationSheet(
              menuItem: menu,
              onAddToCart: ({
                required int quantity,
                required String? selectedSpicyLevel,
                required List<MenuTopping> selectedToppings,
                required String? specialNotes,
              }) {},
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);

      // 3. CartScreen (empty + populated)
      await tester.pumpWidget(const MaterialApp(home: CartScreen()));
      await tester.pump();
      expect(find.text('Keranjang Masih Kosong'), findsOneWidget);
      expect(tester.takeException(), isNull);

      cart.addItem(menuItem: menu, quantity: 2);
      await tester.pumpWidget(const MaterialApp(home: CartScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);

      cart.applyVoucher('BUSRI5RB');
      await tester.pumpWidget(const MaterialApp(home: CartScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);

      // 4. CheckoutScreen
      await tester.pumpWidget(const MaterialApp(home: CheckoutScreen()));
      await tester.pump();
      expect(tester.takeException(), isNull);

      // 5. OrdersScreen (active & past), PaymentSuccessScreen, OrderTrackingScreen, DigitalReceiptSheet
      final longCustomerOrder = OrderModel(
        id: 'ORD_TEST_LONG_1234567890',
        queueNumber: '#A-99',
        canteenId: canteen.id,
        canteenName: 'Kantin Bu Sri — Masakan Nusantara Super Lengkap',
        customerName: 'Muhammad Alexandra Kusuma Wijaya Panjang',
        customerPhone: '08123456789012345',
        items: [CartItemModel(id: 'ci_1', menuItem: menu, quantity: 2)],
        orderType: OrderType.dineIn,
        tableNumber: 'Meja Pojok Lantai 2 Dekat Pintu',
        paymentMethod: 'COD (Bayar Tunai di Kasir Stan)',
        subtotal: 44000,
        serviceFee: 1000,
        discountAmount: 5000,
        totalAmount: 40000,
        status: OrderStatusType.waiting,
        createdAt: DateTime.now(),
        estimatedReadyTime: DateTime.now().add(const Duration(minutes: 10)),
        qrVerificationCode: 'KQ-A99-TEST',
      );
      final completedOrder = longCustomerOrder.copyWith(status: OrderStatusType.completed);

      final orderCtrl = AppState.instance.orderController;
      await orderCtrl.createOrder(
        canteenId: canteen.id,
        canteenName: canteen.name,
        customerName: longCustomerOrder.customerName,
        customerPhone: longCustomerOrder.customerPhone,
        items: longCustomerOrder.items,
        orderType: OrderType.dineIn,
        tableNumber: longCustomerOrder.tableNumber,
        paymentMethod: longCustomerOrder.paymentMethod,
        subtotal: longCustomerOrder.subtotal,
        serviceFee: longCustomerOrder.serviceFee,
        discountAmount: longCustomerOrder.discountAmount,
        totalAmount: longCustomerOrder.totalAmount,
      );
      final latestId = orderCtrl.orders.first.id;

      await tester.pumpWidget(const MaterialApp(home: OrdersScreen()));
      await tester.pump();
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Riwayat Selesai'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(MaterialApp(home: PaymentSuccessScreen(order: longCustomerOrder)));
      await tester.pump();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(MaterialApp(home: OrderTrackingScreen(orderId: latestId)));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.qr_code_2_rounded), findsNothing);
      expect(find.byIcon(Icons.headset_mic_outlined), findsNothing);
      expect(find.textContaining('Tunjukkan QR Code'), findsNothing);
      expect(find.textContaining('bayar tunai (COD)'), findsWidgets);

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: DigitalReceiptSheet(order: completedOrder))));
      await tester.pump();
      expect(tester.takeException(), isNull);

      // 6. ProfileScreen
      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);

      cart.clearCart();
    });

    testWidgets('Narrow 360x760 audit across merchant forms & order detail sheet has zero errors', (tester) async {
      tester.view.physicalSize = const Size(360, 760);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      AppState.instance.authController.loginAsDemoSeller(canteenId: 'c1');
      final canteen = MockCanteenData.canteens.first;
      final menu = MockCanteenData.allMenus.firstWhere((m) => m.canteenId == 'c1');

      final order = OrderModel(
        id: 'ORD_MERCHANT_TEST',
        queueNumber: '#B-88',
        canteenId: canteen.id,
        canteenName: canteen.name,
        customerName: 'Pembeli Nama Panjang Sekali Uji Layout',
        customerPhone: '0812345678909876',
        items: [CartItemModel(id: 'mci_1', menuItem: menu, quantity: 3)],
        orderType: OrderType.dineIn,
        tableNumber: 'Meja Tengah Kantin Utama Lt. 1',
        paymentMethod: 'COD (Bayar Tunai di Kasir Stan)',
        subtotal: 66000,
        serviceFee: 1000,
        discountAmount: 5000,
        totalAmount: 62000,
        status: OrderStatusType.waiting,
        createdAt: DateTime.now(),
        estimatedReadyTime: DateTime.now().add(const Duration(minutes: 10)),
        qrVerificationCode: 'KQ-B88-TEST',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MerchantOrderDetailSheet(order: order),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MerchantMenuFormSheet(
              canteenId: canteen.id,
              canteenName: canteen.name,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MerchantVoucherFormSheet(
              canteenId: canteen.id,
              canteenName: canteen.name,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const MaterialApp(home: MerchantDashboardScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);

      await tester.tap(find.textContaining('Dimasak ('));
      await tester.pump();
      expect(tester.takeException(), isNull);

      await tester.tap(find.textContaining('Siap / Selesai ('));
      await tester.pump();
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Kelola Menu'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Voucher'));
      await tester.pump();
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Pengaturan'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    });
  });
}
