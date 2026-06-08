<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Bookmark;
use App\Models\Destination;
use App\Models\Culinary;
use App\Models\Event;

class BookmarkController extends Controller
{
    /**
     * Get all user bookmarks
     * GET /api/bookmarks
     */
    public function index()
    {
        try {
            $bookmarks = auth()->user()->bookmarks()->with('bookmarkable')->recent()->get();

            $destinations = [];
            $culinaries = [];
            $events = [];

            foreach ($bookmarks as $bookmark) {
                $item = $bookmark->bookmarkable;
                if (!$item) continue;

                $data = [
                    'id' => $item->id,
                    'name' => $item->name,
                    'slug' => $item->slug,
                    'image' => $item->image_url,  // Use accessor for full URL
                    'location' => $item->location,
                    'bookmarked_at' => $bookmark->created_at->toISOString(),
                ];

                if ($bookmark->bookmarkable_type === Destination::class) {
                    $data['rating'] = $item->rating;
                    $data['category_id'] = $item->category_id;
                    $data['category_name'] = $item->category?->name;
                    $destinations[] = $data;
                } elseif ($bookmark->bookmarkable_type === Culinary::class) {
                    $data['rating'] = $item->rating;
                    $data['category_id'] = $item->category_id;
                    $data['category_name'] = $item->category?->name;
                    $culinaries[] = $data;
                } elseif ($bookmark->bookmarkable_type === Event::class) {
                    $data['start_date'] = $item->start_date->format('Y-m-d');
                    $data['category_id'] = $item->category_id;
                    $data['category_name'] = $item->category?->name;
                    $events[] = $data;
                }
            }

            return response()->json([
                'success' => true,
                'message' => 'Bookmarks retrieved successfully',
                'data' => [
                    'destinations' => $destinations,
                    'culinaries' => $culinaries,
                    'events' => $events,
                ],
                'errors' => null,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve bookmarks',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }

    /**
     * Toggle destination bookmark
     * POST /api/bookmarks/destinations/{id}
     */
    public function toggleDestination($id)
    {
        try {
            $destination = Destination::findOrFail($id);

            $bookmark = Bookmark::where('user_id', auth()->id())
                ->where('bookmarkable_type', Destination::class)
                ->where('bookmarkable_id', $id)
                ->first();

            if ($bookmark) {
                $bookmark->delete();
                $isBookmarked = false;
                $message = 'Bookmark removed';
            } else {
                Bookmark::create([
                    'user_id' => auth()->id(),
                    'bookmarkable_type' => Destination::class,
                    'bookmarkable_id' => $id,
                ]);
                $isBookmarked = true;
                $message = 'Bookmark added';
            }

            return response()->json([
                'success' => true,
                'message' => $message,
                'data' => [
                    'is_bookmarked' => $isBookmarked,
                ],
                'errors' => null,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to toggle bookmark',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }

    /**
     * Toggle culinary bookmark
     * POST /api/bookmarks/culinaries/{id}
     */
    public function toggleCulinary($id)
    {
        try {
            $culinary = Culinary::findOrFail($id);

            $bookmark = Bookmark::where('user_id', auth()->id())
                ->where('bookmarkable_type', Culinary::class)
                ->where('bookmarkable_id', $id)
                ->first();

            if ($bookmark) {
                $bookmark->delete();
                $isBookmarked = false;
                $message = 'Bookmark removed';
            } else {
                Bookmark::create([
                    'user_id' => auth()->id(),
                    'bookmarkable_type' => Culinary::class,
                    'bookmarkable_id' => $id,
                ]);
                $isBookmarked = true;
                $message = 'Bookmark added';
            }

            return response()->json([
                'success' => true,
                'message' => $message,
                'data' => [
                    'is_bookmarked' => $isBookmarked,
                ],
                'errors' => null,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to toggle bookmark',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }

    /**
     * Toggle event bookmark
     * POST /api/bookmarks/events/{id}
     */
    public function toggleEvent($id)
    {
        try {
            $event = Event::findOrFail($id);

            $bookmark = Bookmark::where('user_id', auth()->id())
                ->where('bookmarkable_type', Event::class)
                ->where('bookmarkable_id', $id)
                ->first();

            if ($bookmark) {
                $bookmark->delete();
                $isBookmarked = false;
                $message = 'Bookmark removed';
            } else {
                Bookmark::create([
                    'user_id' => auth()->id(),
                    'bookmarkable_type' => Event::class,
                    'bookmarkable_id' => $id,
                ]);
                $isBookmarked = true;
                $message = 'Bookmark added';
            }

            return response()->json([
                'success' => true,
                'message' => $message,
                'data' => [
                    'is_bookmarked' => $isBookmarked,
                ],
                'errors' => null,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to toggle bookmark',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }
}
