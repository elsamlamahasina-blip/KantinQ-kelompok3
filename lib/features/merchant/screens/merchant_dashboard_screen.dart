import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/state/app_state.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/image_picker_helper.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/menu_image_view.dart';
import '../../../core/widgets/status_badge.dart';
import '../../auth/models/user_model.dart';
import '../../canteen/models/menu_item_model.dart';
import '../../voucher/models/voucher_model.dart';
import '../widgets/merchant_guide_dialog.dart';
import 'merchant_menu_form_sheet.dart';
import 'merchant_order_detail_sheet.dart';
import 'merchant_voucher_form_sheet.dart';

class MerchantDashboardScreen extends StatefulWidget {
  const MerchantDashboardScreen({super.key});

  @override
  State<MerchantDashboardScreen> createState() => _MerchantDashboardScreenState();
}

class _MerchantDashboardScreenState extends State<MerchantDashboardScreen> {
  int _currentNavIndex = 0;
  int _orderSubTabIndex = 0; // 0: Antrean, 1: Dimasak, 2: Selesai

  void _openGuideDialog() {
    showDialog(
      context: context,
      builder: (_) => const MerchantGuideDialog(),
    );
  }

  void _openSwitchStallSheet() {
    final canteenCtrl = AppState.instance.canteenController;
    final authCtrl = AppState.instance.authController;
    final currentStallId = authCtrl.currentUser?.sellerCanteenId ?? 'c1';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(AppDimens.lg),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusXl)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.md),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.storefront_rounded, color: AppColors.secondary, size: 22),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pilih Stan untuk Dikelola',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        Text(
                          'Ganti stan mitra kampus untuk demo kelola merchant',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.md),
              ...canteenCtrl.canteens.map((c) {
                final isSelected = c.id == currentStallId;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: isSelected ? AppColors.secondary.withValues(alpha: 0.08) : AppColors.surfaceVariant,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                      side: BorderSide(
                        color: isSelected ? AppColors.secondary : AppColors.outline,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryContainer,
                        backgroundImage: NetworkImage(c.avatarUrl),
                        onBackgroundImageError: (_, _) {},
                        radius: 20,
                      ),
                    title: Text(
                      c.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.secondary : AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      '${c.location} • ${c.categories.isNotEmpty ? c.categories.first : "Umum"} • ${c.isOpen ? "Buka" : "Tutup"}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.secondary)
                        : const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
                    onTap: () {
                      authCtrl.setSellerCanteenId(c.id);
                      Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Beralih mengelola stan: ${c.name}'),
                              backgroundColor: AppColors.secondary,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  void _openMenuForm({MenuItemModel? itemToEdit, required String canteenId, required String canteenName}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MerchantMenuFormSheet(
        canteenId: canteenId,
        canteenName: canteenName,
        itemToEdit: itemToEdit,
      ),
    );
  }

  Future<void> _pickAndUpdateMenuImage(MenuItemModel item) async {
    final picked = await pickImageBytes();
    if (!mounted || picked == null) return;
    AppState.instance.canteenController.updateMenuItem(
      item.copyWith(imageBytes: picked.bytes),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Foto menu "${item.name}" diperbarui (${picked.name}).'),
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  void _openQuickImageSheet(MenuItemModel item, String canteenId, String canteenName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Material(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Text(
              'Tambah / Ubah Gambar: ${item.name}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            if (isDeviceImagePickerSupported)
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryContainer,
                  child: Icon(Icons.add_photo_alternate_rounded, color: AppColors.primary),
                ),
                title: const Text('Upload Gambar dari Perangkat', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: const Text('Pilih file JPG/PNG langsung untuk foto menu', style: TextStyle(fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUpdateMenuImage(item);
                },
              ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.secondaryContainer,
                child: Icon(Icons.photo_library_rounded, color: AppColors.secondary),
              ),
              title: const Text('Galeri Preset / URL Gambar & Edit Menu', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: const Text('Pilih foto makanan tersedia atau masukkan URL', style: TextStyle(fontSize: 11)),
              onTap: () {
                Navigator.pop(ctx);
                  _openMenuForm(
                    itemToEdit: item,
                    canteenId: canteenId,
                    canteenName: canteenName,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openVoucherForm({VoucherModel? voucherToEdit, required String canteenId, required String canteenName}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MerchantVoucherFormSheet(
        canteenId: canteenId,
        canteenName: canteenName,
        voucherToEdit: voucherToEdit,
      ),
    );
  }

  void _openOrderDetail(dynamic order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MerchantOrderDetailSheet(order: order),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = AppState.instance.authController;
    final canteenCtrl = AppState.instance.canteenController;
    final orderCtrl = AppState.instance.orderController;
    final voucherCtrl = AppState.instance.voucherController;

    return AnimatedBuilder(
      animation: Listenable.merge([authCtrl, canteenCtrl, orderCtrl, voucherCtrl]),
      builder: (context, _) {
        final sellerCanteenId = authCtrl.currentUser?.sellerCanteenId ?? 'c1';
        final canteen = canteenCtrl.getCanteenById(sellerCanteenId) ??
            (canteenCtrl.canteens.isNotEmpty ? canteenCtrl.canteens.first : null);

        final canteenName = canteen?.name ?? 'Kantin Bu Sri — Masakan Nusantara';
        final isOpen = canteen?.isOpen ?? true;

        final allOrders = orderCtrl.getOrdersForCanteen(sellerCanteenId);
        final waitingOrders = allOrders.where((o) => o.status == OrderStatusType.waiting).toList();
        final cookingOrders = allOrders.where((o) => o.status == OrderStatusType.cooking).toList();
        final readyAndDoneOrders = allOrders.where((o) => o.status == OrderStatusType.ready || o.status == OrderStatusType.completed).toList();

        final todayOrdersCount = orderCtrl.getTodayOrderCountForCanteen(sellerCanteenId);
        final todayRevenue = orderCtrl.getTodayRevenueForCanteen(sellerCanteenId);
        final activeQueueCount = orderCtrl.getActiveOrdersForCanteen(sellerCanteenId).length;

        final stallMenus = canteenCtrl.getMenusForCanteen(sellerCanteenId);
        final stallVouchers = voucherCtrl.getVouchersForCanteen(sellerCanteenId);
        final activeVoucherCount = stallVouchers.where((v) => v.isUsable).length;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            title: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: _openSwitchStallSheet,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  canteenName,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_drop_down_rounded, size: 18, color: AppColors.textSecondary),
                            ],
                          ),
                          Text(
                            '${canteen?.location ?? "Kantin Utama"} • Ketuk untuk ganti',
                            style: const TextStyle(fontSize: 10, color: AppColors.secondary, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              // Open/Close Switch
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Row(
                  children: [
                    Text(
                      isOpen ? 'BUKA' : 'TUTUP',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isOpen ? AppColors.secondary : AppColors.error,
                      ),
                    ),
                    Switch(
                      value: isOpen,
                      activeThumbColor: AppColors.secondary,
                      onChanged: (val) {
                        canteenCtrl.toggleCanteenOpen(sellerCanteenId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(val ? 'Stan sekarang DIBUKA untuk pesanan.' : 'Stan sekarang DITUTUP sementara.'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: IndexedStack(
            index: _currentNavIndex,
            children: [
              // Screen 1: Dashboard Pesanan (M-02)
              _buildOrdersTab(
                context,
                todayOrdersCount: todayOrdersCount,
                todayRevenue: todayRevenue,
                activeQueueCount: activeQueueCount,
                waitingOrders: waitingOrders,
                cookingOrders: cookingOrders,
                readyAndDoneOrders: readyAndDoneOrders,
                onOrderTap: _openOrderDetail,
              ),

              // Screen 2: Kelola Menu & Stok (M-04 / M-06)
              _buildMenuManagementTab(
                context,
                stallMenus: stallMenus,
                canteenId: sellerCanteenId,
                canteenName: canteenName,
              ),

              // Screen 3: Kelola Voucher Promo Stan
              _buildVouchersTab(
                context,
                stallVouchers: stallVouchers,
                canteenId: sellerCanteenId,
                canteenName: canteenName,
              ),

              // Screen 4: Profil & Pengaturan Stan (M-07)
              _buildStallSettingsTab(
                context,
                canteenName: canteenName,
                canteen: canteen,
                onOpenGuide: _openGuideDialog,
              ),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.outline, width: 1)),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentNavIndex,
              onTap: (idx) => setState(() => _currentNavIndex = idx),
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textSecondary,
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  icon: Badge(
                    isLabelVisible: waitingOrders.isNotEmpty,
                    label: Text('${waitingOrders.length}'),
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.receipt_long_outlined),
                  ),
                  activeIcon: Badge(
                    isLabelVisible: waitingOrders.isNotEmpty,
                    label: Text('${waitingOrders.length}'),
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.receipt_long_rounded),
                  ),
                  label: 'Pesanan',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.restaurant_menu_outlined),
                  activeIcon: Icon(Icons.restaurant_menu_rounded),
                  label: 'Kelola Menu',
                ),
                BottomNavigationBarItem(
                  icon: Badge(
                    isLabelVisible: activeVoucherCount > 0,
                    label: Text('$activeVoucherCount'),
                    backgroundColor: AppColors.secondary,
                    child: const Icon(Icons.confirmation_number_outlined),
                  ),
                  activeIcon: Badge(
                    isLabelVisible: activeVoucherCount > 0,
                    label: Text('$activeVoucherCount'),
                    backgroundColor: AppColors.secondary,
                    child: const Icon(Icons.confirmation_number_rounded),
                  ),
                  label: 'Voucher',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined),
                  activeIcon: Icon(Icons.settings_rounded),
                  label: 'Pengaturan',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // TAB 1: Pesanan Masuk (Kitchen Board)
  Widget _buildOrdersTab(
    BuildContext context, {
    required int todayOrdersCount,
    required double todayRevenue,
    required int activeQueueCount,
    required List<dynamic> waitingOrders,
    required List<dynamic> cookingOrders,
    required List<dynamic> readyAndDoneOrders,
    required Function(dynamic) onOrderTap,
  }) {
    return Column(
      children: [
        // Daily Performance Card
        Padding(
          padding: const EdgeInsets.fromLTRB(AppDimens.md, AppDimens.sm, AppDimens.md, AppDimens.xs),
          child: Container(
            padding: const EdgeInsets.all(AppDimens.sm + 2),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF263238), Color(0xFF37474F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              boxShadow: const [AppColors.softShadow],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _StatItem(label: 'Antrean Aktif', value: '$activeQueueCount', color: AppColors.primaryLight),
                ),
                Container(width: 1, height: 32, color: Colors.white24),
                Expanded(
                  child: _StatItem(label: 'Pesanan Hari Ini', value: '$todayOrdersCount', color: Colors.white),
                ),
                Container(width: 1, height: 32, color: Colors.white24),
                Expanded(
                  child: _StatItem(label: 'Total Omzet', value: CurrencyFormatter.format(todayRevenue), color: AppColors.accent),
                ),
              ],
            ),
          ),
        ),

        // Subtabs: Antrean, Sedang Dimasak, Selesai
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: AppDimens.xs),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          ),
          child: Row(
            children: [
              _SubTabButton(
                label: 'Antrean (${waitingOrders.length})',
                isSelected: _orderSubTabIndex == 0,
                onTap: () => setState(() => _orderSubTabIndex = 0),
              ),
              _SubTabButton(
                label: 'Dimasak (${cookingOrders.length})',
                isSelected: _orderSubTabIndex == 1,
                onTap: () => setState(() => _orderSubTabIndex = 1),
              ),
              _SubTabButton(
                label: 'Siap / Selesai (${readyAndDoneOrders.length})',
                isSelected: _orderSubTabIndex == 2,
                onTap: () => setState(() => _orderSubTabIndex = 2),
              ),
            ],
          ),
        ),

        // Orders List
        Expanded(
          child: Builder(
            builder: (_) {
              List<dynamic> targetList;
              if (_orderSubTabIndex == 0) {
                targetList = waitingOrders;
              } else if (_orderSubTabIndex == 1) {
                targetList = cookingOrders;
              } else {
                targetList = readyAndDoneOrders;
              }

              if (targetList.isEmpty) {
                return Center(
                  child: EmptyStateView(
                    icon: _orderSubTabIndex == 0
                        ? Icons.hourglass_empty_rounded
                        : _orderSubTabIndex == 1
                            ? Icons.soup_kitchen_rounded
                            : Icons.check_circle_outline_rounded,
                    title: _orderSubTabIndex == 0
                        ? 'Belum Ada Antrean Baru'
                        : _orderSubTabIndex == 1
                            ? 'Tidak Ada yang Sedang Dimasak'
                            : 'Belum Ada Pesanan Selesai',
                    message: 'Pesanan dari pembeli akan muncul otomatis di sini.',
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(AppDimens.md),
                itemCount: targetList.length,
                separatorBuilder: (_, _) => const SizedBox(height: AppDimens.sm),
                itemBuilder: (context, idx) {
                  final order = targetList[idx];
                  return _MerchantOrderCard(
                    order: order,
                    onTap: () => onOrderTap(order),
                    onQuickAction: () {
                      if (order.status == OrderStatusType.waiting) {
                        AppState.instance.orderController.updateOrderStatus(order.id, OrderStatusType.cooking);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Pesanan ${order.queueNumber} mulai dimasak!'),
                            backgroundColor: AppColors.warning,
                          ),
                        );
                      } else if (order.status == OrderStatusType.cooking) {
                        AppState.instance.orderController.updateOrderStatus(order.id, OrderStatusType.ready);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Pesanan ${order.queueNumber} siap diambil pembeli!'),
                            backgroundColor: AppColors.secondary,
                          ),
                        );
                      }
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // TAB 2: Kelola Menu & Stok (M-04 / M-06)
  Widget _buildMenuManagementTab(
    BuildContext context, {
    required List<MenuItemModel> stallMenus,
    required String canteenId,
    required String canteenName,
  }) {
    final canteenCtrl = AppState.instance.canteenController;

    return Column(
      children: [
        // Top Action Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(AppDimens.md, AppDimens.md, AppDimens.md, AppDimens.xs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Katalog Menu Stan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('${stallMenus.length} Menu Terdaftar', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _openMenuForm(canteenId: canteenId, canteenName: canteenName),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Tambah Menu', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusSm)),
                ),
              ),
            ],
          ),
        ),

        // Menu List with Quick Stock controls (+ / -) & "+ Tambah Gambar / Menu Baru" item
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(AppDimens.md),
            itemCount: stallMenus.isEmpty ? 2 : stallMenus.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: AppDimens.sm),
            itemBuilder: (context, idx) {
              if (idx == 0) {
                return InkWell(
                  onTap: () => _openMenuForm(canteenId: canteenId, canteenName: canteenName),
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  child: Container(
                    padding: const EdgeInsets.all(AppDimens.sm + 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.45),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_rounded, color: AppColors.primary, size: 24),
                              SizedBox(height: 2),
                              Text(
                                '+ Foto',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppDimens.sm),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '+ Tambah Gambar & Menu Baru',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Upload foto dari perangkat, URL, atau pilih galeri untuk menu baru',
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.primary),
                      ],
                    ),
                  ),
                );
              }

              if (stallMenus.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: AppDimens.lg),
                  child: EmptyStateView(
                    icon: Icons.restaurant_menu_rounded,
                    title: 'Belum Ada Menu',
                    message: 'Ketuk item "+ Tambah Gambar & Menu Baru" di atas untuk menambahkan menu pertama stan Anda.',
                  ),
                );
              }

              final item = stallMenus[idx - 1];
              return Container(
                padding: const EdgeInsets.all(AppDimens.sm),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  border: Border.all(color: AppColors.outline),
                  boxShadow: const [AppColors.softShadow],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Tappable Thumbnail with camera badge for adding/changing image
                    InkWell(
                      onTap: () => _openQuickImageSheet(item, canteenId, canteenName),
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: MenuImageView(
                                imageUrl: item.imageUrl,
                                imageBytes: item.imageBytes,
                                width: 60,
                                height: 60,
                              ),
                            ),
                            Positioned(
                              right: 2,
                              bottom: 2,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.72),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Icon(
                                  Icons.add_a_photo_rounded,
                                  color: Colors.white,
                                  size: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimens.sm),

                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  CurrencyFormatter.format(item.price),
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: item.isOutOfStock ? AppColors.errorContainer : AppColors.secondaryContainer,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item.isOutOfStock ? 'HABIS' : 'Sisa ${item.stock} porsi',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: item.isOutOfStock ? AppColors.error : AppColors.secondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Quick Stock Stepper (+ / -)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.primary, size: 22),
                                onPressed: item.stock > 0
                                    ? () => canteenCtrl.incrementStock(item.id, -1)
                                    : null,
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(4),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  '${item.stock}',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 22),
                                onPressed: () => canteenCtrl.incrementStock(item.id, 1),
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(4),
                              ),
                            ],
                          ),

                          // Edit & Delete actions
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert_rounded, size: 18, color: AppColors.textSecondary),
                            onSelected: (val) {
                              if (val == 'edit') {
                                _openMenuForm(
                                  itemToEdit: item,
                                  canteenId: canteenId,
                                  canteenName: canteenName,
                                );
                              } else if (val == 'toggle') {
                                canteenCtrl.toggleMenuAvailability(item.id);
                              } else if (val == 'delete') {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Hapus Menu?'),
                                    content: Text('Menu "${item.name}" akan dihapus dari katalog stan.'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                                      ElevatedButton(
                                        onPressed: () {
                                          canteenCtrl.deleteMenuItem(item.id);
                                          Navigator.pop(ctx);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Menu "${item.name}" berhasil dihapus.')),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
                                        child: const Text('Hapus'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(value: 'edit', child: Text('Ubah Data & Foto Menu')),
                              PopupMenuItem(
                                value: 'toggle',
                                child: Text(item.isAvailable ? 'Tandai Habis' : 'Tandai Tersedia'),
                              ),
                              const PopupMenuItem(value: 'delete', child: Text('Hapus Menu', style: TextStyle(color: AppColors.error))),
                            ],
                          ),
                        ],
                      ),
                    );
            },
          ),
        ),
      ],
    );
  }

  // TAB 3: Kelola Voucher Promo Stan
  Widget _buildVouchersTab(
    BuildContext context, {
    required List<VoucherModel> stallVouchers,
    required String canteenId,
    required String canteenName,
  }) {
    final voucherCtrl = AppState.instance.voucherController;
    final activeCount = stallVouchers.where((v) => v.isUsable).length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppDimens.md, AppDimens.md, AppDimens.md, AppDimens.xs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Voucher Promo Stan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(
                      '$activeCount dari ${stallVouchers.length} voucher aktif untuk pembeli',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _openVoucherForm(canteenId: canteenId, canteenName: canteenName),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Buat Voucher', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusSm)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: stallVouchers.isEmpty
              ? Center(
                  child: EmptyStateView(
                    icon: Icons.confirmation_number_outlined,
                    title: 'Belum Ada Voucher Stan',
                    message: 'Buat promo khusus stan Anda agar pelanggan semakin sering memesan.',
                    buttonText: '+ Buat Voucher Pertama',
                    onButtonPressed: () => _openVoucherForm(canteenId: canteenId, canteenName: canteenName),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppDimens.md),
                  itemCount: stallVouchers.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppDimens.sm),
                  itemBuilder: (context, idx) {
                    final v = stallVouchers[idx];
                    return Container(
                      padding: const EdgeInsets.all(AppDimens.md),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                        border: Border.all(
                          color: v.isUsable ? AppColors.primary.withValues(alpha: 0.35) : AppColors.outline,
                        ),
                        boxShadow: const [AppColors.softShadow],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: v.isUsable ? AppColors.primaryContainer : AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  v.code,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: v.isUsable ? AppColors.primaryDark : AppColors.textMuted,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: v.isUsable ? AppColors.secondaryContainer : AppColors.errorContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  !v.isActive
                                      ? 'NONAKTIF'
                                      : (!v.hasQuota ? 'KUOTA HABIS' : 'AKTIF'),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: v.isUsable ? AppColors.secondaryDark : AppColors.error,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Switch.adaptive(
                                value: v.isActive,
                                activeTrackColor: AppColors.secondary,
                                onChanged: (_) => voucherCtrl.toggleVoucherStatus(v.id),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            v.title,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            v.description,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    Text(
                                      'Potongan ${CurrencyFormatter.format(v.discountAmount)}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    Text(
                                      v.minPurchase > 0
                                          ? '• Min. ${CurrencyFormatter.format(v.minPurchase)}'
                                          : '• Tanpa min. belanja',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                    ),
                                    Text(
                                      '• Terpakai ${v.usedCount}/${v.quota}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                                tooltip: 'Ubah Voucher',
                                onPressed: () => _openVoucherForm(
                                  voucherToEdit: v,
                                  canteenId: canteenId,
                                  canteenName: canteenName,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                                tooltip: 'Hapus Voucher',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Hapus Voucher?'),
                                      content: Text('Voucher "${v.code}" akan dihapus dari promo stan.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text('Batal'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.error,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () {
                                            Navigator.pop(ctx);
                                            voucherCtrl.deleteVoucher(v.id);
                                          },
                                          child: const Text('Hapus'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // TAB 4: Profil & Pengaturan Stan (M-07)
  Widget _buildStallSettingsTab(
    BuildContext context, {
    required String canteenName,
    required dynamic canteen,
    required VoidCallback onOpenGuide,
  }) {
    final authCtrl = AppState.instance.authController;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.md),
      child: Column(
        children: [
          // Stan Profile Card
          Container(
            padding: const EdgeInsets.all(AppDimens.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              border: Border.all(color: AppColors.outline),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primaryContainer,
                  backgroundImage: canteen != null ? NetworkImage(canteen.avatarUrl) : null,
                  onBackgroundImageError: canteen != null ? (_, _) {} : null,
                  child: canteen == null
                      ? const Icon(Icons.storefront_rounded, size: 32, color: AppColors.primary)
                      : null,
                ),
                const SizedBox(width: AppDimens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        canteenName,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        canteen?.location ?? 'Stan Kantin Utama',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Jam Operasional: ${canteen?.openHours ?? "07:30 - 16:30 WIB"}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimens.md),

          // Menu Actions Group
          Material(
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              side: const BorderSide(color: AppColors.outline),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.store_mall_directory_rounded, color: AppColors.secondary),
                  title: const Text('Ganti Stan yang Dikelola (Multi-Tenant Demo)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  subtitle: Text('Kelola stan mitra: $canteenName', style: const TextStyle(fontSize: 11)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: _openSwitchStallSheet,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.menu_book_rounded, color: AppColors.primary),
                  title: const Text('Panduan Singkat Penjual (Tutorial)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Pelajari cara mengelola antrean dan stok stan', style: TextStyle(fontSize: 11)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: onOpenGuide,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.swap_horiz_rounded, color: AppColors.secondary),
                  title: const Text('Beralih ke Aplikasi Mahasiswa', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                  subtitle: const Text('Buka tampilan untuk memesan makanan', style: TextStyle(fontSize: 11)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () {
                    authCtrl.switchRole(UserRole.buyer);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Beralih ke Mode Mahasiswa / Pembeli'),
                        backgroundColor: AppColors.secondary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimens.lg),

          // Logout Button
          AppButton(
            text: 'Keluar dari Akun Stan',
            variant: AppButtonVariant.danger,
            icon: const Icon(Icons.logout_rounded, size: 18),
            onPressed: () {
              authCtrl.logout();
            },
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.white70),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SubTabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SubTabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            boxShadow: isSelected ? const [AppColors.softShadow] : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

class _MerchantOrderCard extends StatelessWidget {
  final dynamic order;
  final VoidCallback onTap;
  final VoidCallback onQuickAction;

  const _MerchantOrderCard({
    required this.order,
    required this.onTap,
    required this.onQuickAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(
          color: order.status == OrderStatusType.waiting
              ? AppColors.primary
              : AppColors.outline,
          width: order.status == OrderStatusType.waiting ? 1.5 : 1,
        ),
        boxShadow: const [AppColors.softShadow],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            order.queueNumber,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                          ),
                        ),
                        const SizedBox(width: AppDimens.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.customerName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                order.orderTypeLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(status: order.status),
                ],
              ),
              const Divider(height: 18),
              Text(
                order.items.map((i) => "${i.quantity}x ${i.menuItem.name}").join(", "),
                style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (order.notes != null && order.notes!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Catatan: "${order.notes}"',
                  style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.warning),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      CurrencyFormatter.format(order.totalAmount),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (order.status == OrderStatusType.waiting)
                    ElevatedButton.icon(
                      onPressed: onQuickAction,
                      icon: const Icon(Icons.soup_kitchen_rounded, size: 14),
                      label: const Text('Mulai Masak', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warning,
                        foregroundColor: Colors.white,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                    )
                  else if (order.status == OrderStatusType.cooking)
                    ElevatedButton.icon(
                      onPressed: onQuickAction,
                      icon: const Icon(Icons.check_circle_rounded, size: 14),
                      label: const Text('Makanan Siap', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                    )
                  else
                    const Row(
                      children: [
                        Text('Lihat Rincian', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios_rounded, size: 11, color: AppColors.primary),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
