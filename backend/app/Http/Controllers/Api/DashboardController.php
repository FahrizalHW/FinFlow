<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function index(Request $request)
    {
        $query = $request->user()->transaksi();

        $pemasukan = (clone $query)
            ->where('jenis_transaksi', 'pemasukan')
            ->sum('nominal');

        $pengeluaran = (clone $query)
            ->where('jenis_transaksi', 'pengeluaran')
            ->sum('nominal');

        $jumlahTransaksi = (clone $query)->count();

        return response()->json([
            'success' => true,
            'message' => 'Dashboard berhasil diambil.',
            'data' => [
                'total_pemasukan' => (float) $pemasukan,
                'total_pengeluaran' => (float) $pengeluaran,
                'saldo' => (float) $pemasukan - (float) $pengeluaran,
                'jumlah_transaksi' => $jumlahTransaksi,
            ],
        ]);
    }
}