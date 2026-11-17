<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;

class HealthController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json([
            'success' => true,
            'message' => 'FinFlow API berjalan dengan baik!',
            'data' => [
                'app' => 'FinFlow',
                'status' => 'running',
            ],
        ]);
    }
}
