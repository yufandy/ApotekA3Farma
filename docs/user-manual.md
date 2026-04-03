# Manual Pengguna Apotek Modern

## Daftar Isi
1. [Login ke Sistem](#login-ke-sistem)
2. [Transaksi Penjualan](#transaksi-penjualan)
3. [Manajemen Stok](#manajemen-stok)
4. [Manajemen Pasien](#manajemen-pasien)
5. [Laporan](#laporan)

## Login ke Sistem

1. Buka aplikasi apotek
2. Masukkan username dan password
3. Klik "Login"

## Transaksi Penjualan

### Penjualan Tunai
1. Klik menu "POS / Kasir"
2. Cari obat (scan barcode atau ketik nama)
3. Masukkan jumlah
4. Pilih metode pembayaran "Tunai"
5. Masukkan nominal uang
6. Klik "Proses"

### Penjualan QRIS
1. Sama seperti di atas
2. Pilih metode "QRIS"
3. Customer scan QR code yang muncul
4. Tunggu konfirmasi pembayaran

### Penjualan BPJS
1. Pilih pasien BPJS (atau registrasi baru)
2. Verifikasi nomor BPJS
3. Pilih obat (hanya obat formularium)
4. Sistem akan menghitung copayment
5. Proses klaim otomatis

## Manajemen Stok

### Cek Stok
- Buka menu "Stok → Cek Stok"
- Cari berdasarkan nama obat atau barcode
- Lihat batch dan expired date

### Transfer Stok Antar Outlet
- Buka menu "Stok → Transfer"
- Pilih outlet tujuan
- Pilih produk dan jumlah
- Klik "Transfer"

## Manajemen Pasien

### Registrasi Pasien Baru
- Buka menu "Pasien → Registrasi"
- Isi data lengkap (nama, NIK, alamat, dll)
- Pilih jenis asuransi (BPJS/Private/None)
- Klik "Simpan"

### Buat Reminder
- Buka menu "Pasien → Reminder"
- Pilih pasien
- Pilih jenis reminder (minum obat/beli ulang/kontrol)
- Set tanggal dan waktu
- Pilih channel (WA/SMS/Email)
- Klik "Simpan"

## Laporan

### Laporan Penjualan Harian
- Buka menu "Laporan → Penjualan Harian"
- Pilih tanggal
- Klik "Generate"

### Laporan Stok Kritis
- Buka menu "Laporan → Stok Kritis"
- Lihat produk yang perlu diorder

### Laporan Pareto
- Buka menu "Analisis → Pareto ABC"
- Lihat klasifikasi produk A, B, C, D

## Troubleshooting Umum

### Gagal Login
- Periksa username dan password
- Reset password via admin

### Stok Tidak Sesuai
- Lakukan stock opname
- Koreksi stok via menu "Stok → Adjustment"

### Reminder Tidak Terkirim
- Periksa koneksi internet
- Cek log di menu "Reminder → Log"