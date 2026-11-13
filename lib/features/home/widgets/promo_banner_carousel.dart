import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/state/app_state.dart';
import '../../../core/utils/currency_formatter.dart';

class PromoBannerCarousel extends StatefulWidget {
  const PromoBannerCarousel({super.key});

  @override
  State<PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends State<PromoBannerCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentPage = 0;

  static const List<Map<String, dynamic>> _baseBanners = [
    {
      'title': 'Diskon Istirahat Siang',
      'subtitle': 'Potongan Rp 5.000 dengan kode KANTINQHEMAT • Ketuk untuk salin',
      'tag': 'PROMO SPESIAL',
      'code': 'KANTINQHEMAT',
      'colors': [Color(0xFFE65100), Color(0xFFFF8F00)],
      'icon': Icons.local_fire_department_rounded,
    },
    {
      'title': 'Bebas Antre di Semua Stan',
      'subtitle': 'Pesan dari kelas, ambil saat notifikasi Siap Diambil berbunyi',
      'tag': 'SMART QUEUE',
      'colors': [Color(0xFF00695C), Color(0xFF00897B)],
      'icon': Icons.bolt_rounded,
    },
    {
      'title': 'Bayar COD di Kasir Stan',
      'subtitle': 'Pesan dari HP, bayar tunai langsung saat mengambil makanan',
      'tag': 'COD PRAKTIS',
      'colors': [Color(0xFF1565C0), Color(0xFF1E88E5)],
      'icon': Icons.payments_rounded,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _buildBanners() {
    final canteenVouchers = AppState.instance.voucherController.activeCanteenVouchers;
    final dynamicBanners = <Map<String, dynamic>>[
      _baseBanners.first,
      ...canteenVouchers.take(3).map(
        (v) => {
          'title': '${v.title} (${v.code})',
          'subtitle':
              'Hemat ${CurrencyFormatter.format(v.discountAmount)} di ${v.canteenName ?? 'stan mitra'} • Ketuk untuk salin',
          'tag': 'VOUCHER STAN',
          'code': v.code,
          'colors': [const Color(0xFFD84315), const Color(0xFFFF7043)],
          'icon': Icons.confirmation_number_rounded,
        },
      ),
      ..._baseBanners.skip(1),
    ];
    return dynamicBanners;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState.instance.voucherController,
      builder: (context, _) {
        final banners = _buildBanners();
        final safePage = _currentPage >= banners.length ? 0 : _currentPage;

        return Column(
          children: [
            SizedBox(
              height: 125,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: banners.length,
                itemBuilder: (context, index) {
                  final banner = banners[index];
                  final colors = banner['colors'] as List<Color>;

                  final code = banner['code'] as String?;

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: colors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                      boxShadow: const [AppColors.softShadow],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                        onTap: () {
                          if (code != null && code.isNotEmpty) {
                            Clipboard.setData(ClipboardData(text: code));
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Kode voucher "$code" disalin! Terapkan di Keranjang saat checkout.',
                                ),
                                backgroundColor: AppColors.secondary,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(AppDimens.md),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.25),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        banner['tag'] as String,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      banner['title'] as String,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      banner['subtitle'] as String,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.9),
                                        fontSize: 11,
                                        height: 1.2,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  banner['icon'] as IconData,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppDimens.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                banners.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: safePage == index ? 16 : 6,
                  height: 5,
                  decoration: BoxDecoration(
                    color: safePage == index
                        ? AppColors.primary
                        : AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
