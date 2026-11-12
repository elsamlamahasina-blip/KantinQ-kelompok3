# Product Requirements Document (PRD) — KantinQ Mobile App

## 1. Executive Summary & Problem Statement
KantinQ adalah aplikasi mobile modern untuk pemesanan makanan dan minuman di kantin sekolah, kampus, dan gedung perkantoran. Aplikasi ini dirancang untuk mengatasi masalah antrean panjang, keterbatasan waktu istirahat (30–45 menit), ketidakpastian ketersediaan menu, serta proses pembayaran tunai yang lambat.

Dengan sistem **Smart Digital Queue & KantinQ Pay**, pengguna dapat memesan makanan terlebih dahulu, memantau antrean secara real-time, melakukan pembayaran non-tunai yang cepat, dan langsung mengambil makanan ketika nomor antrean mereka dipanggil.

---

## 2. Product Objectives & Success Metrics
- **Efisiensi Waktu**: Memangkas waktu tunggu antrean fisik di stan kantin hingga lebih dari 70%.
- **Transparansi Stok & Menu**: Mengurangi pembatalan pesanan akibat menu habis melalui pembaruan stok real-time.
- **Cashless & Seamless Transaction**: 90% transaksi diproses secara digital melalui KantinQ Pay dan QRIS.
- **Akurasi Pesanan**: Memastikan pesanan diambil oleh orang yang tepat dengan sistem Nomor Antrean Unik dan Tiket QR Code Pengambilan.

---

## 3. User Roles & Personas
1. **Customer (Siswa / Mahasiswa / Pegawai)**:
   - Mencari tenant kantin dan menu makanan/minuman favorit.
   - Menyesuaikan pesanan (level pedas, catatan khusus, porsi).
   - Memilih tipe pesanan: *Makan di Tempat (Dine-in)* atau *Bungkus (Takeaway)*.
   - Membayar pesanan menggunakan Saldo KantinQ Pay, QRIS, atau Tunai di Kasir.
   - Memantau nomor antrean digital dan status proses dapur secara real-time.
   - Mengambil pesanan dengan menunjukkan kode tiket / scan QR Code.
   - Memberikan ulasan dan rating pada menu yang sudah selesai dinikmati.
2. **Tenant / Penjual Kantin (Merchant Mitra)**:
   - Mengelola katalog menu dan ketersediaan stok.
   - Menerima pesanan masuk, mengubah status menjadi "Sedang Dimasak", dan "Siap Diambil".
   - Memverifikasi kode tiket saat makanan diserahkan.
3. **Kantin Administrator**:
   - Mengelola data master tenant, rekapitulasi transaksi, dan keamanan sistem.

---

## 4. Key Feature Requirements

### 4.1 Authentication & User Management
- **Guest / Quick Exploration**: Pengguna dapat menjelajahi menu dan tenant tanpa harus login di awal.
- **User Authentication**: Login dan Pendaftaran dengan validasi email/username dan password.
- **User Profile**: Menampilkan nama pengguna, nomor telepon, email, avatar, dan saldo dompet KantinQ Pay.
- **Security**: Fitur logout yang membersihkan sesi pengguna dengan aman.

### 4.2 Home & Discovery
- **Header & Wallet Quick Card**: Menampilkan sapaan personal, lokasi kantin aktif, dan ringkasan Saldo KantinQ Pay dengan tombol instan *Top Up*.
- **Banner Promo Dinamis**: Carousel promo diskon jam istirahat, menu hemat harian, dan cashback.
- **Kategori Menu Cepat**: Navigasi filter cepat (Semua, Makanan Berat, Minuman Segar, Snack & Cemilan, Paket Hemat, Sehat/Vegetarian).
- **Tenant Spotlight**: Daftar stan kantin mitra dengan indikator status buka/tutup, perkiraan waktu penyiapan, dan rating bintang.
- **Menu Terlaris & Rekomendasi**: Grid card menu populer dengan foto menggugah selera, label harga, rating, dan tombol cepat *+ Keranjang*.

### 4.3 Search & Filtering
- Pencarian kata kunci menu atau nama tenant secara instan.
- Filter berdasarkan rentang harga, rating minimum, dan kategori makanan.

