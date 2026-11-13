import 'package:flutter/foundation.dart';

import '../../../core/utils/currency_formatter.dart';
import '../models/voucher_model.dart';

typedef VoucherValidationResult = ({
  bool isValid,
  String message,
  double discount,
  VoucherModel? voucher,
});

class VoucherController extends ChangeNotifier {
  final List<VoucherModel> _vouchers = [
    // Promo spesifik setiap akun penjual stan kantin (c1 - c5)
    // Berlaku khusus dalam satu stan (tidak bercampur ke stan lain)
    const VoucherModel(
      id: 'v_c1_1',
      code: 'BUSRI5RB',
      title: 'Promo Kantin Bu Sri 5Rb',
      description: 'Potongan langsung Rp 5.000 khusus pesanan di Kantin Bu Sri min. belanja Rp 20.000.',
      canteenId: 'c1',
      canteenName: 'Kantin Bu Sri — Masakan Nusantara',
      discountAmount: 5000,
      minPurchase: 20000,
      quota: 100,
    ),
    const VoucherModel(
      id: 'v_c1_2',
      code: 'LUNCHBUSRI',
      title: 'Hemat Makan Siang Bu Sri',
      description: 'Diskon Rp 3.000 untuk semua lauk & paket nasi Bu Sri min. belanja Rp 12.000.',
      canteenId: 'c1',
      canteenName: 'Kantin Bu Sri — Masakan Nusantara',
      discountAmount: 3000,
      minPurchase: 12000,
      quota: 60,
    ),
    const VoucherModel(
      id: 'v_c1_3',
      code: 'KANTINQHEMAT',
      title: 'Voucher Hemat Bu Sri',
      description: 'Potongan Rp 5.000 khusus pesanan di Kantin Bu Sri tanpa minimal pembelian.',
      canteenId: 'c1',
      canteenName: 'Kantin Bu Sri — Masakan Nusantara',
      discountAmount: 5000,
      minPurchase: 0,
      quota: 999,
    ),
    const VoucherModel(
      id: 'v_c2_1',
      code: 'MASJONI4RB',
      title: 'Traktiran Bakso Mas Joni',
      description: 'Potongan Rp 4.000 untuk bakso & mie ayam Mas Joni min. belanja Rp 15.000.',
      canteenId: 'c2',
      canteenName: 'Stan Bakso & Mie Mas Joni',
      discountAmount: 4000,
      minPurchase: 15000,
      quota: 80,
    ),
    const VoucherModel(
      id: 'v_c2_2',
      code: 'JONIKOMPLIT',
      title: 'Paket Komplit Mas Joni',
      description: 'Diskon Rp 5.000 khusus pesanan di Stan Bakso & Mie Mas Joni min. belanja Rp 20.000.',
      canteenId: 'c2',
      canteenName: 'Stan Bakso & Mie Mas Joni',
      discountAmount: 5000,
      minPurchase: 20000,
      quota: 100,
    ),
    const VoucherModel(
      id: 'v_c3_1',
      code: 'GEPREK5RB',
      title: 'Promo Geprek Pedas Hemat',
      description: 'Diskon Rp 5.000 di Ayam Geprek Kampus Juara untuk transaksi min. Rp 18.000.',
      canteenId: 'c3',
      canteenName: 'Ayam Geprek Kampus Juara',
      discountAmount: 5000,
      minPurchase: 18000,
      quota: 100,
    ),
    const VoucherModel(
      id: 'v_c4_1',
      code: 'DIMSUM5RB',
      title: 'Paket Ngemil & Ngopi Kampus',
      description: 'Potongan Rp 5.000 di KantinQ Dimsum Bar & Kopi min. belanja Rp 20.000.',
      canteenId: 'c4',
      canteenName: 'KantinQ Dimsum Bar & Kopi',
      discountAmount: 5000,
      minPurchase: 20000,
      quota: 75,
    ),
    const VoucherModel(
      id: 'v_c5_1',
      code: 'SEHAT3RB',
      title: 'Promo Menu Sehat Bu Dewi',
      description: 'Hemat Rp 3.000 di Dapur Sehat Bu Dewi min. belanja Rp 15.000.',
      canteenId: 'c5',
      canteenName: 'Dapur Sehat Bu Dewi — Salad & Jus',
      discountAmount: 3000,
      minPurchase: 15000,
      quota: 60,
    ),
  ];

  List<VoucherModel> get allVouchers => List.unmodifiable(_vouchers);

  List<VoucherModel> get activeVouchers =>
      _vouchers.where((v) => v.isUsable).toList();

  List<VoucherModel> get activeCanteenVouchers =>
      _vouchers.where((v) => v.isUsable).toList();

  List<VoucherModel> getVouchersForCanteen(String canteenId) =>
      _vouchers.where((v) => v.canteenId == canteenId).toList();

  List<VoucherModel> getActiveVouchersForCanteen(String canteenId) =>
      _vouchers.where((v) => v.canteenId == canteenId && v.isUsable).toList();

  List<VoucherModel> getAvailableVouchersForCart(String? cartCanteenId) {
    if (cartCanteenId == null || cartCanteenId.isEmpty) return const [];
    final matching = _vouchers.where((v) {
      if (!v.isUsable) return false;
      return v.canteenId == cartCanteenId;
    }).toList();

    matching.sort((a, b) => b.discountAmount.compareTo(a.discountAmount));
    return matching;
  }

