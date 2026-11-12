# Design System & Visual Identity — KantinQ Mobile App

## 1. Brand Identity & Filosofi Visual
KantinQ mengusung identitas visual yang **hangat, menggugah selera, modern, dan efisien**. Desain antarmuka memadukan energi warna *Warm Coral* (simbol kelezatan makanan dan semangat istirahat) dengan ketenangan *Emerald Teal* (simbol kebersihan, kesegaran bahan, dan keandalan transaksi non-tunai).

---

## 2. Palet Warna (Color Palette)

### 2.1 Warna Utama (Brand Colors)
- **Primary (Warm Coral / Sunset Orange)**: `0xFFFF5722`
  - *Primary Dark*: `0xFFD84315` (untuk teks penting, hover, dan header gelap)
  - *Primary Light / Container*: `0xFFFFEBE5` (untuk badge latar, highlight aktif)
- **Secondary (Emerald Teal / Fres Mint)**: `0xFF00897B`
  - *Secondary Dark*: `0xFF00695C`
  - *Secondary Light / Container*: `0xFFE0F2F1` (untuk status siap diambil, saldo positif)
- **Accent (Amber Gold)**: `0xFFFFB300` (untuk bintang rating, promo spesial, poin)

### 2.2 Warna Netral & Permukaan (Neutral & Surface)
- **Background App**: `0xFFF8F9FA` (abu-abu sangat terang yang hangat dan nyaman di mata)
- **Surface (Kartu & Dialog)**: `0xFFFFFFFF` (putih murni untuk kontras optimal)
- **Surface Variant / Input Fill**: `0xFFF1F3F5` (untuk field teks dan divider lembut)
- **Text Primary (Teks Utama)**: `0xFF1E2022` (karbon pekat dengan tingkat keterbacaan tinggi)
- **Text Secondary (Teks Sekunder/Muted)**: `0xFF6C757D` (abu-abu netral untuk deskripsi dan caption)
- **Outline / Border**: `0xFFE9ECEF` (garis batas halus dan elegan)

### 2.3 Warna Status & Umpan Balik (Feedback Colors)
- **Success (Selesai / Berhasil)**: `0xFF2E7D32` (latar lembut: `0xFFE8F5E9`)
- **Warning / In-Progress (Sedang Dimasak)**: `0xFFEF6C00` (latar lembut: `0xFFFFF3E0`)
- **Error / Danger (Batal / Gagal / Saldo Kurang)**: `0xFFD32F2F` (latar lembut: `0xFFFFEBEE`)
- **Info (Menunggu / Tiket)**: `0xFF1976D2` (latar lembut: `0xFFE3F2FD`)

---

## 3. Tipografi (Typography Hierarchy)
- **Display / App Title**: 26sp - 30sp, Bold, tracking: -0.5px.
- **Heading 1 / Screen Title**: 20sp - 22sp, Bold.
- **Heading 2 / Section Title**: 16sp - 18sp, Semi-Bold.
- **Body Large**: 15sp, Medium.
- **Body Medium / Default**: 14sp, Regular, line-height: 1.4.
- **Body Small**: 12sp - 13sp, Regular.
- **Caption & Overline**: 10sp - 11sp, Semi-Bold / Medium, tracking: 0.5px.

---

## 4. Spacing, Radius, & Elevation

### 4.1 Skala Spacing (Margin & Padding)
- **xxs**: 4px
- **xs**: 8px
- **sm**: 12px
- **md**: 16px (standar padding sisi layar)
- **lg**: 20px
- **xl**: 24px
- **xxl**: 32px

### 4.2 Border Radius
- **Small (Chips, Status Badges, Mini Buttons)**: 8px
- **Medium (Kartu Menu, Input Form, Tombol Utama)**: 14px - 16px
- **Large (Bottom Sheet, Dialog Konfirmasi, Header Banner)**: 24px
- **Pill / Circular (Tombol Aksi Mengambang, Avatar, Tag Kategori)**: 999px

### 4.3 Shadow & Elevation
- **Soft Floating Shadow**:
  - `BoxShadow(color: Color(0x0C000000), blurRadius: 16, offset: Offset(0, 4), spreadRadius: 0)`
- **Active Card Shadow**:
  - `BoxShadow(color: Color(0x18FF5722), blurRadius: 20, offset: Offset(0, 6))`

---

## 5. Komponen Desain Standar (Reusable Design Components)
1. **Primary Button**: Tombol penuh berlatar Warm Coral dengan teks putih tegas dan sudut membulat 14px. Memiliki state loading (spinner terintegrasi).
2. **Secondary Button**: Tombol bergaris batas halus (*outline*) atau berlatar container pastel.
3. **Queue Ticket Card**: Kartu beraksen tiket perforasi dengan nomor antrean raksasa, indikator status berwarna cerah, dan waktu estimasi.
4. **Food Menu Card**: Kartu horizontal atau vertikal dengan foto makanan rasio 4:3, tag rating, harga tebal berformat Rupiah, dan tombol cepat `+`.
5. **State Views**: Komponen khusus untuk `LoadingState` (shimmer/spinner elegan), `EmptyState` (ilustrasi & tombol aksi), dan `ErrorState` (pesan edukatif & tombol coba lagi).
