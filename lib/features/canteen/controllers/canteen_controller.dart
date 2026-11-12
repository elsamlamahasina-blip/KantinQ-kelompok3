import 'package:flutter/foundation.dart';
import '../data/mock_canteen_data.dart';
import '../models/canteen_model.dart';
import '../models/menu_item_model.dart';

class CanteenController extends ChangeNotifier {
  List<CanteenModel> _canteens = [];
  List<MenuItemModel> _allMenus = [];
  String _selectedCategory = 'Semua';
  String? _selectedCanteenId;
  String _searchQuery = '';
  final Set<String> _favoriteMenuIds = {'m1', 'm5'};
  bool _isLoading = false;
  String? _errorMessage;

  CanteenController() {
    loadData();
  }

  List<CanteenModel> get canteens => _canteens;
  List<MenuItemModel> get allMenus => _allMenus;
  String get selectedCategory => _selectedCategory;
  String? get selectedCanteenId => _selectedCanteenId;
  String get searchQuery => _searchQuery;
  Set<String> get favoriteMenuIds => _favoriteMenuIds;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<String> get categories => [
    'Semua',
    'Nasi & Lauk',
    'Mie & Bakso',
    'Dimsum & Snack',
    'Minuman',
    'Snack & Cemilan',
    'Paket Hemat',
  ];

  List<MenuItemModel> get popularMenus {
    return _allMenus.where((m) => m.isBestSeller).toList();
  }

  List<MenuItemModel> get filteredMenus {
    return _allMenus.where((menu) {
      final matchesCategory = _selectedCategory == 'Semua' || menu.category == _selectedCategory;
      final matchesCanteen = _selectedCanteenId == null || menu.canteenId == _selectedCanteenId;
      final matchesSearch = _searchQuery.isEmpty ||
          menu.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          menu.canteenName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          menu.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesCanteen && matchesSearch;
    }).toList();
  }

  void selectCanteen(String? canteenId) {
    _selectedCanteenId = canteenId;
    notifyListeners();
  }

  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _canteens = List.from(MockCanteenData.canteens);
      _allMenus = List.from(MockCanteenData.allMenus);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal memuat katalog kantin. Silakan coba lagi.';
      notifyListeners();
    }
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleFavorite(String menuId) {
    if (_favoriteMenuIds.contains(menuId)) {
      _favoriteMenuIds.remove(menuId);
    } else {
      _favoriteMenuIds.add(menuId);
    }
    notifyListeners();
  }

  bool isFavorite(String menuId) => _favoriteMenuIds.contains(menuId);

  CanteenModel? getCanteenById(String id) {
    if (_canteens.isEmpty) return null;
    try {
      final canteen = _canteens.firstWhere((c) => c.id == id, orElse: () => _canteens.first);
      // Ensure menus reflect the latest _allMenus
      final canteenMenus = _allMenus.where((m) => m.canteenId == canteen.id).toList();
      return canteen.copyWith(menus: canteenMenus);
    } catch (_) {
      return _canteens.first;
    }
  }

  List<MenuItemModel> getMenusForCanteen(String canteenId) {
    return _allMenus.where((m) => m.canteenId == canteenId).toList();
  }

  void updateMenuStock(String menuId, int newStock) {
    final index = _allMenus.indexWhere((m) => m.id == menuId);
    if (index >= 0) {
      final safeStock = newStock < 0 ? 0 : newStock;
      _allMenus[index] = _allMenus[index].copyWith(
        stock: safeStock,
        isAvailable: safeStock > 0,
      );
      _syncCanteenMenus(_allMenus[index].canteenId);
      notifyListeners();
    }
  }

  void incrementStock(String menuId, int delta) {
    final index = _allMenus.indexWhere((m) => m.id == menuId);
    if (index >= 0) {
      final current = _allMenus[index].stock;
      final safeStock = (current + delta) < 0 ? 0 : (current + delta);
      _allMenus[index] = _allMenus[index].copyWith(
        stock: safeStock,
        isAvailable: safeStock > 0,
      );
      _syncCanteenMenus(_allMenus[index].canteenId);
      notifyListeners();
    }
  }

  void toggleMenuAvailability(String menuId) {
    final index = _allMenus.indexWhere((m) => m.id == menuId);
    if (index >= 0) {
      final current = _allMenus[index].isAvailable;
      final newAvailable = !current;
      _allMenus[index] = _allMenus[index].copyWith(
        isAvailable: newAvailable,
        stock: newAvailable && _allMenus[index].stock == 0 ? 10 : _allMenus[index].stock,
      );
      _syncCanteenMenus(_allMenus[index].canteenId);
      notifyListeners();
    }
  }

  void toggleCanteenOpen(String canteenId) {
    final index = _canteens.indexWhere((c) => c.id == canteenId);
    if (index >= 0) {
      final currentOpen = _canteens[index].isOpen;
      _canteens[index] = _canteens[index].copyWith(isOpen: !currentOpen);
      notifyListeners();
    }
  }

  void addMenuItem(MenuItemModel item) {
    _allMenus.insert(0, item);
    _syncCanteenMenus(item.canteenId);
    notifyListeners();
  }

  void updateMenuItem(MenuItemModel item) {
    final index = _allMenus.indexWhere((m) => m.id == item.id);
    if (index >= 0) {
      _allMenus[index] = item;
      _syncCanteenMenus(item.canteenId);
      notifyListeners();
    }
  }

  void deleteMenuItem(String menuId) {
    final index = _allMenus.indexWhere((m) => m.id == menuId);
    if (index >= 0) {
      final canteenId = _allMenus[index].canteenId;
      _allMenus.removeAt(index);
      _syncCanteenMenus(canteenId);
      notifyListeners();
    }
  }

  void deductStockForOrder(List<dynamic> items) {
    for (final item in items) {
      final menuId = item.menuItem.id;
      final qty = item.quantity as int;
      incrementStock(menuId, -qty);
    }
  }

  void restoreStockForOrder(List<dynamic> items) {
    for (final item in items) {
      final menuId = item.menuItem.id;
      final qty = item.quantity as int;
      incrementStock(menuId, qty);
    }
  }

  void _syncCanteenMenus(String canteenId) {
    final canteenIndex = _canteens.indexWhere((c) => c.id == canteenId);
    if (canteenIndex >= 0) {
      final updatedMenus = _allMenus.where((m) => m.canteenId == canteenId).toList();
      final updatedCategories = List<String>.from(_canteens[canteenIndex].categories);
      for (final menu in updatedMenus) {
        if (!updatedCategories.contains(menu.category)) {
          updatedCategories.add(menu.category);
        }
      }
      _canteens[canteenIndex] = _canteens[canteenIndex].copyWith(
        menus: updatedMenus,
        categories: updatedCategories,
      );
    }
  }
}

