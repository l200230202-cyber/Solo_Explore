<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Reward;
use Illuminate\Support\Str;

class RewardController extends Controller
{
    /**
     * Get all rewards
     * GET /api/rewards
     */
    public function index()
    {
        try {
            $rewards = Reward::active()->get();

            return response()->json([
                'success' => true,
                'message' => 'Rewards retrieved successfully',
                'data' => $rewards->map(function ($reward) {
                    return $this->formatReward($reward);
                }),
                'errors' => null,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve rewards',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }

    /**
     * Get rewards user can claim
     * GET /api/rewards/available
     */
    public function available()
    {
        try {
            $user = auth()->user();
            $rewards = Reward::active()
                ->availableFor($user->points)
                ->get();

            return response()->json([
                'success' => true,
                'message' => 'Available rewards retrieved successfully',
                'data' => $rewards->map(function ($reward) use ($user) {
                    $data = $this->formatReward($reward);
                    $data['can_claim'] = $user->points >= $reward->required_points;
                    return $data;
                }),
                'errors' => null,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve available rewards',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }

    /**
     * Get user's claimed rewards
     * GET /api/rewards/my
     */
    public function myRewards()
    {
        try {
            $rewards = auth()->user()->rewards;

            return response()->json([
                'success' => true,
                'message' => 'User rewards retrieved successfully',
                'data' => $rewards->map(function ($reward) {
                    return [
                        'id' => $reward->pivot->id,
                        'reward_id' => $reward->id,
                        'name' => $reward->name,
                        'type' => $reward->type,
                        'value' => $reward->value,
                        'code' => $reward->pivot->code,
                        'status' => $reward->pivot->status,
                        'claimed_at' => $reward->pivot->claimed_at,
                        'used_at' => $reward->pivot->used_at,
                        'valid_until' => $reward->valid_until ? $reward->valid_until->format('Y-m-d') : null,
                    ];
                }),
                'errors' => null,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve user rewards',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }

    /**
     * Claim a reward
     * POST /api/rewards/{id}/claim
     */
    public function claim($id)
    {
        try {
            $reward = Reward::active()->findOrFail($id);
            $user = auth()->user();

            // Check if user has enough points
            if ($user->points < $reward->required_points) {
                return response()->json([
                    'success' => false,
                    'message' => 'Insufficient points',
                    'data' => null,
                    'errors' => ['points' => ['You need ' . $reward->required_points . ' points to claim this reward']],
                ], 422);
            }

            // Check if already claimed
            $alreadyClaimed = $user->rewards()->where('reward_id', $id)->exists();
            if ($alreadyClaimed) {
                return response()->json([
                    'success' => false,
                    'message' => 'Reward already claimed',
                    'data' => null,
                    'errors' => ['reward' => ['You have already claimed this reward']],
                ], 422);
            }

            // Generate unique code
            $code = 'SOLO-' . strtoupper(Str::random(6));

            // Claim reward
            $user->rewards()->attach($id, [
                'claimed_at' => now(),
                'status' => 'claimed',
                'code' => $code,
            ]);

            // Deduct points
            $user->decrement('points', $reward->required_points);

            return response()->json([
                'success' => true,
                'message' => 'Reward claimed successfully',
                'data' => [
                    'reward_id' => $reward->id,
                    'code' => $code,
                    'points_used' => $reward->required_points,
                    'remaining_points' => $user->fresh()->points,
                ],
                'errors' => null,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to claim reward',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }

    /**
     * Use a reward
     * POST /api/rewards/{id}/use
     */
    public function use($id)
    {
        try {
            $user = auth()->user();
            $userReward = $user->rewards()->wherePivot('id', $id)->first();

            if (!$userReward) {
                return response()->json([
                    'success' => false,
                    'message' => 'Reward not found',
                    'data' => null,
                    'errors' => ['reward' => ['Reward not found in your collection']],
                ], 404);
            }

            if ($userReward->pivot->status === 'used') {
                return response()->json([
                    'success' => false,
                    'message' => 'Reward already used',
                    'data' => null,
                    'errors' => ['reward' => ['This reward has already been used']],
                ], 422);
            }

            // Mark as used
            $user->rewards()->updateExistingPivot($userReward->id, [
                'used_at' => now(),
                'status' => 'used',
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Reward marked as used',
                'data' => null,
                'errors' => null,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to use reward',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }

    /**
     * Format reward data
     */
    private function formatReward($reward)
    {
        return [
            'id' => $reward->id,
            'name' => $reward->name,
            'slug' => $reward->slug,
            'description' => $reward->description,
            'image' => $reward->image,
            'required_points' => $reward->required_points,
            'type' => $reward->type,
            'value' => $reward->value,
            'valid_until' => $reward->valid_until ? $reward->valid_until->format('Y-m-d') : null,
            'is_active' => $reward->is_active,
        ];
    }
}
