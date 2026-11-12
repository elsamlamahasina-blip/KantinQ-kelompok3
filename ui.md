# Struktur Layar, Navigasi, & Interaksi UI — KantinQ Mobile App

## 1. Arsitektur Navigasi & Screen Inventory

### 1.1 Diagram Navigasi Utama
```
[Splash & Onboarding] ───► [Login / Register]
                                  │
                                  ▼
                     [MainShell (Bottom Navigation)]
        ┌───────────────────┬───────────────────┬───────────────────┐
        ▼                   ▼                   ▼                   ▼
    [Beranda]           [Pesanan]            [Dompet]            [Profil]
        │                   │                   │                   │
        ├─► [Tenant Detail] ├─► [Order Detail/  ├─► [Top Up Saldo]  ├─► [Edit Profil]
        │         │         │     Queue Tracker]├─► [Mutasi Saldo]  ├─► [Bantuan/FAQ]
        │         ▼         │                   │                   └─► [Logout]
        │   [Menu Detail/   └─► [Struk Digital] └─► [Transfer]
        │     Kustomisasi]
        │         │
        ▼         ▼
  [Keranjang Belanja] ───► [Checkout & Bayar] ───► [Tiket Antrean Sukses]
```

---

## 2. Rincian Layar (Screen Specifications)

### 2.1 Main Shell (Navigasi Bawah)
- **Bottom Navigation Bar**:
  1. **Beranda (`Icons.storefront_rounded`)**: Eksplorasi kantin, promo, dan menu populer.
  2. **Pesanan (`Icons.receipt_long_rounded`)**: Daftar antrean aktif dan riwayat pemesanan. Memiliki badge merah saat ada pesanan aktif.
  3. **Dompet (`Icons.account_balance_wallet_rounded`)**: Pusat kendali saldo KantinQ Pay, top up, dan mutasi.
  4. **Profil (`Icons.person_rounded`)**: Pengaturan akun, voucher, dan informasi pengguna.

---

### 2.2 Layar Beranda (Home Screen)
- **Header**:
  - Sapaan nama pengguna dan avatar profil.
  - Dropdown lokasi kantin aktif (misal: "Kantin Utama Lt. 1").
  - Tombol notifikasi antrean dengan badge aktif.
- **Kartu Ringkasan KantinQ Pay**:
  - Saldo aktif berformat Rupiah tebal.
  - Tombol aksi instan: `Top Up`, `Riwayat`, dan `Scan QR`.
- **Search Bar**:
  - Field pencarian dengan ikon kaca pembesar dan placeholder *"Cari nasi goreng, es teh, atau nama kantin..."*.
- **Carousel Banner Promo**:
  - Banner horizontal scroll dengan penawaran menarik: "Diskon Istirahat Siang 25%", "Cashback KantinQ Pay 50%".
- **Kategori Menu Cepat**:
  - Horizontal pill selector: "Semua", "Nasi & Lauk", "Mie & Bakso", "Minuman", "Snack", "Paket Hemat".
- **Daftar Tenant Kantin Pilihan**:
  - Horizontal list kartu stan kantin dengan foto stan, status buka/tutup, perkiraan waktu penyiapan (10–15 mnt), dan rating.
- **Menu Terpopuler (Food Grid/List)**:
  - Kartu menu dengan foto berkualitas tinggi, nama menu, nama stan, rating, harga, dan tombol cepat `+ Keranjang`.

---

### 2.3 Layar Detail Tenant (Canteen Detail Screen)
- **Header Hero**:
  - Banner foto stan kantin, tombol kembali, dan tombol favorit (bookmark).
- **Profil Tenant**:
  - Nama stan, kategori makanan, rating bintang (misal: 4.8 ★), jam buka, dan lokasi nomor stan.
- **Tab Kategori Menu Stan**:
  - Filter menu spesifik milik stan tersebut (Makanan Utama, Minuman, Tambahan).
- **Katalog Menu Stan**:
  - Daftar menu dengan foto, deskripsi singkat bahan, harga, dan tombol aksi "Tambah".
- **Sticky Floating Cart Indicator**:
  - Muncul di bagian bawah jika keranjang memiliki item dari stan tersebut, menampilkan jumlah item dan total harga dengan tombol "Lihat Keranjang".

---

### 2.4 Modal Kustomisasi Menu (Menu Detail & Options)
- **Hero Image & Title**:
  - Foto besar menu, nama makanan, harga satuan, dan deskripsi lezat.
- **Pilihan Level Pedas (Radio Chips)**:
  - Level 0 (Tidak Pedas), Level 1 (Sedang), Level 2 (Pedas), Level 3 (Super Pedas).
- **Pilihan Topping Tambahan (Checkboxes)**:
  - Telur Dadar/Ceplok (+Rp3.000), Ekstra Sambal (+Rp1.000), Kerupuk Kaleng (+Rp1.000).
