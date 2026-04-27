<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\ValidationException;
use Carbon\Carbon;

class ProfileController extends Controller
{
    /**
     * Get user profile
     * GET /api/profile
     */
    public function show()
    {
        try {
            $user = auth()->user();

            return response()->json([
                'success' => true,
                'message' => 'Profile retrieved successfully',
                'data' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'phone' => $user->phone,
                    'avatar' => $user->avatar,
                    'bio' => $user->bio,
                    'level' => $user->level,
                    'level_title' => $user->level_title,
                    'points' => $user->points,
                    'total_destinations' => $user->total_destinations,
                    'is_verified' => $user->is_verified,
                    'created_at' => $user->created_at->toISOString(),
                ],
                'errors' => null,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve profile',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }

    /**
     * Update user profile
     * PUT /api/profile
     */
    public function update(Request $request)
    {
        try {
            $validated = $request->validate([
                'name' => 'sometimes|string|max:255',
                'phone' => 'nullable|string|max:20',
                'bio' => 'nullable|string|max:500',
            ]);

            $user = auth()->user();
            $user->update($validated);

            return response()->json([
                'success' => true,
                'message' => 'Profile updated successfully',
                'data' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'phone' => $user->phone,
                    'bio' => $user->bio,
                ],
                'errors' => null,
            ], 200);

        } catch (ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'data' => null,
                'errors' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to update profile',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }

    /**
     * Update user avatar
     * POST /api/profile/avatar
     */
    public function updateAvatar(Request $request)
    {
        try {
            $validated = $request->validate([
                'avatar' => 'required|image|mimes:jpeg,png,jpg|max:2048', // 2MB max
            ]);

            $user = auth()->user();

            // Delete old avatar if exists
            if ($user->avatar) {
                $oldPath = str_replace('/storage/', '', $user->avatar);
                Storage::disk('public')->delete($oldPath);
            }

            // Store new avatar
            $path = $request->file('avatar')->store('avatars', 'public');
            $url = Storage::url($path);

            $user->update(['avatar' => $url]);

            return response()->json([
                'success' => true,
                'message' => 'Avatar updated successfully',
                'data' => [
                    'avatar' => $url,
                ],
                'errors' => null,
            ], 200);

        } catch (ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'data' => null,
                'errors' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to update avatar',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }

    /**
     * Get user statistics
     * GET /api/profile/stats
     */
    public function stats()
    {
        try {
            $user = auth()->user();

            // Calculate points earned this month
            $pointsThisMonth = $user->visits()
                ->whereMonth('created_at', Carbon::now()->month)
                ->sum('points_earned');

            // Calculate visits by type
            $totalDestinationVisits = $user->visits()
                ->where('visitable_type', 'App\Models\Destination')
                ->count();
            
            $totalCulinaryVisits = $user->visits()
                ->where('visitable_type', 'App\Models\Culinary')
                ->count();
                
            $totalEventVisits = $user->visits()
                ->where('visitable_type', 'App\Models\Event')
                ->count();

            // Calculate next level points
            $nextLevelPoints = match($user->level) {
                1 => 500,
                2 => 1000,
                3 => 1500,
                4 => 2000,
                default => 2000,
            };

            $progressToNextLevel = $user->level < 5 
                ? round(($user->points / $nextLevelPoints) * 100, 2)
                : 100;

            return response()->json([
                'success' => true,
                'message' => 'Stats retrieved successfully',
                'data' => [
                    'points' => $user->points,
                    'points_this_month' => $pointsThisMonth,
                    'level' => $user->level,
                    'level_title' => $user->level_title,
                    'total_destinations' => $totalDestinationVisits,
                    'total_culinaries' => $totalCulinaryVisits,
                    'total_events' => $totalEventVisits,
                    'total_visits' => $user->visits()->count(),
                    'total_reviews' => $user->reviews()->count(),
                    'total_badges' => $user->badges()->count(),
                    'total_rewards_claimed' => $user->rewards()->count(),
                    'next_level_points' => $nextLevelPoints,
                    'progress_to_next_level' => $progressToNextLevel,
                ],
                'errors' => null,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve stats',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }
}
