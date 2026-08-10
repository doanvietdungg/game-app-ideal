<?php

use Illuminate\Support\Facades\Route;
use KidTime\Presentation\Api\V1\AnalyticsController;
use KidTime\Presentation\Api\V1\AuthController;
use KidTime\Presentation\Api\V1\ChildController;
use KidTime\Presentation\Api\V1\PinController;
use KidTime\Presentation\Api\V1\RewardController;
use KidTime\Presentation\Api\V1\TaskController;
use KidTime\Presentation\Api\V1\TaskLogController;
use KidTime\Presentation\Api\V1\MobileProfileController;

Route::prefix('v1')->group(function () {
    // Auth public routes
    Route::post('auth/register', [AuthController::class, 'register']);
    Route::post('auth/login', [AuthController::class, 'login']);
    Route::post('auth/child-login', [AuthController::class, 'childLogin']);
    Route::post('pin/verify', [PinController::class, 'verify']);

    // Task Logs approval public endpoints (for demo & app approvals)
    Route::get('task-logs/pending', [TaskLogController::class, 'pending']);
    Route::post('task-logs', [TaskLogController::class, 'submit']);
    Route::post('task-logs/{id}/approve', [TaskLogController::class, 'approve']);
    Route::post('task-logs/{id}/reject', [TaskLogController::class, 'reject']);

    // Mobile Profile & Tasks public endpoints for mobile app
    Route::get('children/{id}/profile', [MobileProfileController::class, 'profile']);
    Route::get('children/{id}/tasks/today', [MobileProfileController::class, 'todayTasks']);
    Route::post('children/{id}/pet/skin', [MobileProfileController::class, 'changeOrUnlockSkin']);

    // Mobile Rewards public endpoints
    Route::get('rewards', [RewardController::class, 'index']);
    Route::post('rewards/{id}/redeem', [RewardController::class, 'redeem']);

    // Protected routes (Sanctum)
    Route::middleware('auth:sanctum')->group(function () {
        Route::post('auth/logout', [AuthController::class, 'logout']);
        Route::get('auth/me', [AuthController::class, 'me']);

        // Children routes
        Route::get('children', [ChildController::class, 'index']);
        Route::post('children', [ChildController::class, 'store']);

        // Tasks routes
        Route::get('tasks/templates', [TaskController::class, 'templates']);
        Route::get('tasks', [TaskController::class, 'index']);
        Route::post('tasks', [TaskController::class, 'store']);
        Route::delete('tasks/{id}', [TaskController::class, 'destroy']);

        // Rewards routes
        Route::get('rewards', [RewardController::class, 'index']);
        Route::post('rewards', [RewardController::class, 'store']);
        Route::post('rewards/{id}/redeem', [RewardController::class, 'redeem']);

        // Analytics routes
        Route::get('analytics/weekly/{childId}', [AnalyticsController::class, 'weekly']);

        // Mobile profile & custom support endpoints
        Route::post('children/{id}/pet/skin', [MobileProfileController::class, 'changeOrUnlockSkin']);
        Route::post('notifications/register', [MobileProfileController::class, 'registerFcmToken']);
        Route::post('blocking/apps', [MobileProfileController::class, 'syncApps']);
    });
});
