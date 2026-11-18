<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\KategoriController;
use App\Http\Controllers\Api\TransaksiController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\ProfilController;
use App\Http\Controllers\RingkasanController;

Route::get('/health', function () {
    return response()->json([
        'success' => true,
        'message' => 'FinFlow API berjalan dengan baik!',
        'data' => [
            'app' => 'FinFlow',
            'status' => 'running',
        ],
    ]);
});

// Route yang tidak memerlukan login
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Semua route di bawah ini memerlukan token Sanctum
Route::middleware('auth:sanctum')->group(function () {
    Route::put('/profil', [ProfilController::class, 'update']);

    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);

    Route::apiResource('kategori', KategoriController::class);
    Route::apiResource('transaksi', TransaksiController::class);

    Route::get('/dashboard', [DashboardController::class, 'index']);
    Route::get('/ringkasan', [RingkasanController::class, 'index']);
});
