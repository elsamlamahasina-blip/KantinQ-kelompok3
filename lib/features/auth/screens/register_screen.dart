import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';

import '../../../core/state/app_state.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

import '../models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  UserRole _selectedRole = UserRole.buyer;
  String _selectedCanteenId = 'c1';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authCtrl = AppState.instance.authController;
      final success = await authCtrl.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _phoneController.text.trim(),
        _passwordController.text.trim(),
        role: _selectedRole,
        sellerCanteenId: _selectedRole == UserRole.seller ? _selectedCanteenId : null,
      );

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _selectedRole == UserRole.seller
                  ? 'Pendaftaran Stan Berhasil! Selamat datang di Dashboard Merchant.'
                  : 'Pendaftaran berhasil! Selamat datang di KantinQ.',
            ),
            backgroundColor: AppColors.secondary,
          ),
        );
      } else if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authCtrl.errorMessage ?? 'Gagal mendaftar'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = AppState.instance.authController;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Buat Akun Baru'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Daftar KantinQ',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Nikmati kemudahan pesan makanan bebas antre di kantin',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppDimens.lg),

                // Role selector
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedRole = UserRole.buyer;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _selectedRole == UserRole.buyer
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.school_outlined,
                                    size: 18,
                                    color: _selectedRole == UserRole.buyer
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Mahasiswa',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: _selectedRole == UserRole.buyer
                                            ? Colors.white
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedRole = UserRole.seller;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _selectedRole == UserRole.seller
                                  ? AppColors.secondary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.storefront_rounded,
                                    size: 18,
                                    color: _selectedRole == UserRole.seller
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Penjual Stan',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: _selectedRole == UserRole.seller
                                            ? Colors.white
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.md),

                Container(
                  padding: const EdgeInsets.all(AppDimens.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                    border: Border.all(color: AppColors.outline),
                    boxShadow: const [AppColors.softShadow],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_selectedRole == UserRole.seller) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: AppDimens.md),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline, color: AppColors.secondary, size: 20),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Pilih stan kantin yang Anda kelola untuk mengatur pesanan dan stok menu.',
                                  style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Text(
                          'Pilih Stan Kantin',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                            border: Border.all(color: AppColors.outline),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCanteenId,
                              isExpanded: true,
                              items: AppState.instance.canteenController.canteens.map((c) {
                                return DropdownMenuItem(
                                  value: c.id,
                                  child: Text(
                                    '${c.name} (${c.location})',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedCanteenId = val;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimens.md),
                      ],
                      AppTextField(
                        controller: _nameController,
                        label: 'Nama Lengkap',
                        hint: 'Contoh: Budi Santoso',
                        prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Nama lengkap wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimens.sm),
                      AppTextField(
                        controller: _emailController,
                        label: 'Alamat Email',
                        hint: 'nama@kampus.ac.id',
                        prefixIcon: const Icon(Icons.email_outlined, size: 20),
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Email wajib diisi';
                          }
                          if (!val.contains('@')) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimens.sm),
                      AppTextField(
                        controller: _phoneController,
                        label: 'Nomor WhatsApp / HP',
                        hint: '0812xxxxxxxx',
                        prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                        keyboardType: TextInputType.phone,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Nomor HP wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimens.sm),
                      AppTextField(
                        controller: _passwordController,
                        label: 'Kata Sandi',
                        hint: 'Minimal 6 karakter',
                        isPassword: true,
                        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                        validator: (val) {
                          if (val == null || val.length < 6) {
                            return 'Kata sandi minimal 6 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimens.lg),
                      AnimatedBuilder(
                        animation: authCtrl,
                        builder: (context, _) {
                          return AppButton(
                            text: 'Daftar Sekarang',
                            isLoading: authCtrl.isLoading,
                            onPressed: _onRegister,
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimens.lg),

                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    const Text('Sudah memiliki akun? ', style: TextStyle(color: AppColors.textSecondary)),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Masuk di Sini',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
