<?php

namespace App\Http\Controllers;

use App\Models\Transaksi;
use Illuminate\Http\Request;

class RingkasanController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $semuaTransaksi = Transaksi::where('id_user', $user->id_user);
        $pemasukan = (clone $semuaTransaksi)
        ->where('jenis_transaksi', 'pemasukan')
        ->sum('nominal');

        $pengeluaran = (clone $semuaTransaksi)
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
            'saldo' => (float) $totalPemasukan - (float) $totalPengeluaran,
            'total_pemasukan' => (float) $totalPemasukan,
            'total_pengeluaran' => (float) $totalPengeluaran,
            'transaksi_terbaru' => $transaksiTerbaru,
        ],
    ]);
}
}