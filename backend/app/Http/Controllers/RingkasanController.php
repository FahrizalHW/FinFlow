<?php

namespace App\Http\Controllers;

use App\Models\Transaksi;
use Illuminate\Http\Request;

class RingkasanController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();

        $awalBulan = now()->startOfMonth()->toDateString();
        $akhirBulan = now()->endOfMonth()->toDateString();

        $transaksiBulanIni = Transaksi::where('id_user', $user->id_user)
            ->whereBetween('tanggal_transaksi', [
                $awalBulan,
                $akhirBulan,
            ]);

        $pemasukan = (clone $transaksiBulanIni)
            ->where('jenis_transaksi', 'pemasukan')
            ->sum('nominal');

        $pengeluaran = (clone $transaksiBulanIni)
            ->where('jenis_transaksi', 'pengeluaran')
            ->sum('nominal');

        $transaksiTerbaru = Transaksi::with('kategori')
            ->where('id_user', $user->id_user)
            ->orderByDesc('tanggal_transaksi')
            ->orderByDesc('id_transaksi')
            ->limit(5)
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Ringkasan berhasil diambil.',
            'data' => [
                'saldo' => (float) $pemasukan - (float) $pengeluaran,
                'pemasukan_bulan_ini' => (float) $pemasukan,
                'pengeluaran_bulan_ini' => (float) $pengeluaran,
                'transaksi_terbaru' => $transaksiTerbaru,
            ],
        ]);
    }
}