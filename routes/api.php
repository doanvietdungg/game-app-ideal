<?php

use Illuminate\Support\Facades\Route;
use KidTime\Presentation\Api\V1\AuthController;
use KidTime\Presentation\Api\V1\ChildController;

Route::prefix('v1')->group(function () {
    // Auth public routes
    Route::post('auth/register', [AuthController::class, 'register']);
    Route::post('auth/login', [AuthController::class, 'login']);
    Route::post('auth/child-login', [AuthController::class, 'childLogin']);

    // Protected routes (Sanctum)
    Route::middleware('auth:sanctum')->group(function () {
        Route::post('auth/logout', [AuthController::class, 'logout']);
        Route::get('auth/me', [AuthController::class, 'me']);

        // Children routes
        Route::get('children', [ChildController::class, 'index']);
        Route::post('children', [ChildController::class, 'store']);
    });
});