- **Catatan untuk Penjual**:
  - Input teks multi-baris (misal: "bawang goreng dibanyakin").
- **Quantity Selector**:
  - Tombol minus `-`, jumlah saat ini (angka tebal), tombol plus `+`.
- **Tombol Aksi Utama**:
  - `Tambah ke Keranjang • RpXX.XXX` dengan animasi feedback getar/snackbar lembut.

---

### 2.5 Layar Keranjang Belanja (Cart Screen)
- **Tipe Pesanan (Segmented Control)**:
  - Pilihan jelas antara: `Makan di Tempat (Dine-in)` atau `Bungkus (Takeaway)`.
- **Nomor Meja / Catatan Tempat**:
  - Field input nomor meja jika memilih Makan di Tempat.
- **Daftar Item Pesanan**:
  - Dikelompokkan rapi per stan kantin.
  - Setiap baris memiliki thumbnail, nama menu, ringkasan varian (level pedas, topping), catatan, harga total item, dan kontrol kuantitas (+ / - / hapus).
- **Rincian Pembayaran (Order Summary Card)**:
  - Subtotal Makanan & Minuman.
  - Biaya Layanan Kantin (Rp1.000).
  - Diskon Promo.
  - **Total Pembayaran**.
- **Tombol Checkout**:
  - Tombol penuh berlatar Warm Coral bertuliskan "Lanjut ke Pembayaran".

---

### 2.6 Layar Pembayaran (Checkout Screen)
- **Metode Pembayaran (Selectable Cards)**:
  1. **KantinQ Pay (Saldo: RpXX.XXX)**:
     - Jika saldo mencukupi: badge hijau "Saldo Cukup".
     - Jika saldo kurang: badge merah "Saldo Kurang" dan tombol instan "Top Up Dulu".
  2. **QRIS KantinQ**:
     - Pembayaran instan via scan QRIS (GoPay, OVO, Dana, BCA, Livin, dll).
  3. **Tunai di Kasir**:
     - Bayar langsung saat mengambil pesanan di kasir stan.
- **Pilihan Kupon Promo**:
  - Input kode voucher atau pilih kupon diskon yang tersedia.
- **Konfirmasi Keamanan**:
  - Dialog konfirmasi sebelum pembayaran diproses.

---

### 2.7 Layar Pelacakan Antrean (Smart Queue Tracking Screen)
- **Kartu Tiket Antrean (Queue Ticket Card)**:
  - Desain tiket beraksen potongan perforasi dengan nomor antrean raksasa (misal: `#A-14`).
  - Nama Stan Kantin dan Tipe Pesanan (Dine-in / Takeaway).
  - Waktu estimasi penyajian (misal: "Estimasi: ~8 Menit").
- **Stepper Status Interaktif Real-Time**:
  - Step 1: Pesanan Diterima (Centang Hijau)
  - Step 2: Sedang Dimasak (Animasi Ikon Koki / Wajan berkedip hangat)
  - Step 3: Siap Diambil (Warna Teal cerah, petunjuk nomor meja/lokasi stan)
  - Step 4: Selesai
- **QR Code Pengambilan Pesanan**:
  - Barcode / QR Code digital yang dapat di-scan oleh penjual stan sebagai bukti sah pengambilan.
- **Aksi Cepat**:
  - Tombol "Hubungi Stan Kantin", tombol "Lihat Struk Digital", dan tombol "Konfirmasi Pesanan Diterima".

---

### 2.8 Layar Dompet Digital & Top Up (Wallet & Top Up Screen)
- **Tampilan Saldo Modern**:
  - Kartu dompet dengan motif gelombang gradien elegan.
  - Nomor kartu ID pengguna dan tombol hide/show saldo.
- **Tombol Aksi**:
  - Top Up Saldo, Transfer Antar Teman, dan Riwayat Lengkap.
- **Form Top Up Instan**:
  - Pilihan chip nominal cepat: Rp10.000, Rp20.000, Rp50.000, Rp100.000, Rp200.000.
  - Pilihan metode transfer: Bank Virtual Account (BCA, Mandiri, BRI, BNI), QRIS, atau Kasir Kantin.
  - Tombol konfirmasi top up dengan simulasi sukses instan yang langsung mengupdate saldo utama.
- **Riwayat Mutasi Saldo**:
  - List transaksi keluar (debit belanja pesanan) dan masuk (kredit top up) lengkap dengan tanggal, jam, dan status.

---

### 2.9 Layar Profil Pengguna (Profile Screen)
- **Header Profil**: Avatar bundar, nama pengguna, email, nomor HP, badge status "Member KantinQ".
- **Menu Navigasi Akun**:
  - Voucher & Kupon Diskon Saya.
  - Pengaturan Keamanan & PIN Transaksi.
  - Pusat Bantuan & Tanya Jawab (FAQ).
  - Tentang Aplikasi KantinQ (Versi 1.0.0+1).
  - Tombol Keluar (Logout) dengan konfirmasi dialog aman.
