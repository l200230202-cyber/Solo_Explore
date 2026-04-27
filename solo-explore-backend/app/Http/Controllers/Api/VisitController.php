<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Visit;
use App\Models\Destination;
use App\Models\Culinary;
use App\Models\Event;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class VisitController extends Controller
{
    /**
     * Get user visit history
     * GET /api/visits
     */
    public function index()
    {
        try {
            $visits = auth()->user()->visits()->with('visitable')->orderBy('visit_date', 'desc')->get();

            return response()->json([
                'success' => true,
                'message' => 'Visits retrieved successfully',
                'data' => $visits->map(function ($visit) {
                    $item = $visit->visitable;
                    if (!$item) return null;

                    $type = $visit->visitable_type === Destination::class ? 'destination' : 'culinary';

                    return [
                        'id' => $visit->id,
                        'visited_at' => $visit->visit_date->format('Y-m-d'),
                        'points_earned' => $visit->points_earned,
                        'notes' => null,
                        $type => [
                            'id' => $item->id,
                            'name' => $item->name,
                            'slug' => $item->slug,
                            'image' => $item->image_url,  // Use accessor for full URL
                            'location' => $item->location,
                            'rating' => $item->rating ?? 0,
                        ],
                    ];
                })->filter(),
                'errors' => null,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve visits',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }

    /**
     * Record destination visit
     * POST /api/visits/destinations/{id}
     */
    public function recordDestination(Request $request, $id)
    {
        try {
            $validated = $request->validate([
                'visit_date' => 'required|date',
            ]);

            $destination = Destination::findOrFail($id);

            // Check if already visited on this date
            $existingVisit = Visit::where('user_id', auth()->id())
                ->where('visitable_type', Destination::class)
                ->where('visitable_id', $id)
                ->where('visit_date', $validated['visit_date'])
                ->first();

            if ($existingVisit) {
                return response()->json([
                    'success' => false,
                    'message' => 'Visit already recorded for this date',
                    'data' => null,
                    'errors' => ['visit' => ['You have already recorded a visit for this date']],
                ], 422);
            }

            $pointsEarned = 50;

            $visit = Visit::create([
                'user_id' => auth()->id(),
                'visitable_type' => Destination::class,
                'visitable_id' => $id,
                'visit_date' => $validated['visit_date'],
                'points_earned' => $pointsEarned,
            ]);

            // Award points
            $user = auth()->user();
            $user->addPoints($pointsEarned);
            $user->increment('total_destinations');

            // Check and award badges based on visit count
            $this->checkAndAwardBadges($user);

            return response()->json([
                'success' => true,
                'message' => 'Visit recorded successfully',
                'data' => [
                    'visit_id' => $visit->id,
                    'points_earned' => $pointsEarned,
                    'total_points' => $user->fresh()->points,
                ],
                'errors' => null,
            ], 201);

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
                'message' => 'Failed to record visit',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }

    /**
     * Record culinary visit
     * POST /api/visits/culinaries/{id}
     */
    public function recordCulinary(Request $request, $id)
    {
        try {
            $validated = $request->validate([
                'visit_date' => 'required|date',
            ]);

            $culinary = Culinary::findOrFail($id);

            // Check if already visited on this date
            $existingVisit = Visit::where('user_id', auth()->id())
                ->where('visitable_type', Culinary::class)
                ->where('visitable_id', $id)
                ->where('visit_date', $validated['visit_date'])
                ->first();

            if ($existingVisit) {
                return response()->json([
                    'success' => false,
                    'message' => 'Visit already recorded for this date',
                    'data' => null,
                    'errors' => ['visit' => ['You have already recorded a visit for this date']],
                ], 422);
            }

            $pointsEarned = 30;

            $visit = Visit::create([
                'user_id' => auth()->id(),
                'visitable_type' => Culinary::class,
                'visitable_id' => $id,
                'visit_date' => $validated['visit_date'],
                'points_earned' => $pointsEarned,
            ]);

            // Award points
            $user = auth()->user();
            $user->addPoints($pointsEarned);

            // Check and award badges based on visit count
            $this->checkAndAwardBadges($user);

            return response()->json([
                'success' => true,
                'message' => 'Visit recorded successfully',
                'data' => [
                    'visit_id' => $visit->id,
                    'points_earned' => $pointsEarned,
                    'total_points' => $user->fresh()->points,
                ],
                'errors' => null,
            ], 201);

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
                'message' => 'Failed to record visit',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }

    /**
     * Record event visit
     * POST /api/visits/events/{id}
     */
    public function recordEvent(Request $request, $id)
    {
        try {
            $validated = $request->validate([
                'visit_date' => 'required|date',
            ]);

            $event = Event::findOrFail($id);

            // Check if already visited on this date
            $existingVisit = Visit::where('user_id', auth()->id())
                ->where('visitable_type', Event::class)
                ->where('visitable_id', $id)
                ->where('visit_date', $validated['visit_date'])
                ->first();

            if ($existingVisit) {
                return response()->json([
                    'success' => false,
                    'message' => 'Visit already recorded for this date',
                    'data' => null,
                    'errors' => ['visit' => ['You have already recorded a visit for this date']],
                ], 422);
            }

            $pointsEarned = 40;

            $visit = Visit::create([
                'user_id' => auth()->id(),
                'visitable_type' => Event::class,
                'visitable_id' => $id,
                'visit_date' => $validated['visit_date'],
                'points_earned' => $pointsEarned,
            ]);

            // Award points
            $user = auth()->user();
            $user->addPoints($pointsEarned);

            // Check and award badges based on visit count
            $this->checkAndAwardBadges($user);

            return response()->json([
                'success' => true,
                'message' => 'Visit recorded successfully',
                'data' => [
                    'visit_id' => $visit->id,
                    'points_earned' => $pointsEarned,
                    'total_points' => $user->fresh()->points,
                ],
                'errors' => null,
            ], 201);

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
                'message' => 'Failed to record visit',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }
    private function checkAndAwardBadges($user)
    {
        try {
            $totalVisits = $user->visits()->count();
            $totalDestinations = $user->visits()->where('visitable_type', Destination::class)->count();
            $totalCulinaries = $user->visits()->where('visitable_type', Culinary::class)->count();
            $totalEvents = $user->visits()->where('visitable_type', Event::class)->count();
            
            \Log::info("Badge check for user {$user->id}: Total visits: {$totalVisits}, Destinations: {$totalDestinations}, Culinaries: {$totalCulinaries}, Events: {$totalEvents}");
            
            // Badge: First Visit (1 visit)
            if ($totalVisits >= 1) {
                $this->awardBadgeIfNotExists($user, 'first-visit');
            }
            
            // Badge: Explorer (5 visits)
            if ($totalVisits >= 5) {
                $this->awardBadgeIfNotExists($user, 'explorer');
            }
            
            // Badge: Adventurer (10 visits)
            if ($totalVisits >= 10) {
                $this->awardBadgeIfNotExists($user, 'adventurer');
            }
            
            // Badge: Master Explorer (20 visits)
            if ($totalVisits >= 20) {
                $this->awardBadgeIfNotExists($user, 'master-explorer');
            }
            
            // Badge: Culture Enthusiast (5 destinations)
            if ($totalDestinations >= 5) {
                $this->awardBadgeIfNotExists($user, 'culture-enthusiast');
            }
            
            // Badge: Food Hunter (5 culinaries)
            if ($totalCulinaries >= 5) {
                $this->awardBadgeIfNotExists($user, 'food-hunter');
            }
            
        } catch (\Exception $e) {
            \Log::error('Failed to check badges: ' . $e->getMessage());
        }
    }

    /**
     * Award badge to user if they don't have it yet
     */
    private function awardBadgeIfNotExists($user, $badgeSlug)
    {
        try {
            $badge = \App\Models\Badge::where('slug', $badgeSlug)->first();
            
            if (!$badge) {
                \Log::warning("Badge not found: {$badgeSlug}");
                return;
            }
            
            // Check if user already has this badge
            $hasBadge = \DB::table('user_badges')
                ->where('user_id', $user->id)
                ->where('badge_id', $badge->id)
                ->exists();
            
            if (!$hasBadge) {
                \DB::table('user_badges')->insert([
                    'user_id' => $user->id,
                    'badge_id' => $badge->id,
                    'earned_at' => now(),
                ]);
                
                \Log::info("Badge awarded: {$badge->name} to user {$user->id}");
                
                // Optional: Send notification to user
                // $user->notify(new BadgeEarnedNotification($badge));
            }
            
        } catch (\Exception $e) {
            \Log::error("Failed to award badge {$badgeSlug}: " . $e->getMessage());
        }
    }
}
