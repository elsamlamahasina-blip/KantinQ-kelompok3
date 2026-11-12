import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/state/app_state.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showEditProfileDialog(BuildContext context) {
    final authCtrl = AppState.instance.authController;
    final user = authCtrl.currentUser;
    final nameCtrl = TextEditingController(text: user?.name ?? '');
    final phoneCtrl = TextEditingController(text: user?.phone ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: nameCtrl,
              label: 'Nama Lengkap',
            ),
            const SizedBox(height: AppDimens.sm),
            AppTextField(
              controller: phoneCtrl,
              label: 'Nomor Handphone',
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              authCtrl.updateProfile(
                name: nameCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profil berhasil diperbarui!'),
                  backgroundColor: AppColors.secondary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showFaqDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Pusat Bantuan & FAQ'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('1. Bagaimana cara mengambil pesanan?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text('Tunjukkan Nomor Antrean atau QR Code di layar Pesanan kepada penjual stan kantin saat status pesanan menjadi "Siap Diambil".', style: TextStyle(fontSize: 12)),
              SizedBox(height: 10),
              Text('2. Apakah bisa membatalkan pesanan?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text('Pesanan hanya dapat dibatalkan selama masih dalam status "Menunggu Konfirmasi". Jika sudah dimasak, pesanan tidak dapat dibatalkan.', style: TextStyle(fontSize: 12)),
              SizedBox(height: 10),
              Text('3. Bagaimana cara pembayaran COD (Bayar di Tempat)?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text('Cukup pesan menu melalui aplikasi tanpa perlu saldo digital. Saat pesanan berstatus "Siap Diambil", datang ke kasir stan dan bayar tunai sesuai struk.', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  void _showVouchersDialog(BuildContext context) {
    final voucherCtrl = AppState.instance.voucherController;
    final activeVouchers = voucherCtrl.activeVouchers;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kupon & Voucher KantinQ'),
        content: SizedBox(
          width: double.maxFinite,
          child: activeVouchers.isEmpty
              ? const Text('Belum ada voucher promo aktif saat ini.')
              : ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 360),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: activeVouchers.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, idx) {
                      final v = activeVouchers[idx];
                      return _VoucherItem(
                        code: v.code,
                        discount: 'Diskon ${CurrencyFormatter.format(v.discountAmount)}',
                        desc: v.description,
                        stallLabel: v.isGlobal ? 'Semua Stan KantinQ' : (v.canteenName ?? 'Stan Mitra'),
                        quotaLabel: 'Sisa kuota: ${v.remainingQuota}',
                        onCopy: () {
                          Clipboard.setData(ClipboardData(text: v.code));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Kode "${v.code}" disalin ke clipboard!'),
                              backgroundColor: AppColors.secondary,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = AppState.instance.authController;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil Akun'),
      ),
      body: AnimatedBuilder(
        animation: authCtrl,
        builder: (context, _) {
          final user = authCtrl.currentUser;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.md),
            child: Column(
              children: [
                // Profile Header Card
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
                        radius: 32,
                        backgroundColor: AppColors.primaryContainer,
                        backgroundImage: user != null ? NetworkImage(user.avatarUrl) : null,
                        onBackgroundImageError: user != null ? (_, _) {} : null,
                        child: user == null
                            ? const Icon(Icons.person_rounded, size: 36, color: AppColors.primary)
                            : null,
                      ),
                      const SizedBox(width: AppDimens.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'Pengguna Tamu',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.email ?? 'tamu@kantinq.com',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.accentLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.verified_rounded, size: 12, color: AppColors.accent),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      user?.memberTier ?? 'Member KantinQ',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFF57F17),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                        onPressed: () => _showEditProfileDialog(context),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimens.md),

                // Settings Menu Group
                Material(
                  color: AppColors.surface,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    side: const BorderSide(color: AppColors.outline),
                  ),
                  child: Column(
                    children: [
                      _ProfileMenuItem(
                        icon: Icons.confirmation_number_outlined,
                        title: 'Voucher & Promo Saya',
                        onTap: () => _showVouchersDialog(context),
                      ),
                      const Divider(height: 1),
                      _ProfileMenuItem(
                        icon: Icons.security_rounded,
                        title: 'Keamanan Akun & Verifikasi',
                        onTap: () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Keamanan akun aktif dan terverifikasi.'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _ProfileMenuItem(
                        icon: Icons.help_outline_rounded,
                        title: 'Pusat Bantuan & FAQ',
                        onTap: () => _showFaqDialog(context),
                      ),
                      const Divider(height: 1),
                      _ProfileMenuItem(
                        icon: Icons.info_outline_rounded,
                        title: 'Tentang Aplikasi KantinQ',
                        subtitle: 'Versi 1.0.0+1 (Build Stable)',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimens.lg),

                // Logout Button
                AppButton(
                  text: 'Keluar dari Akun',
                  variant: AppButtonVariant.danger,
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Konfirmasi Keluar'),
                        content: const Text('Apakah Anda yakin ingin keluar dari akun KantinQ?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () {
                              authCtrl.logout();
                              Navigator.pop(ctx);
                            },
                            child: const Text('Keluar', style: TextStyle(color: AppColors.error)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)) : null,
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}

class _VoucherItem extends StatelessWidget {
  final String code;
  final String discount;
  final String desc;
  final String stallLabel;
  final String quotaLabel;
  final VoidCallback onCopy;

  const _VoucherItem({
    required this.code,
    required this.discount,
    required this.desc,
    required this.stallLabel,
    required this.quotaLabel,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onCopy,
      borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.sm),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    code,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  discount,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '$stallLabel • $quotaLabel',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
            ),
            const SizedBox(height: 2),
            Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
