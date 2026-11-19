<?php

namespace App\Http\Controllers;

use App\Models\Transaksi;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RingkasanController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $transaksiUser = Transaksi::query()
            ->where('id_user', $request->user()->id_user);

        // Angka total dipakai SummaryModel Flutter untuk kartu ringkasan.
        $totalPemasukan = (clone $transaksiUser)
            ->where('jenis_transaksi', 'pemasukan')
            ->sum('nominal');

        $totalPengeluaran = (clone $transaksiUser)
            ->where('jenis_transaksi', 'pengeluaran')
            ->sum('nominal');

        // Tetap sediakan angka bulan berjalan agar endpoint kompatibel
        // dengan pemanggil API versi sebelumnya.
        $awalBulan = now()->startOfMonth()->toDateString();
        $akhirBulan = now()->endOfMonth()->toDateString();

        $pemasukanBulanIni = (clone $transaksiUser)
            ->where('jenis_transaksi', 'pemasukan')
            ->whereBetween('tanggal_transaksi', [$awalBulan, $akhirBulan])
            ->sum('nominal');

        $pengeluaranBulanIni = (clone $transaksiUser)
            ->where('jenis_transaksi', 'pengeluaran')
            ->whereBetween('tanggal_transaksi', [$awalBulan, $akhirBulan])
            ->sum('nominal');

        $transaksiTerbaru = (clone $transaksiUser)
            ->with('kategori')
            ->orderByDesc('tanggal_transaksi')
            ->orderByDesc('id_transaksi')
            ->limit(5)
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Ringkasan berhasil diambil.',
            'data' => [
                'saldo' => (float) $totalPemasukan - (float) $totalPengeluaran,
                'total_pemasukan' => (float) $totalPemasukan,
                'total_pengeluaran' => (float) $totalPengeluaran,
                'pemasukan_bulan_ini' => (float) $pemasukanBulanIni,
                'pengeluaran_bulan_ini' => (float) $pengeluaranBulanIni,
                'transaksi_terbaru' => $transaksiTerbaru,
            ],
        ]);
    }
}