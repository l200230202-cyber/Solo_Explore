<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Culinary;
use Illuminate\Http\Request;

class CulinaryController extends Controller
{
    /**
     * Get all culinaries with filters
     * GET /api/culinaries
     */
    public function index(Request $request)
    {
        try {
            $query = Culinary::with('category');

            // Apply filters
            if ($request->has('category')) {
                $query->whereHas('category', function ($q) use ($request) {
                    $q->where('slug', $request->category);
                });
            }

            if ($request->boolean('halal')) {
                $query->halal();
            }

            if ($request->boolean('featured')) {
                $query->featured();
            }

            if ($request->has('search')) {
                $query->search($request->search);
            }

            $perPage = $request->get('per_page', 15);
            $culinaries = $query->orderBy('created_at', 'desc')->paginate($perPage);

            return response()->json([
                'success' => true,
                'message' => 'Culinaries retrieved successfully',
                'data' => [
                    'current_page' => $culinaries->currentPage(),
                    'data' => collect($culinaries->items())->map(function ($culinary) {
                        return $this->formatCulinary($culinary);
                    }),
                    'per_page' => $culinaries->perPage(),
                    'total' => $culinaries->total(),
                    'last_page' => $culinaries->lastPage(),
                ],
                'errors' => null,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve culinaries',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }

    /**
     * Get culinary by slug
     * GET /api/culinaries/{slug}
     */
    public function show($slug)
    {
        try {
            $culinary = Culinary::with(['category', 'reviews.user'])
                ->where('slug', $slug)
                ->firstOrFail();

            // Increment views
            $culinary->incrementViews();

            $userId = auth()->id();

            return response()->json([
                'success' => true,
                'message' => 'Culinary retrieved successfully',
                'data' => [
                    'id' => $culinary->id,
                    'category_id' => $culinary->category_id,
                    'category_name' => $culinary->category?->name,
                    'name' => $culinary->name,
                    'slug' => $culinary->slug,
                    'description' => $culinary->description,
                    'location' => $culinary->location,
                    'address' => $culinary->address,
                    'latitude' => $culinary->latitude,
                    'longitude' => $culinary->longitude,
                    'image' => $culinary->image_url,  // Use accessor for full URL
                    'images' => $culinary->images ?? [],
                    'rating' => $culinary->rating,
                    'total_reviews' => $culinary->total_reviews,
                    'price_range' => $culinary->price_range,
                    'since' => $culinary->since,
                    'facilities' => $culinary->facilities,
                    'highlights' => $culinary->highlights,
                    'opening_hours' => $culinary->opening_hours,
                    'is_halal' => $culinary->is_halal,
                    'is_featured' => $culinary->is_featured,
                    'views' => $culinary->views,
                    'is_bookmarked' => $userId ? $culinary->isBookmarkedBy($userId) : false,
                    'reviews' => $culinary->reviews->take(10)->map(function ($review) {
                        return [
                            'id' => $review->id,
                            'user_name' => $review->user->name,
                            'user_avatar' => $review->user->avatar,
                            'rating' => $review->rating,
                            'comment' => $review->comment,
                            'images' => $review->images ?? [],
                            'created_at' => $review->created_at->toISOString(),
                        ];
                    }),
                ],
                'errors' => null,
            ], 200);

        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Culinary not found',
                'data' => null,
                'errors' => ['culinary' => ['The requested culinary was not found']],
            ], 404);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve culinary',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }
    /**
     * Get personalized culinary recommendations based on logged-in user's interests
     * GET /api/culinaries/recommendations
     */
    public function recommendations(Request $request)
    {
        try {
            $user = $request->user(); 

            $query = Culinary::with('category');

            if ($user && $user->interests()->exists()) {
                $userInterestIds = $user->interests()->pluck('category_id');
                $query->whereIn('category_id', $userInterestIds);
            } else {
                $query->featured();
            }

            $perPage = $request->get('per_page', 5);
            $culinaries = $query->orderBy('rating', 'desc')->paginate($perPage);

            // 🛠️ FIX FALLBACK: Jika hasil filter minat ternyata kosong (0),
            // kita ambil data kuliner terbaru/terpopuler secara umum agar data tidak kosong.
            if ($culinaries->isEmpty()) {
                $culinaries = Culinary::with('category')
                    ->orderBy('rating', 'desc')
                    ->paginate($perPage);
            }

            return response()->json([
                'success' => true,
                'message' => 'Personalized culinary recommendations retrieved successfully',
                'data' => [
                    'current_page' => $culinaries->currentPage(),
                    'data' => collect($culinaries->items())->map(function ($culinary) {
                        return $this->formatCulinary($culinary);
                    }),
                    'per_page' => $culinaries->perPage(),
                    'total' => $culinaries->total(),
                    'last_page' => $culinaries->lastPage(),
                ],
                'errors' => null,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve culinary recommendations',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }
    /**
     * Format culinary for list view
     */
    private function formatCulinary($culinary)
    {
        $userId = auth()->id();
        
        return [
            'id' => $culinary->id,
            'category_id' => $culinary->category_id,
            'category_name' => $culinary->category?->name,
            'name' => $culinary->name,
            'slug' => $culinary->slug,
            'description' => $culinary->description,
            'location' => $culinary->location,
            'address' => $culinary->address,
            'latitude' => $culinary->latitude,
            'longitude' => $culinary->longitude,
            'image' => $culinary->image_url,  // Use accessor for full URL
            'images' => $culinary->images ?? [],
            'rating' => $culinary->rating,
            'total_reviews' => $culinary->total_reviews,
            'price_range' => $culinary->price_range,
            'since' => $culinary->since,
            'facilities' => $culinary->facilities,
            'highlights' => $culinary->highlights,
            'opening_hours' => $culinary->opening_hours,
            'is_halal' => $culinary->is_halal,
            'is_featured' => $culinary->is_featured,
            'views' => $culinary->views,
            'is_bookmarked' => $userId ? $culinary->isBookmarkedBy($userId) : false,
        ];
    }
}
