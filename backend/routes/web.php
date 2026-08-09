<?php

use App\Http\Controllers\Web\AnalyticsWebController;
use App\Http\Controllers\Web\AuthController;
use App\Http\Controllers\Web\ChildWebController;
use App\Http\Controllers\Web\DashboardController;
use App\Http\Controllers\Web\PendingWebController;
use App\Http\Controllers\Web\RewardWebController;
use App\Http\Controllers\Web\TaskWebController;
use Illuminate\Support\Facades\Route;

Route::middleware('guest')->group(function () {
    Route::get('/login', [AuthController::class, 'showLogin'])->name('login');
    Route::post('/login', [AuthController::class, 'login']);
    Route::get('/register', [AuthController::class, 'showRegister'])->name('register');
    Route::post('/register', [AuthController::class, 'register']);
});

Route::middleware('auth')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout'])->name('logout');

    Route::get('/', fn() => redirect('/dashboard'));
    Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard');

    // Children Web Routes
    Route::get('/children', [ChildWebController::class, 'index'])->name('children.index');
    Route::get('/children/create', [ChildWebController::class, 'create'])->name('children.create');
    Route::post('/children', [ChildWebController::class, 'store'])->name('children.store');
    Route::delete('/children/{id}', [ChildWebController::class, 'destroy'])->name('children.destroy');

    // Tasks Web Routes
    Route::get('/tasks', [TaskWebController::class, 'index'])->name('tasks.index');
    Route::get('/tasks/create', [TaskWebController::class, 'create'])->name('tasks.create');
    Route::post('/tasks', [TaskWebController::class, 'store'])->name('tasks.store');
    Route::delete('/tasks/{id}', [TaskWebController::class, 'destroy'])->name('tasks.destroy');

    // Pending Approvals Web Routes
    Route::get('/pending', [PendingWebController::class, 'index'])->name('pending.index');
    Route::post('/pending/{id}/approve', [PendingWebController::class, 'approve'])->name('pending.approve');
    Route::post('/pending/{id}/reject', [PendingWebController::class, 'reject'])->name('pending.reject');

    // Rewards Web Routes
    Route::get('/rewards', [RewardWebController::class, 'index'])->name('rewards.index');
    Route::post('/rewards', [RewardWebController::class, 'store'])->name('rewards.store');
    Route::delete('/rewards/{id}', [RewardWebController::class, 'destroy'])->name('rewards.destroy');

    // Analytics Web Routes
    Route::get('/analytics', [AnalyticsWebController::class, 'index'])->name('analytics.index');
});
