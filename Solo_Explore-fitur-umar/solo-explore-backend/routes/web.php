<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Admin\AuthController as AdminAuthController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\DestinationController as AdminDestinationController;
use App\Http\Controllers\Admin\CulinaryController as AdminCulinaryController;
use App\Http\Controllers\Admin\EventController as AdminEventController;
use App\Http\Controllers\Admin\UserController as AdminUserController;
use App\Http\Controllers\Admin\CategoryController as AdminCategoryController;
use App\Http\Controllers\Auth\MitraRegisterController;

// Mitra registration routes
Route::get('/register-mitra', [MitraRegisterController::class, 'showRegistrationForm'])->name('register.mitra');
Route::post('/register-mitra', [MitraRegisterController::class, 'register'])->name('register.mitra.store');

Route::get('/', function () {
    return redirect()->route('admin.login');
});

// Admin routes
Route::prefix('admin')->name('admin.')->group(function () {
    // Auth routes (no middleware)
    Route::get('login', [AdminAuthController::class, 'showLogin'])->name('login');
    Route::post('login', [AdminAuthController::class, 'login']);
    
    // Protected admin routes
    Route::middleware(['auth', 'admin'])->group(function () {
        Route::get('/', [DashboardController::class, 'index'])->name('dashboard');
        Route::post('logout', [AdminAuthController::class, 'logout'])->name('logout');
        
        // Resource routes
        Route::get('/users/requests', [AdminUserController::class, 'mitraRequests'])->name('users.requests');
        Route::post('/users/{user}/approve', [AdminUserController::class, 'approveMitra'])->name('users.approve');
        Route::post('/users/{user}/reject', [AdminUserController::class, 'rejectMitra'])->name('users.reject');
        Route::resource('destinations', AdminDestinationController::class);
        Route::resource('culinaries', AdminCulinaryController::class);
        Route::resource('events', AdminEventController::class);
        Route::resource('users', AdminUserController::class);
        Route::resource('categories', AdminCategoryController::class);
    });
});
