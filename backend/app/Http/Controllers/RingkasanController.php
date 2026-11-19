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

        // Total pemasukan dan pengeluaran sepanjang waktu.
        $totalPemasukan = (clone $semuaTransaksi)
            ->where('jenis_transaksi', 'pemasukan')
            ->sum('nominal');

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

        // Lima transaksi terbaru milik user.
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
            'saldo' => (float) $totalPemasukan - (float) $totalPengeluaran,
            'total_pemasukan' => (float) $totalPemasukan,
            'total_pengeluaran' => (float) $totalPengeluaran,
            'transaksi_terbaru' => $transaksiTerbaru,
        ],
    ]);
}
}