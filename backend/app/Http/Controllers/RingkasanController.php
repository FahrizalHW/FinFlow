<?php

namespace App\Http\Controllers;

use App\Models\Transaksi;
use Illuminate\Http\Request;

class RingkasanController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();

        // Semua transaksi milik user yang sedang login.
        $semuaTransaksi = Transaksi::where(
            'id_user',
            $user->id_user
        );

        // Total pemasukan sepanjang waktu.
        $totalPemasukan = (clone $semuaTransaksi)
            ->where('jenis_transaksi', 'pemasukan')
            ->sum('nominal');

        // Total pengeluaran sepanjang waktu.
        $totalPengeluaran = (clone $semuaTransaksi)
            ->where('jenis_transaksi', 'pengeluaran')
            ->sum('nominal');

        // Awal dan akhir bulan berjalan.
        $awalBulan = now()->startOfMonth()->toDateString();
        $akhirBulan = now()->endOfMonth()->toDateString();

        // Pemasukan bulan ini.
        $pemasukanBulanIni = (clone $semuaTransaksi)
            ->where('jenis_transaksi', 'pemasukan')
            ->whereBetween('tanggal_transaksi', [
                $awalBulan,
                $akhirBulan,
            ])
            ->sum('nominal');

        // Pengeluaran bulan ini.
        $pengeluaranBulanIni = (clone $semuaTransaksi)
            ->where('jenis_transaksi', 'pengeluaran')
            ->whereBetween('tanggal_transaksi', [
                $awalBulan,
                $akhirBulan,
            ])
            ->sum('nominal');

        // Lima transaksi terbaru.
        $transaksiTerbaru = (clone $semuaTransaksi)
            ->with('kategori')
            ->orderByDesc('tanggal_transaksi')
            ->orderByDesc('id_transaksi')
            ->limit(5)
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Ringkasan berhasil diambil.',
            'data' => [
                // Saldo sepanjang waktu.
                'saldo' => (float) $totalPemasukan
                    - (float) $totalPengeluaran,

                // Total sepanjang waktu.
                'total_pemasukan' => (float) $totalPemasukan,
                'total_pengeluaran' => (float) $totalPengeluaran,

                // Total bulan berjalan.
                'pemasukan_bulan_ini' => (float) $pemasukanBulanIni,
                'pengeluaran_bulan_ini' => (float) $pengeluaranBulanIni,

                // Lima transaksi terbaru.
                'transaksi_terbaru' => $transaksiTerbaru,
            ],
        ]);
    }
}
