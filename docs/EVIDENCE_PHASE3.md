# FinFlow — Evidence Phase 3 (Data, Backend & Platform Integration)

Dokumen ini dipakai pada presentasi Phase 3 (RPS INF11119, rubrik D.4). Setiap klaim punya bukti yang bisa diperiksa ulang.
Kolom **Bukti** diisi dengan nama file di folder `docs/bukti/` setelah pengujian ke backend asli dilakukan.

## 1. Cara menjalankan (reproducible)

**Backend (Laravel 12)**

```bash
cd backend
composer install
cp .env.example .env            # Windows: copy .env.example .env
php artisan key:generate
# isi kredensial MySQL di .env, buat database-nya
php artisan migrate
php artisan storage:link
php artisan serve --host=0.0.0.0 --port=8000
```

**Frontend (Flutter)**

```bash
cd frontend
flutter pub get
flutter test
flutter run --dart-define=API_BASE_URL=http://<IP-LAN-LAPTOP-BACKEND>:8000/api
```

| Perangkat | Nilai `API_BASE_URL` |
|---|---|
| Android Emulator | `http://10.0.2.2:8000/api` (bawaan) |
| HP fisik (satu Wi-Fi) | `http://<IP-LAN>:8000/api` |
| Windows desktop | `http://127.0.0.1:8000/api` |

Gunakan build **debug**. Build rilis menolak HTTP polos (lihat bagian 5).

## 2. Kontrak API

Semua respons berbentuk `{ "success": bool, "message": string, "data": ... }`.
Endpoint bertanda 🔒 butuh header `Authorization: Bearer <token>` (Laravel Sanctum).

| Method | Path | 🔒 | Request | Respons sukses | Error umum |
|---|---|---|---|---|---|
| GET | `/health` | – | – | 200 status API | – |
| POST | `/register` | – | `username`, `password` (min 8), `password_confirmation` | 201 `data.user`, `data.token`; 5 kategori awal dibuat otomatis | 422 validasi (username sudah dipakai) |
| POST | `/login` | – | `username`, `password` | 200 `data.user`, `data.token` | 401 username/password salah, 422 |
| POST | `/logout` | 🔒 | – | 200, token dihapus | 401 |
| GET | `/me` | 🔒 | – | 200 `data.user` | 401 token ditolak |
| PUT | `/profil` | 🔒 | `username`, `password` + `password_confirmation`, `foto_profil` (gambar ≤ 2 MB), `hapus_foto` (semua opsional) | 200 `data.user` (+ `foto_profil_url`) | 401, 422 |
| GET | `/kategori` | 🔒 | – | 200 daftar kategori milik user | 401 |
| POST | `/kategori` | 🔒 | `nama_kategori`, `jenis_kategori` (`pemasukan`/`pengeluaran`) | 201 | 422 |
| PUT | `/kategori/{id}` | 🔒 | field yang diubah | 200 | 404, 422 |
| DELETE | `/kategori/{id}` | 🔒 | – | 200 | 409 kategori masih dipakai transaksi |
| GET | `/transaksi` | 🔒 | – | 200 daftar transaksi (terbaru dulu) + relasi `kategori` | 401 |
| POST | `/transaksi` | 🔒 | `id_kategori`, `nama_transaksi`, `jenis_transaksi`, `tanggal_transaksi`, `nominal` (> 0), `catatan` (opsional) | 201 | 422 (termasuk jenis transaksi tidak sesuai jenis kategori) |
| GET | `/transaksi/{id}` | 🔒 | – | 200 | 404 |
| PUT | `/transaksi/{id}` | 🔒 | field yang diubah | 200 | 404, 422 |
| DELETE | `/transaksi/{id}` | 🔒 | – | 200 | 404 |
| GET | `/ringkasan` | 🔒 | – | 200 `saldo`, `total_pemasukan`, `total_pengeluaran`, `transaksi_terbaru` (5 data) | 401 |
| GET | `/dashboard` | 🔒 | – | 200 total + `jumlah_transaksi` | 401 |

**Keputusan desain:** `saldo` = total seluruh pemasukan dikurangi total seluruh pengeluaran (bukan per bulan).
`id_user` selalu diambil dari token, bukan dari request, sehingga pengguna tidak bisa membaca atau mengubah data pengguna lain (data lain menghasilkan 404).
`/dashboard` disediakan backend tetapi tidak dipakai frontend, karena Beranda memakai `/ringkasan`.

## 3. Checklist acceptance criteria

> Sesuaikan baris ini dengan user stories Phase 1 tim. Kolom "Kode" berdasarkan pembacaan kode.
> Kolom "Backend asli" baru boleh dicentang setelah diuji dan buktinya ada di `docs/bukti/`.

