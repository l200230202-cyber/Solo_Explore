<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Badge;

class BadgeController extends Controller
{
    /**
     * Get all badges
     * GET /api/badges
     */
    public function index()
    {
        try {
            $badges = Badge::all();

            return response()->json([
                'success' => true,
                'message' => 'Badges retrieved successfully',
                'data' => $badges->map(function ($badge) {
                    return [
                        'id' => $badge->id,
                        'name' => $badge->name,
                        'slug' => $badge->slug,
                        'description' => $badge->description,
                        'icon' => $badge->icon,
                        'requirement' => $badge->requirement,
                        'required_points' => $badge->required_points,
                    ];
                }),
                'errors' => null,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve badges',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }

    /**
     * Get user's earned badges
     * GET /api/badges/my
     */
    public function myBadges()
    {
        try {
            $badges = auth()->user()->badges;

            return response()->json([
                'success' => true,
                'message' => 'User badges retrieved successfully',
                'data' => $badges->map(function ($badge) {
                    return [
                        'id' => $badge->id,
                        'name' => $badge->name,
                        'slug' => $badge->slug,
                        'description' => $badge->description,
                        'icon' => $badge->icon,
                        'earned_at' => $badge->pivot->earned_at,
                    ];
                }),
                'errors' => null,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve user badges',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }
}
