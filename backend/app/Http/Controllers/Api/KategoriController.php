<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Kategori;
use Illuminate\Http\Request;
use Illuminate\Database\QueryException;

class KategoriController extends Controller
{
    public function index(Request $request)
    {
        $kategori = $request->user()
            ->kategori()
            ->orderBy('nama_kategori')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Daftar kategori berhasil diambil.',
            'data' => $kategori,
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'nama_kategori' => 'required|string|max:255',
            'jenis_kategori' => 'required|in:pemasukan,pengeluaran',
        ]);

        // id_user otomatis diambil dari pengguna yang login.
        $kategori = $request->user()
            ->kategori()
            ->create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Kategori berhasil ditambahkan.',
            'data' => $kategori,
        ], 201);
    }

    public function show(Request $request, $id)
    {
        $kategori = $request->user()
            ->kategori()
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'message' => 'Detail kategori berhasil diambil.',
            'data' => $kategori,
        ]);
    }

    public function update(Request $request, $id)
    {
        $kategori = $request->user()
            ->kategori()
            ->findOrFail($id);

        $validated = $request->validate([
            'nama_kategori' => 'sometimes|required|string|max:255',
            'jenis_kategori' => 'sometimes|required|in:pemasukan,pengeluaran',
        ]);

        $kategori->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Kategori berhasil diperbarui.',
            'data' => $kategori->fresh(),
        ]);
    }

    public function destroy(Request $request, $id)
    {
        $kategori = $request->user()
            ->kategori()
            ->findOrFail($id);

        try {
            $kategori->delete();
        } catch (QueryException $e) {
            // Foreign key transaksi melarang kategori yang masih dipakai dihapus.
            return response()->json([
                'success' => false,
                'message' => 'Kategori tidak dapat dihapus karena masih digunakan oleh transaksi.',
            ], 409);
        }

        return response()->json([
            'success' => true,
            'message' => 'Kategori berhasil dihapus.',
        ]);
    }
}