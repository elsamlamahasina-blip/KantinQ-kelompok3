# Arsitektur & Spesifikasi Sistem — KantinQ Mobile App

## 1. Arsitektur Aplikasi
KantinQ dibangun menggunakan prinsip **Clean Architecture** yang dipadukan dengan pendekatan **Feature-First**. Pendekatan ini memisahkan tanggung jawab kode menjadi tiga lapisan utama:

```
lib/
├── core/                         # Komponen global dan lintas fitur
│   ├── constants/                # App colors, strings, assets, dimensions
│   ├── errors/                   # Exception types & failure handling
│   ├── theme/                    # Material 3 Design tokens & AppTheme
│   ├── utils/                    # Formatters (Rupiah, Date), Helpers
│   └── widgets/                  # Reusable atomic UI (Buttons, Cards, States)
├── features/                     # Modul fitur terisolasi
│   ├── auth/                     # Autentikasi & manajemen sesi pengguna
│   ├── home/                     # Beranda, discovery, banner promo
│   ├── canteen/                  # Detail tenant, katalog menu, kustomisasi
│   ├── cart/                     # Keranjang belanja & opsi pemesanan
│   ├── checkout/                 # Pembayaran, voucher, ringkasan biaya
│   ├── order/                    # Pelacakan antrean real-time & riwayat pesanan
│   ├── wallet/                   # KantinQ Pay, top up, riwayat mutasi
│   └── profile/                  # Pengaturan akun, FAQ, bantuan
└── main.dart                     # Entry point & provider injection tree
```

### 1.1 Pola Lapisan (Layers)
Setiap fitur diorganisasi ke dalam tiga sub-lapisan:
1. **Domain Layer (Inti Bisnis)**:
   - *Entities / Models*: Definisi objek data murni tanpa ketergantungan framework.
   - *Repository Interfaces*: Kontrak operasi data tanpa implementasi teknis.
2. **Data Layer (Akses & Persistensi Data)**:
   - *Data Sources*: Pengambil data (Mock API dengan latensi simulasi, Local Storage).
   - *Models / DTOs*: Serialisasi data (JSON parsing, validasi payload).
   - *Repository Implementations*: Implementasi konkret dari kontrak domain.
3. **Presentation Layer (Antarmuka & Reaktivitas)**:
   - *Controllers / Notifiers*: Pengelola state (`ChangeNotifier`) yang memisahkan logika UI dari rendering widget.
   - *Screens & Widgets*: Komponen antarmuka deklaratif yang mendengarkan perubahan state.

---

## 2. State Management & Reaktivitas
- Menggunakan **ChangeNotifier & AnimatedBuilder / ListenableBuilder** bawaan Flutter yang ringan, bebas dari overhead library eksternal, dan terbukti sangat stabil pada seluruh versi Flutter 3+.
- Setiap controller bertanggung jawab atas satu domain fungsional (misal: `CartController`, `OrderController`, `WalletController`, `AuthController`).
- Notifier memancarkan state status:
  - `AppStatus.initial`
  - `AppStatus.loading`
  - `AppStatus.success`
  - `AppStatus.empty`
  - `AppStatus.error`

---

## 3. Data Flow & Network Simulation
- **Mock Service Layer**: Karena backend microservices sedang dalam tahap sinkronisasi, aplikasi menyertakan `MockDataSource` yang realistis dengan:
  - Delay simulasi jaringan 300ms–600ms untuk menguji kelayakan loading skeleton/spinner.
  - Simulasi skenario error (misal: saldo tidak cukup, menu habis, gangguan koneksi).
  - Mekanisme reaktif: saat pesanan dibuat di `CartController`, data langsung diteruskan ke `OrderController` dan saldo dipotong di `WalletController`.

---

## 4. Keamanan & Validasi Sistem
1. **Integritas Transaksi Dompet**:
   - Saldo dompet (`WalletBalance`) tidak boleh bernilai negatif.
   - Validasi saldo dilakukan ganda (pada UI checkout dan saat eksekusi repository).
2. **Anti Double-Submission**:
   - Tombol bayar dinonaktifkan (`isProcessing`) segera setelah ditekan hingga proses selesai.
3. **Validasi Input**:
   - Validasi format email, nomor telepon Indonesia (`08...`), serta minimal karakter password.
   - Validasi batas minimum dan maksimum top-up saldo (minimal Rp5.000, maksimal Rp2.000.000 per transaksi).

---

## 5. Standar Penanganan Error & Ketersediaan Layanan
- Semua kegagalan jaringan atau parsing dibungkus ke dalam objek `AppFailure` yang memiliki pesan ramah pengguna berbahasa Indonesia.
- Layanan menyediakan fitur retry terpadu saat terjadi kegagalan muat data.
