<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Destination;
use Illuminate\Http\Request;

class DestinationController extends Controller
{
    /**
     * Get all destinations with filters
     * GET /api/destinations
     */
    public function index(Request $request)
    {
        try {
            $query = Destination::with('category');

            // Apply filters
            if ($request->has('category')) {
                $query->byCategory($request->category);
            }

            if ($request->boolean('featured')) {
                $query->featured();
            }

            if ($request->has('search')) {
                $query->search($request->search);
            }

            $perPage = $request->get('per_page', 15);
            $destinations = $query->orderBy('created_at', 'desc')->paginate($perPage);

            return response()->json([
                'success' => true,
                'message' => 'Destinations retrieved successfully',
                'data' => [
                    'current_page' => $destinations->currentPage(),
                    'data' => collect($destinations->items())->map(function ($dest) {
                        return $this->formatDestination($dest);
                    }),
                    'per_page' => $destinations->perPage(),
                    'total' => $destinations->total(),
                    'last_page' => $destinations->lastPage(),
                ],
                'errors' => null,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve destinations',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }

    /**
     * Get destination by slug
     * GET /api/destinations/{slug}
     */
    public function show($slug)
    {
        try {
            $destination = Destination::with(['category', 'reviews.user'])
                ->where('slug', $slug)
                ->firstOrFail();

            // Increment views
            $destination->incrementViews();

            $userId = auth()->id();

            return response()->json([
                'success' => true,
                'message' => 'Destination retrieved successfully',
                'data' => [
                    'id' => $destination->id,
                    'category_id' => $destination->category_id,
                    'category_name' => $destination->category->name,
                    'name' => $destination->name,
                    'slug' => $destination->slug,
                    'description' => $destination->description,
                    'location' => $destination->location,
                    'address' => $destination->address,
                    'latitude' => $destination->latitude,
                    'longitude' => $destination->longitude,
                    'image' => $destination->image_url,  // Use accessor for full URL
                    'images' => $destination->images ?? [],
                    'rating' => $destination->rating,
                    'total_reviews' => $destination->total_reviews,
                    'ticket_price' => $destination->ticket_price,
                    'facilities' => $destination->facilities,
                    'highlights' => $destination->highlights,
                    'opening_hours' => $destination->opening_hours,
                    'is_open' => $destination->is_open,
                    'is_featured' => $destination->is_featured,
                    'views' => $destination->views,
                    'is_bookmarked' => $userId ? $destination->isBookmarkedBy($userId) : false,
                    'reviews' => $destination->reviews->take(10)->map(function ($review) {
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
                'message' => 'Destination not found',
                'data' => null,
                'errors' => ['destination' => ['The requested destination was not found']],
            ], 404);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve destination',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }

    /**
     * Get destinations by category
     * GET /api/destinations/category/{slug}
     */
    public function byCategory($slug, Request $request)
    {
        try {
            $query = Destination::with('category')->byCategory($slug);

            $perPage = $request->get('per_page', 15);
            $destinations = $query->orderBy('created_at', 'desc')->paginate($perPage);

            return response()->json([
                'success' => true,
                'message' => 'Destinations retrieved successfully',
                'data' => [
                    'current_page' => $destinations->currentPage(),
                    'data' => collect($destinations->items())->map(function ($dest) {
                        return $this->formatDestination($dest);
                    }),
                    'per_page' => $destinations->perPage(),
                    'total' => $destinations->total(),
                    'last_page' => $destinations->lastPage(),
                ],
                'errors' => null,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve destinations',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }

    /**
     * Get personalized destination recommendations based on logged-in user's interests
     * GET /api/destinations/recommendations
     */
    public function recommendations(Request $request)
    {
        try {
            $user = $request->user(); // Mendeteksi token user yang aktif (Abdul)

            $query = Destination::with('category');

            // 🔐 JIKA USER LOGIN: Filter destinasi berdasarkan minat kategori mereka
            if ($user && $user->interests()->exists()) {
                $userInterestIds = $user->interests()->pluck('category_id');
                $query->whereIn('category_id', $userInterestIds);
            } else {
                // JIKA GUEST (BELUM LOGIN): Kasih destinasi berlabel featured atau rating tertinggi
                $query->featured();
            }

            $perPage = $request->get('per_page', 5); // Default ambil 5 data wisata untuk Beranda
            $destinations = $query->orderBy('rating', 'desc')->paginate($perPage);

            return response()->json([
                'success' => true,
                'message' => 'Personalized destination recommendations retrieved successfully',
                'data' => [
                    'current_page' => $destinations->currentPage(),
                    'data' => collect($destinations->items())->map(function ($dest) {
                        return $this->formatDestination($dest);
                    }),
                    'per_page' => $destinations->perPage(),
                    'total' => $destinations->total(),
                    'last_page' => $destinations->lastPage(),
                ],
                'errors' => null,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve destination recommendations',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }
    
    /**
     * Format destination for list view
     */
    private function formatDestination($dest)
    {
        $userId = auth()->id();
        
        return [
            'id' => $dest->id,
            'category_id' => $dest->category_id,
            'category_name' => $dest->category->name,
            'name' => $dest->name,
            'slug' => $dest->slug,
            'description' => $dest->description,
            'location' => $dest->location,
            'address' => $dest->address,
            'latitude' => $dest->latitude,
            'longitude' => $dest->longitude,
            'image' => $dest->image_url,  // Use accessor for full URL
            'images' => $dest->images ?? [],
            'rating' => $dest->rating,
            'total_reviews' => $dest->total_reviews,
            'ticket_price' => $dest->ticket_price,
            'opening_hours' => $dest->opening_hours,
            'is_open' => $dest->is_open,
            'is_featured' => $dest->is_featured,
            'views' => $dest->views,
            'is_bookmarked' => $userId ? $dest->isBookmarkedBy($userId) : false,
        ];
    }
}
