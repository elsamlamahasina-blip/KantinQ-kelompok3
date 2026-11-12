import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';

class MerchantGuideDialog extends StatelessWidget {
  const MerchantGuideDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusLg)),
      title: const Row(
        children: [
          Icon(Icons.menu_book_rounded, color: AppColors.primary),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Panduan Singkat Stan',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _GuideStep(
              number: '1',
              title: 'Menerima Pesanan Masuk (Antrean)',
              description: 'Pesanan baru dari mahasiswa akan muncul di tab Antrean. Periksa rincian porsi, level pedas, dan catatan pembeli sebelum mulai memasak.',
            ),
            SizedBox(height: 12),
            _GuideStep(
              number: '2',
              title: 'Ubah ke "Sedang Dimasak"',
              description: 'Tekan tombol "Mulai Masak" agar status di smartphone pembeli berubah. Pembeli akan melihat estimasi waktu penyajian.',
            ),
            SizedBox(height: 12),
            _GuideStep(
              number: '3',
              title: 'Tandai "Siap Diambil"',
              description: 'Setelah hidangan siap di etalase, tekan "Makanan Siap". Pembeli akan menerima notifikasi untuk segera mengambil makanan di stan tanpa mengantre.',
            ),
            SizedBox(height: 12),
            _GuideStep(
              number: '4',
              title: 'Verifikasi Kode & Penyerahan',
              description: 'Cocokkan Nomor Antrean atau scan QR Code pembeli saat menyerahkan makanan untuk memastikan ketepatan pesanan.',
            ),
            SizedBox(height: 12),
            _GuideStep(
              number: '5',
              title: 'Pembaruan Stok Cepat',
              description: 'Gunakan tab "Kelola Menu" untuk menambah atau mengurangi stok porsi (+ / -) bila bahan habis di jam istirahat sibuk.',
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Mengerti & Mulai Berjualan'),
        ),
      ],
    );
  }
}

class _GuideStep extends StatelessWidget {
  final String number;
  final String title;
  final String description;

  const _GuideStep({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