| # | Kriteria | Kode | Tes otomatis | Backend asli | Bukti |
|---|---|---|---|---|---|
| 1 | Pengguna dapat register lalu login | ✅ | – | ☐ | `01-register-login.mp4` |
| 2 | Kategori awal tersedia setelah register | ✅ | – | ☐ | `02-kategori-awal.png` |
| 3 | Pengguna dapat menambah transaksi | ✅ | – | ☐ | `03-tambah-transaksi.mp4` |
| 4 | Pengguna dapat mengubah dan menghapus transaksi | ✅ | – | ☐ | `04-ubah-hapus.mp4` |
| 5 | Pengguna dapat menambah dan menghapus kategori | ✅ | – | ☐ | `05-kategori.mp4` |
| 6 | Jenis transaksi harus sesuai jenis kategori | ✅ (backend 422) | – | ☐ | `06-validasi-jenis.png` |
| 7 | Beranda menampilkan saldo total seluruh transaksi | ✅ | `SummaryModel.fromJson membaca saldo, total, dan transaksi terbaru` | ☐ | `07-saldo-total.png` |
| 8 | Riwayat menampilkan tab Semua dan Pengeluaran | ✅ | `tab Semua…`, `tab Pengeluaran…` | ☐ | `08-riwayat.png` |
| 9 | Riwayat dapat difilter kategori dan tanggal | ✅ | `filter kategori…`, `filter tanggal…` | ☐ | `09-filter.png` |
| 10 | Pengguna dapat mengubah profil | ✅ | – | ☐ | `10-profil.png` |
| 11 | Pengguna dapat mengambil foto profil dari kamera/galeri | ✅ (disimpan lokal per user) | `UserModel.copyWith mempertahankan id dan foto` | ☐ | `11-foto-profil.mp4` |
| 12 | Sesi dipulihkan saat aplikasi dibuka ulang | ✅ | `token tersimpan bisa dipulihkan lewat loadToken` | ☐ | `12-pulihkan-sesi.mp4` |
| 13 | Token ditolak (401) mengembalikan ke Login | ✅ | `401 dengan token memanggil onUnauthorized` | ☐ | `13-sesi-berakhir.mp4` |
| 14 | Salah password tidak memicu logout otomatis | ✅ | `401 tanpa token (salah password)…` | ☐ | – |
| 15 | Loading, kosong, dan error tampil; ada tombol "Coba lagi" | ✅ | `gagal terhubung diterjemahkan menjadi pesan yang ramah` | ☐ | `15-banner-error.mp4` |
| 16 | Pull-to-refresh di Beranda dan Riwayat | ✅ | – | ☐ | `16-refresh.mp4` |

## 4. Bukti pengujian otomatis

`flutter test` dijalankan dari folder `frontend`. Target: **All tests passed! (17 test)**. Lampirkan screenshot di `docs/bukti/00-flutter-test.png`.

| File | Jumlah | Yang diuji |
|---|---|---|
| `test/api_client_test.dart` | 7 | header Bearer, pemulihan token, pesan error 422/500, 401 dengan/tanpa token, gagal koneksi |
| `test/models_test.dart` | 6 | parsing transaksi (nominal teks, kategori, zona waktu UTC), ringkasan, `UserModel.copyWith` |
| `test/transaction_service_test.dart` | 4 | total riwayat, filter tab, kategori, dan tanggal |

Tes memakai `MockClient` (`package:http/testing.dart`) dan `FakeTokenStorage`, sehingga tidak membutuhkan server. Integrasi ke server asli diuji manual lewat bagian 3.

## 5. Autentikasi dan keamanan

| Kontrol | Implementasi |
|---|---|
| Autentikasi | Laravel Sanctum, token Bearer |
| Password | Di-hash, minimal 8 karakter, konfirmasi saat register |
| Otorisasi | `id_user` dari token; kategori dan transaksi dibatasi ke pemilik |
| Penyimpanan token | `flutter_secure_storage` (terenkripsi), bukan `SharedPreferences` |
| Sesi kedaluwarsa | 401 saat memakai token → logout otomatis dan kembali ke Login |
| Backup Android | `android:allowBackup="false"` |
| HTTP polos | Hanya diizinkan di manifest debug dan profile (`usesCleartextTraffic`). Manifest rilis menolaknya |
| HTTPS | Belum diterapkan pada lingkungan pengembangan (jaringan lokal). Untuk produksi wajib HTTPS, dan build rilis sudah memaksanya dengan menolak HTTP |

## 6. Capability, persistence, dan keterbatasan

- **Capability:** kamera dan galeri lewat `image_picker` (diuji di Android atau desktop, bukan browser).
- **Persistence:** token di secure storage; foto profil disalin ke folder aplikasi dan path-nya disimpan per user.
- **Keterbatasan yang diketahui (disampaikan terbuka):**
  - Data transaksi dan ringkasan belum di-cache; saat offline aplikasi menampilkan banner "Coba lagi". Server dijadikan sumber kebenaran.
  - Foto profil masih disimpan lokal. Backend sudah mendukung unggah (`PUT /profil` dengan `foto_profil`), tetapi frontend belum menghubungkannya.
  - Kategori belum bisa diedit dari aplikasi (backend sudah mendukung).

## 7. Skenario demo (urut)

1. Register akun baru (atau login dengan akun demo jika seeder demo sudah diperbaiki dan dijalankan).
2. Tambah pemasukan Rp 1.000.000 bertanggal **bulan lalu**, lalu pengeluaran Rp 200.000 **bulan ini**.
3. Beranda harus menampilkan Saldo Rp 800.000, Pemasukan Rp 1.000.000, Pengeluaran Rp 200.000.
4. Ubah dan hapus satu transaksi; tambah dan hapus satu kategori.
5. Matikan backend, tarik layar untuk refresh → banner "Coba lagi" muncul; nyalakan lagi, tekan tombolnya → data muncul.
6. Ambil foto profil dari galeri atau kamera.
7. Tutup aplikasi lalu buka lagi → langsung masuk Beranda.