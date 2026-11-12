import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthController extends ChangeNotifier {
  UserModel? _currentUser = const UserModel(
    id: 'u1',
    name: 'Rian Pratama',
    email: 'rian.pratama@kampus.ac.id',
    phone: '081234567890',
    avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
    campusLocation: 'Kantin Utama — Gedung A Lt. 1',
    memberTier: 'KantinQ Gold Member',
  );

  bool _isLoggedIn = true;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login(
    String email,
    String password, {
    UserRole role = UserRole.buyer,
    String? sellerCanteenId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    if (email.trim().isEmpty || password.trim().isEmpty) {
      _errorMessage = 'Email dan password wajib diisi';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final isMerchant = role == UserRole.seller || email.contains('penjual') || email.contains('merchant');
    final actualRole = isMerchant ? UserRole.seller : UserRole.buyer;

    _currentUser = UserModel(
      id: isMerchant ? 'seller_c1' : 'u1',
      name: isMerchant ? 'Pengelola KantinQ' : email.split('@').first,
      email: email,
      phone: isMerchant ? '081298765432' : '081234567890',
      avatarUrl: isMerchant
          ? 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80'
          : 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
      campusLocation: isMerchant ? 'Kantin Utama Lt. 1' : 'Kantin Utama — Gedung A Lt. 1',
      memberTier: isMerchant ? 'Mitra Merchant KantinQ' : 'KantinQ Gold Member',
      role: actualRole,
      sellerCanteenId: actualRole == UserRole.seller ? (sellerCanteenId ?? 'c1') : null,
    );
    _isLoggedIn = true;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> register(
    String name,
    String email,
    String phone,
    String password, {
    UserRole role = UserRole.buyer,
    String? sellerCanteenId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      _errorMessage = 'Semua data pendaftaran wajib diisi';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _currentUser = UserModel(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      avatarUrl: role == UserRole.seller
          ? 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80'
          : 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
      role: role,
      sellerCanteenId: sellerCanteenId ?? (role == UserRole.seller ? 'c1' : null),
      memberTier: role == UserRole.seller ? 'Mitra Merchant KantinQ' : 'KantinQ Silver Member',
    );
    _isLoggedIn = true;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  void switchRole(UserRole newRole, {String? sellerCanteenId}) {
    if (_currentUser == null) {
      if (newRole == UserRole.seller) {
        loginAsDemoSeller();
      } else {
        loginAsDemoBuyer();
      }
      return;
    }

    _currentUser = _currentUser!.copyWith(
      role: newRole,
      sellerCanteenId: newRole == UserRole.seller
          ? (sellerCanteenId ?? _currentUser!.sellerCanteenId ?? 'c1')
          : null,
      memberTier: newRole == UserRole.seller
          ? 'Mitra Merchant KantinQ'
          : 'KantinQ Gold Member',
    );
    notifyListeners();
  }

  void loginAsDemoBuyer() {
    _currentUser = const UserModel(
      id: 'u1',
      name: 'Rian Pratama',
      email: 'rian.pratama@kampus.ac.id',
      phone: '081234567890',
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
      campusLocation: 'Kantin Utama — Gedung A Lt. 1',
      memberTier: 'KantinQ Gold Member',
      role: UserRole.buyer,
    );
    _isLoggedIn = true;
    notifyListeners();
  }

  void loginAsDemoSeller({String canteenId = 'c1'}) {
    _currentUser = UserModel(
      id: 'seller_$canteenId',
      name: 'Pengelola KantinQ (Mitra Terpadu)',
      email: 'merchant@kantinq.com',
      phone: '081298765432',
      avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80',
      campusLocation: 'Kantin Utama Lt. 1',
      memberTier: 'Mitra Merchant Terpadu',
      role: UserRole.seller,
      sellerCanteenId: canteenId,
    );
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _currentUser = null;
    notifyListeners();
  }

  void updateProfile({required String name, required String phone}) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(name: name, phone: phone);
      notifyListeners();
    }
  }

  void setSellerCanteenId(String canteenId) {
    if (_currentUser != null && _currentUser!.role == UserRole.seller) {
      _currentUser = _currentUser!.copyWith(sellerCanteenId: canteenId);
      notifyListeners();
    }
  }
}