### 4.4 Tenant & Menu Detail
- **Tenant Profile**: Banner stan, jam operasional, rating, total ulasan, dan daftar menu berdasarkan kategori stan.
- **Menu Customization Modal / Screen**:
  - Foto resolusi tinggi dan deskripsi menu.
  - Pilihan Level Pedas (Tidak Pedas, Sedang, Pedas, Extra Pedas).
  - Pilihan Topping / Tambahan (Telur Mata Sapi, Kerupuk, Keju, Ekstra Nasi).
  - Kolom Catatan Khusus untuk penjual (misal: "tanpa seledri", "sedikit gula").
  - Counter jumlah item (+ / -) dengan update harga total otomatis.
  - Tombol aksi utama "Tambah ke Keranjang".

### 4.5 Smart Cart & Checkout
- **Keranjang Belanja**:
  - Tampilan daftar item dengan rincian varian dan catatan.
  - Fitur tambah/kurang jumlah atau hapus item.
  - Pilihan Mode Pengambilan: *Makan di Tempat (Dine-in)* atau *Bawa Pulang (Takeaway)*.
  - Catatan Meja / Lokasi Pengambilan.
- **Checkout & Payment**:
  - Rincian Biaya Transparan: Subtotal Makanan, Biaya Layanan Kantin (misal Rp1.000), dan Potongan Promo.
  - Input Kode Voucher / Promo Diskon.
  - Pilihan Metode Pembayaran:
    1. **KantinQ Pay (E-Wallet)**: Validasi otomatis kecukupan saldo. Jika saldo kurang, tampilkan peringatan dan tombol cepat *Top Up*.
    2. **QRIS Instan**: Menampilkan barcode QRIS dinamis.
    3. **Tunai di Kasir**: Pembayaran manual saat penyerahan makanan.
  - Tombol Konfirmasi Pesanan dengan dialog konfirmasi anti-double-click.

### 4.6 Smart Queue & Order Tracking
- **Nomor Antrean Unik Digital**: Dihasilkan otomatis (format: `#A-01` s/d `#C-99` sesuai tenant).
- **Live Status Stepper**:
  1. *Menunggu Konfirmasi*: Pesanan telah terkirim ke dapur.
  2. *Sedang Disiapkan / Dimasak*: Koki sedang memasak pesanan.
  3. *Siap Diambil*: Makanan telah selesai dan siap di stan. Notifikasi visual aktif.
  4. *Selesai*: Makanan telah diterima pelanggan.
- **Tiket Pengambilan Digital & QR Code**: QR Code unik untuk verifikasi penyerahan pesanan di stan kantin.
- **Aksi Cepat**: Tombol hubungi tenant dan tombol konfirmasi "Pesanan Telah Diterima".

### 4.7 KantinQ Pay (Dompet Digital)
- Saldo real-time yang aman dan tersinkronisasi.
- **Fitur Top Up Cepat**:
  - Pilihan nominal instan: Rp10.000, Rp20.000, Rp50.000, Rp100.000.
  - Metode Top Up: Transfer Bank / Virtual Account, QRIS, atau Kasir Utama Kantin.
  - Simulasi pembayaran sukses instan untuk kebutuhan pengujian dan transaksi.
- **Riwayat Mutasi**: Daftar histori transaksi masuk (Top Up) dan keluar (Pembayaran Pesanan) dengan rincian tanggal, nominal, dan status.

### 4.8 Order History & Activity
- **Tab Pesanan Aktif**: Memantau seluruh pesanan yang sedang dalam proses persiapan atau siap diambil.
- **Tab Riwayat Selesai**: Arsip pesanan masa lalu dengan rincian struk belanja digital.
- **Fitur Pesan Lagi (Re-order)**: Menambahkan kembali seluruh item dari pesanan sebelumnya ke keranjang dalam satu ketukan.

---

## 5. Non-Functional Requirements
- **Performance**: Waktu respon navigasi < 100ms, transisi layar 60 FPS tanpa jank.
- **Reliability & State Handling**: Seluruh layar wajib memiliki state `Loading`, `Success`, `Empty`, dan `Error` yang ramah pengguna.
- **Offline & Connectivity Resilience**: Penanganan jaringan yang anggun saat koneksi internet terputus dengan opsi coba lagi (Retry).
- **Security**: Tidak ada penyimpanan kredensial sensitif dalam bentuk teks polos. Validasi mutlak pada nominal dan transaksi saldo.
