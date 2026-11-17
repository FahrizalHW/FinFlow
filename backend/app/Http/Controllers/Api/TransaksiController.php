<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Kategori;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class TransaksiController extends Controller
{
    private function rules(Request $request, bool $partial = false): array
    {
        $required = $partial ? 'sometimes|required|' : 'required|';

        return [
            'id_kategori' => [
                $partial ? 'sometimes' : 'required',
                'required_if:jenis_transaksi,',
                'integer',
                Rule::exists('kategori', 'id_kategori')
                    ->where(fn ($query) => $query->where(
                        'id_user',
                        $request->user()->id_user
                    )),
            ],
            'nama_transaksi' => $required . 'string|max:255',
            'jenis_transaksi' => $required . 'in:pemasukan,pengeluaran',
            'tanggal_transaksi' => $required . 'date',
            'nominal' => $required . 'numeric|min:0.01',
            'catatan' => 'sometimes|nullable|string',
        ];
    }

    public function index(Request $request)
    {
        $transaksi = $request->user()
            ->transaksi()
            ->with('kategori')
            ->orderByDesc('tanggal_transaksi')
            ->orderByDesc('id_transaksi')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Daftar transaksi berhasil diambil.',
            'data' => $transaksi,
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'id_kategori' => [
                'required',
                'integer',
                Rule::exists('kategori', 'id_kategori')
                    ->where(fn ($query) => $query->where(
                        'id_user',
                        $request->user()->id_user
                    )),
            ],
            'nama_transaksi' => 'required|string|max:255',
            'jenis_transaksi' => 'required|in:pemasukan,pengeluaran',
            'tanggal_transaksi' => 'required|date',
            'nominal' => 'required|numeric|min:0.01',
            'catatan' => 'nullable|string',
        ]);

        $kategori = Kategori::where('id_user', $request->user()->id_user)
            ->findOrFail($validated['id_kategori']);

        if ($kategori->jenis_kategori !== $validated['jenis_transaksi']) {
            return response()->json([
                'success' => false,
                'message' => 'Jenis transaksi harus sesuai dengan jenis kategori.',
            ], 422);
        }

        // id_user selalu berasal dari pengguna yang terautentikasi.
        $transaksi = $request->user()
            ->transaksi()
            ->create($validated);

        $transaksi->load('kategori');

        return response()->json([
            'success' => true,
            'message' => 'Transaksi berhasil ditambahkan.',
            'data' => $transaksi,
        ], 201);
    }

    public function show(Request $request, $id)
    {
        $transaksi = $request->user()
            ->transaksi()
            ->with('kategori')
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'message' => 'Detail transaksi berhasil diambil.',
            'data' => $transaksi,
        ]);
    }

    public function update(Request $request, $id)
    {
        $transaksi = $request->user()
            ->transaksi()
            ->findOrFail($id);

        $validated = $request->validate([
            'id_kategori' => [
                'sometimes',
                'required',
                'integer',
                Rule::exists('kategori', 'id_kategori')
                    ->where(fn ($query) => $query->where(
                        'id_user',
                        $request->user()->id_user
                    )),
            ],
            'nama_transaksi' => 'sometimes|required|string|max:255',
            'jenis_transaksi' => 'sometimes|required|in:pemasukan,pengeluaran',
            'tanggal_transaksi' => 'sometimes|required|date',
            'nominal' => 'sometimes|required|numeric|min:0.01',
            'catatan' => 'sometimes|nullable|string',
        ]);

        $kategoriId = $validated['id_kategori'] ?? $transaksi->id_kategori;
        $jenisTransaksi = $validated['jenis_transaksi']
            ?? $transaksi->jenis_transaksi;

        $kategori = Kategori::where('id_user', $request->user()->id_user)
            ->findOrFail($kategoriId);

        if ($kategori->jenis_kategori !== $jenisTransaksi) {
            return response()->json([
                'success' => false,
                'message' => 'Jenis transaksi harus sesuai dengan jenis kategori.',
            ], 422);
        }

        $transaksi->update($validated);
        $transaksi->load('kategori');

        return response()->json([
            'success' => true,
            'message' => 'Transaksi berhasil diperbarui.',
            'data' => $transaksi,
        ]);
    }

    public function destroy(Request $request, $id)
    {
        $transaksi = $request->user()
            ->transaksi()
            ->findOrFail($id);

        $transaksi->delete();

        return response()->json([
            'success' => true,
            'message' => 'Transaksi berhasil dihapus.',
        ]);
    }
}
