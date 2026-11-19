<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class ProfilController extends Controller
{
    public function update(Request $request)
    {
        $user = $request->user();

        // Validasi data yang dikirim frontend
        $validated = $request->validate([
            'username' => [
                'sometimes',
                'nullable',
                'string',
                'max:255',
                Rule::unique('users', 'username')
                    ->ignore($user->id_user, 'id_user'),
            ],

            'password' => [
                'sometimes',
                'nullable',
                'string',
                'min:8',
                'confirmed',
            ],

            'foto_profil' => [
                'sometimes',
                'nullable',
                'image',
                'mimes:jpg,jpeg,png,webp',
                'max:2048',
            ],

            'hapus_foto' => [
                'sometimes',
                'boolean',
            ],
        ]);

        // Update username
        if (!empty($validated['username'])) {
            $user->username = $validated['username'];
        }

        // Update password
        if (!empty($validated['password'])) {
            $user->password = Hash::make(
                $validated['password']
            );
        }

        // Hapus foto profil
        if ($request->boolean('hapus_foto')) {

            if ($user->foto_profil) {
                Storage::disk('public')->delete(
                    $user->foto_profil
                );
            }

            $user->foto_profil = null;
        }

        // Upload foto profil baru
        if ($request->hasFile('foto_profil')) {

            // Hapus foto lama
            if ($user->foto_profil) {
                Storage::disk('public')->delete(
                    $user->foto_profil
                );
            }

            // Simpan foto baru ke storage
            $path = $request->file('foto_profil')
                ->store('profile-photos', 'public');

            // Simpan path ke database
            $user->foto_profil = $path;
        }

        // Simpan perubahan user
        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Profil berhasil diperbarui.',
            'data' => [
                'user' => [
                    'id_user' => $user->id_user,
                    'username' => $user->username,
                    'foto_profil' => $user->foto_profil,
                    'foto_profil_url' => $user->foto_profil
                        ? url('storage/' . $user->foto_profil)
                        : null,
                ],
            ],
        ], 200);
    }
}
