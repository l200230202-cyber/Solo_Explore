<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Review;
use App\Models\Destination;
use App\Models\Culinary;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\ValidationException;

class ReviewController extends Controller
{
    /**
     * Get all reviews (admin)
     * GET /api/reviews
     */
    public function index()
    {
        try {
            $reviews = auth()->user()->reviews()->with('reviewable')->recent()->get();

            return response()->json([
                'success' => true,
                'message' => 'Reviews retrieved successfully',
                'data' => $reviews->map(function ($review) {
                    return $this->formatReview($review);
                }),
                'errors' => null,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve reviews',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }

    /**
     * Create review for destination
     * POST /api/destinations/{id}/reviews
     */
    public function storeForDestination(Request $request, $id)
    {
        try {
            $validated = $request->validate([
                'rating' => 'required|integer|min:1|max:5',
                'comment' => 'nullable|string|max:1000',
                'images' => 'nullable|array|max:5',
                'images.*' => 'nullable|string', // Base64 encoded images
            ]);

            $destination = Destination::findOrFail($id);

            // Check if user already reviewed
            $existingReview = Review::where('user_id', auth()->id())
                ->where('reviewable_type', Destination::class)
                ->where('reviewable_id', $id)
                ->first();

            if ($existingReview) {
                return response()->json([
                    'success' => false,
                    'message' => 'You have already reviewed this destination',
                    'data' => null,
                    'errors' => ['review' => ['You can only review once']],
                ], 422);
            }

            // Handle image uploads
            $imageUrls = [];
            if (isset($validated['images'])) {
                foreach ($validated['images'] as $base64Image) {
                    $imageUrls[] = $this->uploadBase64Image($base64Image, 'reviews');
                }
            }

            $review = Review::create([
                'user_id' => auth()->id(),
                'reviewable_type' => Destination::class,
                'reviewable_id' => $id,
                'rating' => $validated['rating'],
                'comment' => $validated['comment'] ?? null,
                'images' => $imageUrls,
            ]);

            // Update destination rating
            $destination->updateRating();

            // Award points
            auth()->user()->addPoints(20);

            return response()->json([
                'success' => true,
                'message' => 'Review submitted successfully',
                'data' => $this->formatReview($review->load('user')),
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
                'message' => 'Failed to submit review',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }

    /**
     * Create review for culinary
     * POST /api/culinaries/{id}/reviews
     */
    public function storeForCulinary(Request $request, $id)
    {
        try {
            $validated = $request->validate([
                'rating' => 'required|integer|min:1|max:5',
                'comment' => 'nullable|string|max:1000',
                'images' => 'nullable|array|max:5',
                'images.*' => 'nullable|string',
            ]);

            $culinary = Culinary::findOrFail($id);

            // Check if user already reviewed
            $existingReview = Review::where('user_id', auth()->id())
                ->where('reviewable_type', Culinary::class)
                ->where('reviewable_id', $id)
                ->first();

            if ($existingReview) {
                return response()->json([
                    'success' => false,
                    'message' => 'You have already reviewed this culinary',
                    'data' => null,
                    'errors' => ['review' => ['You can only review once']],
                ], 422);
            }

            // Handle image uploads
            $imageUrls = [];
            if (isset($validated['images'])) {
                foreach ($validated['images'] as $base64Image) {
                    $imageUrls[] = $this->uploadBase64Image($base64Image, 'reviews');
                }
            }

            $review = Review::create([
                'user_id' => auth()->id(),
                'reviewable_type' => Culinary::class,
                'reviewable_id' => $id,
                'rating' => $validated['rating'],
                'comment' => $validated['comment'] ?? null,
                'images' => $imageUrls,
            ]);

            // Update culinary rating
            $culinary->updateRating();

            // Award points
            auth()->user()->addPoints(20);

            return response()->json([
                'success' => true,
                'message' => 'Review submitted successfully',
                'data' => $this->formatReview($review->load('user')),
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
                'message' => 'Failed to submit review',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }

    /**
     * Delete review
     * DELETE /api/reviews/{id}
     */
    public function destroy($id)
    {
        try {
            $review = Review::where('id', $id)
                ->where('user_id', auth()->id())
                ->firstOrFail();

            $review->delete();

            // Update rating
            $reviewable = $review->reviewable;
            if ($reviewable) {
                $reviewable->updateRating();
            }

            return response()->json([
                'success' => true,
                'message' => 'Review deleted successfully',
                'data' => null,
                'errors' => null,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to delete review',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }

    /**
     * Format review data
     */
    private function formatReview($review)
    {
        return [
            'id' => $review->id,
            'user_id' => $review->user_id,
            'user_name' => $review->user->name,
            'user_avatar' => $review->user->avatar,
            'rating' => $review->rating,
            'comment' => $review->comment,
            'images' => $review->images ?? [],
            'created_at' => $review->created_at->toISOString(),
        ];
    }

    /**
     * Upload base64 image
     */
    private function uploadBase64Image($base64String, $folder)
    {
        // Remove data:image/...;base64, prefix if present
        if (preg_match('/^data:image\/(\w+);base64,/', $base64String, $type)) {
            $base64String = substr($base64String, strpos($base64String, ',') + 1);
            $type = strtolower($type[1]); // jpg, png, gif
        } else {
            $type = 'png';
        }

        $image = base64_decode($base64String);
        $filename = $folder . '/' . uniqid() . '.' . $type;
        
        Storage::disk('public')->put($filename, $image);
        
        return Storage::url($filename);
    }
}
