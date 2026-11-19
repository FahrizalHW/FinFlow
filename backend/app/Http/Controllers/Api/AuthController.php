<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function register(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'username' => ['required', 'string', 'min:3', 'max:255', 'unique:users,username'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
        ]);

        [$user, $token] = DB::transaction(function () use ($validated) {
            $user = User::create([
                'username' => trim($validated['username']),
                'password' => $validated['password'],
            ]);

            // Setiap akun baru langsung mendapat kategori awal miliknya sendiri.
            $user->kategori()->createMany([
                ['nama_kategori' => 'Gaji', 'jenis_kategori' => 'pemasukan'],
                ['nama_kategori' => 'Bonus', 'jenis_kategori' => 'pemasukan'],
                ['nama_kategori' => 'Makanan', 'jenis_kategori' => 'pengeluaran'],
                ['nama_kategori' => 'Transport', 'jenis_kategori' => 'pengeluaran'],
                ['nama_kategori' => 'Belanja', 'jenis_kategori' => 'pengeluaran'],
            ]);

            $token = $user->createToken('finflow-mobile')->plainTextToken;

            return [$user->fresh(), $token];
        });

        return response()->json([
            'success' => true,
            'message' => 'Registrasi berhasil.',
            'data' => [
                'user' => $user,
                'token' => $token,
                'token_type' => 'Bearer',
            ],
        ], 201);
    }

    public function login(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'username' => ['required', 'string'],
            'password' => ['required', 'string'],
        ]);

        $user = User::where('username', trim($validated['username']))->first();

        if (!$user || !Hash::check($validated['password'], $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Username atau password salah.',
            ], 401);
        }

        $token = $user->createToken('finflow-mobile')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil.',
            'data' => [
                'user' => $user,
                'token' => $token,
                'token_type' => 'Bearer',
            ],
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $token = $request->user()->currentAccessToken();

        if ($token && method_exists($token, 'delete')) {
            $token->delete();
        }

        return response()->json([
            'success' => true,
            'message' => 'Logout berhasil.',
        ]);
    }

    public function me(Request $request): JsonResponse
    {
        return response()->json([
            'success' => true,
            'message' => 'Data pengguna berhasil diambil.',
            'data' => [
                'user' => $request->user(),
            ],
        ]);
    }
}