  VoucherModel? findByCode(String code) {
    final clean = code.trim().toUpperCase();
    if (clean.isEmpty) return null;
    for (final v in _vouchers) {
      if (v.code == clean) return v;
    }
    return null;
  }

  bool isCodeTaken(String code, {String? excludeVoucherId}) {
    final clean = code.trim().toUpperCase();
    return _vouchers.any(
      (v) => v.code == clean && v.id != excludeVoucherId,
    );
  }

  VoucherValidationResult validateVoucher(
    String code, {
    required double subtotal,
    String? cartCanteenId,
  }) {
    final clean = code.trim().toUpperCase();
    if (clean.isEmpty) {
      return (
        isValid: false,
        message: 'Masukkan kode voucher terlebih dahulu.',
        discount: 0,
        voucher: null,
      );
    }

    final voucher = findByCode(clean);
    if (voucher == null) {
      return (
        isValid: false,
        message: 'Kode voucher "$clean" tidak ditemukan.',
        discount: 0,
        voucher: null,
      );
    }

    if (!voucher.isActive) {
      return (
        isValid: false,
        message: 'Voucher "$clean" sedang dinonaktifkan penjual.',
        discount: 0,
        voucher: voucher,
      );
    }

    if (!voucher.hasQuota) {
      return (
        isValid: false,
        message: 'Kuota voucher "$clean" sudah habis.',
        discount: 0,
        voucher: voucher,
      );
    }

    if (subtotal <= 0) {
      return (
        isValid: false,
        message: 'Tambahkan menu ke keranjang terlebih dahulu.',
        discount: 0,
        voucher: voucher,
      );
    }

    if (cartCanteenId == null || cartCanteenId.isEmpty) {
      return (
        isValid: false,
        message: 'Pilih menu makanan terlebih dahulu sebelum menerapkan voucher.',
        discount: 0,
        voucher: voucher,
      );
    }

    if (voucher.canteenId != cartCanteenId) {
      final stallLabel = voucher.canteenName ?? 'stan penerbit voucher';
      return (
        isValid: false,
        message: 'Voucher "$clean" hanya berlaku untuk pesanan di $stallLabel.',
        discount: 0,
        voucher: voucher,
      );
    }

    if (subtotal < voucher.minPurchase) {
      return (
        isValid: false,
        message:
            'Minimal belanja ${CurrencyFormatter.format(voucher.minPurchase)} untuk memakai "$clean".',
        discount: 0,
        voucher: voucher,
      );
    }

    final appliedDiscount =
        voucher.discountAmount > subtotal ? subtotal : voucher.discountAmount;
    return (
      isValid: true,
      message:
          'Voucher "$clean" berhasil diterapkan! Hemat ${CurrencyFormatter.format(appliedDiscount)}.',
      discount: appliedDiscount,
      voucher: voucher,
    );
  }

  ({bool success, String message}) addVoucher(VoucherModel voucher) {
    if (voucher.canteenId == null || voucher.canteenId!.isEmpty) {
      return (
        success: false,
        message: 'Voucher harus terikat ke satu akun stan kantin.',
      );
    }
    final cleanCode = voucher.code.trim().toUpperCase();
    if (cleanCode.length < 3) {
      return (
        success: false,
        message: 'Kode voucher minimal 3 karakter.',
      );
    }
    if (isCodeTaken(cleanCode)) {
      return (
        success: false,
        message: 'Kode voucher "$cleanCode" sudah digunakan.',
      );
    }
    _vouchers.insert(0, voucher.copyWith(code: cleanCode));
    notifyListeners();
    return (
      success: true,
      message: 'Voucher "$cleanCode" berhasil dibuat!',
    );
  }

  ({bool success, String message}) updateVoucher(VoucherModel updated) {
    final cleanCode = updated.code.trim().toUpperCase();
    if (cleanCode.length < 3) {
      return (
        success: false,
        message: 'Kode voucher minimal 3 karakter.',
      );
    }
    if (isCodeTaken(cleanCode, excludeVoucherId: updated.id)) {
      return (
        success: false,
        message: 'Kode voucher "$cleanCode" sudah digunakan.',
      );
    }
    final index = _vouchers.indexWhere((v) => v.id == updated.id);
    if (index < 0) {
      return (
        success: false,
        message: 'Voucher tidak ditemukan.',
      );
    }
    _vouchers[index] = updated.copyWith(code: cleanCode);
    notifyListeners();
    return (
      success: true,
      message: 'Voucher "$cleanCode" berhasil diperbarui!',
    );
  }

  void toggleVoucherStatus(String voucherId) {
    final index = _vouchers.indexWhere((v) => v.id == voucherId);
    if (index >= 0) {
      final current = _vouchers[index];
      _vouchers[index] = current.copyWith(isActive: !current.isActive);
      notifyListeners();
    }
  }

  void deleteVoucher(String voucherId) {
    _vouchers.removeWhere((v) => v.id == voucherId);
    notifyListeners();
  }

  void markVoucherUsed(String? code) {
    if (code == null || code.trim().isEmpty) return;
    final clean = code.trim().toUpperCase();
    final index = _vouchers.indexWhere((v) => v.code == clean);
    if (index >= 0) {
      final current = _vouchers[index];
      _vouchers[index] = current.copyWith(usedCount: current.usedCount + 1);
      notifyListeners();
    }
  }
}
