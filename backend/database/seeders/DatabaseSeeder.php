<?php

namespace Database\Seeders;

use App\Models\Kategori;
use App\Models\Transaksi;
use App\Models\User;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // Kredensial ini khusus untuk demo/pengembangan lokal.
        $demo = User::firstOrCreate(
            ['username' => 'demo'],
            ['password' => 'password123']
        );

        $kategoriDemo = [
            'Gaji' => 'pemasukan',
            'Bonus' => 'pemasukan',
            'Makanan' => 'pengeluaran',
            'Transport' => 'pengeluaran',
            'Belanja' => 'pengeluaran',
        ];

        foreach ($kategoriDemo as $nama => $jenis) {
            Kategori::firstOrCreate([
                'id_user' => $demo->id_user,
                'nama_kategori' => $nama,
                'jenis_kategori' => $jenis,
            ]);
        }

        // Buat contoh transaksi hanya jika akun demo belum memilikinya.
        // Seeder aman dijalankan ulang tanpa menggandakan transaksi.
        if (!$demo->transaksi()->exists()) {
            $kategori = $demo->kategori()
                ->get()
                ->keyBy('nama_kategori');

            $contohTransaksi = [
                [
                    'nama_transaksi' => 'Gaji Bulanan',
                    'kategori' => 'Gaji',
                    'jenis_transaksi' => 'pemasukan',
                    'tanggal_transaksi' => now()->startOfMonth()->addDays(2)->toDateString(),
                    'nominal' => 5000000,
                    'catatan' => 'Contoh pemasukan untuk demo',
                ],
                [
                    'nama_transaksi' => 'Bonus Proyek',
                    'kategori' => 'Bonus',
                    'jenis_transaksi' => 'pemasukan',
                    'tanggal_transaksi' => now()->startOfMonth()->addDays(5)->toDateString(),
                    'nominal' => 750000,
                    'catatan' => 'Contoh bonus',
                ],
                [
                    'nama_transaksi' => 'Belanja Bulanan',
                    'kategori' => 'Belanja',
                    'jenis_transaksi' => 'pengeluaran',
                    'tanggal_transaksi' => now()->startOfMonth()->addDays(7)->toDateString(),
                    'nominal' => 650000,
                    'catatan' => 'Contoh belanja kebutuhan',
                ],
                [
                    'nama_transaksi' => 'Makan Siang',
                    'kategori' => 'Makanan',
                    'jenis_transaksi' => 'pengeluaran',
                    'tanggal_transaksi' => now()->startOfMonth()->addDays(9)->toDateString(),
                    'nominal' => 45000,
                    'catatan' => 'Contoh pengeluaran makan',
                ],
                [
                    'nama_transaksi' => 'Transport Harian',
                    'kategori' => 'Transport',
                    'jenis_transaksi' => 'pengeluaran',
                    'tanggal_transaksi' => now()->startOfMonth()->addDays(11)->toDateString(),
                    'nominal' => 30000,
                    'catatan' => 'Contoh biaya transportasi',
                ],
            ];

            foreach ($contohTransaksi as $item) {
                $namaKategori = $item['kategori'];
                unset($item['kategori']);

                $demo->transaksi()->create([
                    ...$item,
                    'id_kategori' => $kategori->get($namaKategori)->id_kategori,
                ]);
            }
        }
    }
}