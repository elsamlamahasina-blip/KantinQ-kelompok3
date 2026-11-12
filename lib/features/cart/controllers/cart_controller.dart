import 'package:flutter/foundation.dart';
import '../../../core/state/app_state.dart';
import '../../canteen/models/menu_item_model.dart';
import '../../order/models/order_model.dart';
import '../models/cart_item_model.dart';

class CartController extends ChangeNotifier {
  final List<CartItemModel> _items = [];
  OrderType _orderType = OrderType.dineIn;
  String _tableNumber = 'Meja 08';
  String _customerNotes = '';
  String? _appliedVoucherCode;
  double _discountAmount = 0.0;
  final double _serviceFee = 1000.0;

  List<CartItemModel> get items => List.unmodifiable(_items);
  OrderType get orderType => _orderType;
  String get tableNumber => _tableNumber;
  String get customerNotes => _customerNotes;
  String? get appliedVoucherCode => _appliedVoucherCode;
  double get discountAmount => _discountAmount;
  double get serviceFee => _items.isEmpty ? 0.0 : _serviceFee;

  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get totalAmount {
    if (_items.isEmpty) return 0.0;
    final total = subtotal + serviceFee - _discountAmount;
    return total > 0 ? total : 0.0;
  }

  String get primaryCanteenId => _items.isNotEmpty ? _items.first.menuItem.canteenId : 'c1';
  String get primaryCanteenName => _items.isNotEmpty ? _items.first.menuItem.canteenName : 'KantinQ';
  String get currentCanteenName => primaryCanteenName;

  bool isDifferentCanteen(String canteenId) {
    if (_items.isEmpty) return false;
    return primaryCanteenId != canteenId;
  }

  void addItem({
    required MenuItemModel menuItem,
    int quantity = 1,
    String? selectedSpicyLevel,
    List<MenuTopping> selectedToppings = const [],
    String? specialNotes,
    bool clearPreviousCanteen = false,
  }) {
    if (clearPreviousCanteen) {
      _items.clear();
      _discountAmount = 0.0;
      _appliedVoucherCode = null;
    }

    // Check if an identical item (same menu, spicy level, toppings, and notes) already exists
    final existingIndex = _items.indexWhere((item) =>
        item.menuItem.id == menuItem.id &&
        item.selectedSpicyLevel == selectedSpicyLevel &&
        item.specialNotes == specialNotes &&
        _areToppingsEqual(item.selectedToppings, selectedToppings));

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(
        CartItemModel(
          id: 'cart_${DateTime.now().millisecondsSinceEpoch}_${_items.length}',
          menuItem: menuItem,
          quantity: quantity,
          selectedSpicyLevel: selectedSpicyLevel,
          selectedToppings: selectedToppings,
          specialNotes: specialNotes,
        ),
      );
    }
    _revalidateVoucher();
    notifyListeners();
  }

  bool _areToppingsEqual(List<MenuTopping> a, List<MenuTopping> b) {
    if (a.length != b.length) return false;
    final aNames = a.map((t) => t.name).toSet();
    final bNames = b.map((t) => t.name).toSet();
    return aNames.containsAll(bNames);
  }

  void updateQuantity(String cartItemId, int quantity) {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      if (_items.isEmpty) {
        _discountAmount = 0.0;
        _appliedVoucherCode = null;
      } else {
        _revalidateVoucher();
      }
      notifyListeners();
    }
  }

  void removeItem(String cartItemId) {
    _items.removeWhere((item) => item.id == cartItemId);
    if (_items.isEmpty) {
      _discountAmount = 0.0;
      _appliedVoucherCode = null;
    } else {
      _revalidateVoucher();
    }
    notifyListeners();
  }

  void setOrderType(OrderType type) {
    _orderType = type;
    notifyListeners();
  }

  void setTableNumber(String table) {
    _tableNumber = table;
    notifyListeners();
  }

  void setCustomerNotes(String notes) {
    _customerNotes = notes;
    notifyListeners();
  }

  ({bool success, String message}) applyVoucherWithMessage(String code) {
    final result = AppState.instance.voucherController.validateVoucher(
      code,
      subtotal: subtotal,
      cartCanteenId: _items.isEmpty ? null : primaryCanteenId,
    );
    if (!result.isValid) {
      return (success: false, message: result.message);
    }
    _appliedVoucherCode = result.voucher?.code ?? code.trim().toUpperCase();
    _discountAmount = result.discount;
    notifyListeners();
    return (success: true, message: result.message);
  }

  bool applyVoucher(String code) => applyVoucherWithMessage(code).success;

  void _revalidateVoucher() {
    final code = _appliedVoucherCode;
    if (code == null) return;
    if (_items.isEmpty) {
      _appliedVoucherCode = null;
      _discountAmount = 0.0;
      return;
    }
    final result = AppState.instance.voucherController.validateVoucher(
      code,
      subtotal: subtotal,
      cartCanteenId: primaryCanteenId,
    );
    if (!result.isValid) {
      _appliedVoucherCode = null;
      _discountAmount = 0.0;
    } else {
      _discountAmount = result.discount;
    }
  }

  void removeVoucher() {
    _appliedVoucherCode = null;
    _discountAmount = 0.0;
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _discountAmount = 0.0;
    _appliedVoucherCode = null;
    _customerNotes = '';
    notifyListeners();
  }

  void clear() => clearCart();
}
