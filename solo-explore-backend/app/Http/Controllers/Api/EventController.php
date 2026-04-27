<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Event;
use Illuminate\Http\Request;

class EventController extends Controller
{
    /**
     * Get all events with filters
     * GET /api/events
     */
    public function index(Request $request)
    {
        try {
            $query = Event::with('category');

            // Apply filters
            if ($request->boolean('upcoming')) {
                $query->upcoming();
            }

            if ($request->has('month') && $request->has('year')) {
                $query->byMonth($request->year, $request->month);
            }

            if ($request->has('category')) {
                $query->whereHas('category', function ($q) use ($request) {
                    $q->where('slug', $request->category);
                });
            }

            if ($request->boolean('featured')) {
                $query->featured();
            }

            $perPage = $request->get('per_page', 15);
            $events = $query->orderBy('start_date', 'asc')->paginate($perPage);

            return response()->json([
                'success' => true,
                'message' => 'Events retrieved successfully',
                'data' => [
                    'current_page' => $events->currentPage(),
                    'data' => collect($events->items())->map(function ($event) {
                        return $this->formatEvent($event);
                    }),
                    'per_page' => $events->perPage(),
                    'total' => $events->total(),
                    'last_page' => $events->lastPage(),
                ],
                'errors' => null,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve events',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }

    /**
     * Get event by slug
     * GET /api/events/{slug}
     */
    public function show($slug)
    {
        try {
            $event = Event::with('category')->where('slug', $slug)->firstOrFail();

            // Increment views
            $event->incrementViews();

            $userId = auth()->id();

            return response()->json([
                'success' => true,
                'message' => 'Event retrieved successfully',
                'data' => [
                    'id' => $event->id,
                    'category_id' => $event->category_id,
                    'category_name' => $event->category?->name,
                    'name' => $event->name,
                    'slug' => $event->slug,
                    'description' => $event->description,
                    'location' => $event->location,
                    'address' => $event->address,
                    'latitude' => $event->latitude,
                    'longitude' => $event->longitude,
                    'image' => $event->image_url,  // Use accessor for full URL
                    'images' => $event->images ?? [],
                    'rating' => $event->rating,
                    'total_reviews' => $event->total_reviews,
                    'start_date' => $event->start_date->format('Y-m-d'),
                    'end_date' => $event->end_date ? $event->end_date->format('Y-m-d') : null,
                    'start_time' => $event->start_time,
                    'end_time' => $event->end_time,
                    'organizer' => $event->organizer,
                    'contact' => $event->contact,
                    'ticket_price' => $event->ticket_price,
                    'is_free' => $event->is_free,
                    'is_featured' => $event->is_featured,
                    'views' => $event->views,
                    'is_bookmarked' => $userId ? $event->isBookmarkedBy($userId) : false,
                    'is_upcoming' => $event->isUpcoming(),
                    'is_ongoing' => $event->isOngoing(),
                ],
                'errors' => null,
            ], 200);

        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Event not found',
                'data' => null,
                'errors' => ['event' => ['The requested event was not found']],
            ], 404);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve event',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }

    /**
     * Get events by month
     * GET /api/events/month/{year}/{month}
     */
    public function byMonth($year, $month)
    {
        try {
            $events = Event::byMonth($year, $month)
                ->orderBy('start_date', 'asc')
                ->get();

            return response()->json([
                'success' => true,
                'message' => 'Events retrieved successfully',
                'data' => $events->map(function ($event) {
                    return $this->formatEvent($event);
                }),
                'errors' => null,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve events',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }

    /**
     * Format event for list view
     */
    private function formatEvent($event)
    {
        $userId = auth()->id();
        
        return [
            'id' => $event->id,
            'category_id' => $event->category_id,
            'category_name' => $event->category?->name,
            'name' => $event->name,
            'slug' => $event->slug,
            'description' => $event->description,
            'location' => $event->location,
            'address' => $event->address,
            'latitude' => $event->latitude,
            'longitude' => $event->longitude,
            'image' => $event->image_url,  // Use accessor for full URL
            'images' => $event->images ?? [],
            'rating' => $event->rating,
            'total_reviews' => $event->total_reviews,
            'start_date' => $event->start_date->format('Y-m-d'),
            'end_date' => $event->end_date ? $event->end_date->format('Y-m-d') : null,
            'start_time' => $event->start_time,
            'end_time' => $event->end_time,
            'organizer' => $event->organizer,
            'contact' => $event->contact,
            'ticket_price' => $event->ticket_price,
            'is_free' => $event->is_free,
            'is_featured' => $event->is_featured,
            'views' => $event->views,
            'is_bookmarked' => $userId ? $event->isBookmarkedBy($userId) : false,
        ];
    }
}
