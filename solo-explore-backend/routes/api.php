<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\DestinationController;
use App\Http\Controllers\Api\CulinaryController;
use App\Http\Controllers\Api\EventController;
use App\Http\Controllers\Api\ReviewController;
use App\Http\Controllers\Api\BookmarkController;
use App\Http\Controllers\Api\VisitController;
use App\Http\Controllers\Api\BadgeController;
use App\Http\Controllers\Api\RewardController;
use App\Http\Controllers\Api\TripPlanController;
use App\Http\Controllers\Api\ProfileController;
use App\Http\Controllers\Api\SearchController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\PasswordResetController;
use App\Http\Controllers\Api\SocialAuthController;
use App\Http\Controllers\Api\AIPlannerController;
use App\Http\Controllers\Api\ImageProxyController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// Public routes
Route::prefix('auth')->group(function () {
    Route::post('register', [AuthController::class, 'register']);
    Route::post('login', [AuthController::class, 'login']);
    
    // Social Login (Mobile - Token based)
    Route::post('google', [SocialAuthController::class, 'loginWithGoogle']);
    Route::post('facebook', [SocialAuthController::class, 'loginWithFacebook']);
});

// Password Reset routes
Route::prefix('password')->group(function () {
    Route::post('forgot', [PasswordResetController::class, 'sendResetLink']);
    Route::post('reset', [PasswordResetController::class, 'resetPassword']);
    Route::post('verify-token', [PasswordResetController::class, 'verifyToken']);
});

// Public data routes
    // Recommendations
Route::get('/destinations/recommendations', [DestinationController::class, 'recommendations']);
Route::get('/culinaries/recommendations', [CulinaryController::class, 'recommendations']);

Route::get('categories', [CategoryController::class, 'index']);
Route::get('destinations', [DestinationController::class, 'index']);
Route::get('destinations/{slug}', [DestinationController::class, 'show']);
Route::get('destinations/category/{slug}', [DestinationController::class, 'byCategory']);
Route::get('culinaries', [CulinaryController::class, 'index']);
Route::get('culinaries/{slug}', [CulinaryController::class, 'show']);
Route::get('events', [EventController::class, 'index']);
Route::get('events/{slug}', [EventController::class, 'show']);
Route::get('events/month/{year}/{month}', [EventController::class, 'byMonth']);
Route::get('search', [SearchController::class, 'search']);

// Image Proxy (to avoid CORS issues with external images)
Route::get('proxy-image', [ImageProxyController::class, 'proxy']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    // Auth
    Route::prefix('auth')->group(function () {
        Route::post('logout', [AuthController::class, 'logout']);
        Route::get('me', [AuthController::class, 'me']);
    });

    // Profile
    Route::prefix('profile')->group(function () {
        Route::get('/', [ProfileController::class, 'show']);
        Route::put('/', [ProfileController::class, 'update']);
        Route::post('/avatar', [ProfileController::class, 'updateAvatar']);
        Route::get('/stats', [ProfileController::class, 'stats']);
    });

    // Reviews
    Route::apiResource('reviews', ReviewController::class);
    Route::post('destinations/{id}/reviews', [ReviewController::class, 'storeForDestination']);
    Route::post('culinaries/{id}/reviews', [ReviewController::class, 'storeForCulinary']);

    // Bookmarks
    Route::prefix('bookmarks')->group(function () {
        Route::get('/', [BookmarkController::class, 'index']);
        Route::post('/destinations/{id}', [BookmarkController::class, 'toggleDestination']);
        Route::post('/culinaries/{id}', [BookmarkController::class, 'toggleCulinary']);
        Route::post('/events/{id}', [BookmarkController::class, 'toggleEvent']);
    });

    // Visits
    Route::prefix('visits')->group(function () {
        Route::get('/', [VisitController::class, 'index']);
        Route::post('/destinations/{id}', [VisitController::class, 'recordDestination']);
        Route::post('/culinaries/{id}', [VisitController::class, 'recordCulinary']);
        Route::post('/events/{id}', [VisitController::class, 'recordEvent']);
    });

    // Badges
    Route::get('badges', [BadgeController::class, 'index']);
    Route::get('badges/my', [BadgeController::class, 'myBadges']);

    // Rewards
    Route::prefix('rewards')->group(function () {
        Route::get('/', [RewardController::class, 'index']);
        Route::get('/available', [RewardController::class, 'available']);
        Route::get('/my', [RewardController::class, 'myRewards']);
        Route::post('/{id}/claim', [RewardController::class, 'claim']);
        Route::post('/{id}/use', [RewardController::class, 'use']);
    });

    // Trip Plans
    Route::apiResource('trip-plans', TripPlanController::class);
    Route::post('trip-plans/{id}/items', [TripPlanController::class, 'addItem']);
    Route::delete('trip-plans/{id}/items/{itemId}', [TripPlanController::class, 'removeItem']);
    Route::post('trip-plans/{id}/generate', [TripPlanController::class, 'generate']);

    // AI Planner
    Route::prefix('ai-planner')->group(function () {
        Route::get('/available-items', [AIPlannerController::class, 'getAvailableItems']);
        Route::post('/generate-itinerary', [AIPlannerController::class, 'generateItinerary']);
        Route::post('/recommendations', [AIPlannerController::class, 'getRecommendations']);
    });

    // Notifications
    Route::prefix('notifications')->group(function () {
        Route::get('/', [NotificationController::class, 'index']);
        Route::get('/unread-count', [NotificationController::class, 'unreadCount']);
        Route::post('/{id}/read', [NotificationController::class, 'markAsRead']);
        Route::post('/read-all', [NotificationController::class, 'markAllAsRead']);
        Route::delete('/{id}', [NotificationController::class, 'destroy']);
        Route::delete('/read/all', [NotificationController::class, 'deleteAllRead']);
    });
});
