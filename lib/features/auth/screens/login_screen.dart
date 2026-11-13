import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/state/app_state.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../models/user_model.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'rian.pratama@kampus.ac.id');
  final _passwordController = TextEditingController(text: 'password123');
  final _formKey = GlobalKey<FormState>();
  UserRole _selectedRole = UserRole.buyer;
  String _selectedCanteenId = 'c1';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRoleChanged(UserRole role) {
    setState(() {
      _selectedRole = role;
      if (role == UserRole.seller) {
        _emailController.text = 'bu.ani@kantinq.com';
      } else {
        _emailController.text = 'rian.pratama@kampus.ac.id';
      }
    });
  }

  void _onLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authCtrl = AppState.instance.authController;
      final success = await authCtrl.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        role: _selectedRole,
        sellerCanteenId: _selectedRole == UserRole.seller ? _selectedCanteenId : null,
      );

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authCtrl.errorMessage ?? 'Gagal masuk akun'),
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.xl),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Brand Logo
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [AppColors.primaryShadow],
                      ),
                      child: const Icon(
                        Icons.restaurant_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.md),
                  const Center(
                    child: Text(
                      AppStrings.appName,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const Center(
                    child: Text(
                      AppStrings.appTagline,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimens.lg),

                  // Role Switcher Segmented Control
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _onRoleChanged(UserRole.buyer),
                            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: _selectedRole == UserRole.buyer ? AppColors.surface : Colors.transparent,
                                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                                boxShadow: _selectedRole == UserRole.buyer ? const [AppColors.softShadow] : null,
                              ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Text(
                                      'Mahasiswa / Pembeli',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: _selectedRole == UserRole.buyer ? FontWeight.bold : FontWeight.w500,
                                        color: _selectedRole == UserRole.buyer ? AppColors.primary : AppColors.textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () => _onRoleChanged(UserRole.seller),
                              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: _selectedRole == UserRole.seller ? AppColors.surface : Colors.transparent,
                                  borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                                  boxShadow: _selectedRole == UserRole.seller ? const [AppColors.softShadow] : null,
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Text(
                                      'Penjual (Stan Kantin)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: _selectedRole == UserRole.seller ? FontWeight.bold : FontWeight.w500,
                                        color: _selectedRole == UserRole.seller ? AppColors.primary : AppColors.textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimens.md),

                  // Login Form Card
                  Container(
                    padding: const EdgeInsets.all(AppDimens.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                      border: Border.all(color: AppColors.outline),
                      boxShadow: const [AppColors.softShadow],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedRole == UserRole.seller ? 'Masuk Dashboard Stan' : 'Masuk ke Akun',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedRole == UserRole.seller
                              ? 'Kelola pesanan masuk & stok menu stan Anda'
                              : 'Gunakan email kampus/sekolah untuk login',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: AppDimens.md),

                        if (_selectedRole == UserRole.seller) ...[
                          const Text(
                            'Pilih Akun Stan Kantin',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedCanteenId,
                            isExpanded: true,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              filled: true,
                              fillColor: AppColors.surfaceVariant,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                                borderSide: const BorderSide(color: AppColors.outline),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                                borderSide: const BorderSide(color: AppColors.outline),
                              ),
                            ),
                            items: AppState.instance.canteenController.canteens
                                .map(
                                  (c) => DropdownMenuItem<String>(
                                    value: c.id,
                                    child: Text(
                                      c.name,
                                      style: const TextStyle(fontSize: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            selectedItemBuilder: (context) => AppState.instance.canteenController.canteens
                                .map(
                                  (c) => Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      c.name,
                                      style: const TextStyle(fontSize: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedCanteenId = value;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: AppDimens.sm),
                        ],

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
                              text: _selectedRole == UserRole.seller ? 'Buka Dashboard Penjual' : 'Masuk Sekarang',
                              isLoading: authCtrl.isLoading,
                              onPressed: _onLogin,
                            );
                          },
                        ),

                        const Divider(height: 28),

                        // Quick Demo Logins
                        const Center(
                          child: Text(
                            'AKSES PENGUJIAN INSTAN (1-KETUK):',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 0.5),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          alignment: WrapAlignment.center,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => authCtrl.loginAsDemoBuyer(),
                              icon: const Icon(Icons.person_rounded, size: 14),
                              label: const Text('Mahasiswa (Tamu)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                foregroundColor: AppColors.secondary,
                                side: const BorderSide(color: AppColors.secondary),
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => authCtrl.loginAsDemoSeller(canteenId: 'c2'),
                              icon: const Icon(Icons.soup_kitchen_rounded, size: 14),
                              label: const Text('Mas Joni (Stan 02)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(color: AppColors.primary),
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => authCtrl.loginAsDemoSeller(canteenId: 'c1'),
                              icon: const Icon(Icons.storefront_rounded, size: 14),
                              label: const Text('Bu Sri (Stan 01)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                foregroundColor: AppColors.textPrimary,
                                side: const BorderSide(color: AppColors.outline),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimens.lg),

                  // Register Link
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      const Text(
                        'Belum memiliki akun? ',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          );
                        },
                        child: const Text(
                          'Daftar Baru',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
