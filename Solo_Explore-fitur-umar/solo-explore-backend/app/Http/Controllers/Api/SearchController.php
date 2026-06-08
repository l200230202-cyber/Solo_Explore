<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Destination;
use App\Models\Culinary;
use App\Models\Event;
use Illuminate\Http\Request;

class SearchController extends Controller
{
    /**
     * Global search across destinations, culinaries, and events
     * GET /api/search?q=query&type=all
     */
    public function search(Request $request)
    {
        try {
            $query = $request->get('q', '');
            $type = $request->get('type', 'all');

            if (empty($query)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Search query is required',
                    'data' => null,
                    'errors' => ['query' => ['Please provide a search query']],
                ], 422);
            }

            $results = [
                'destinations' => [],
                'culinaries' => [],
                'events' => [],
            ];

            // Search destinations
            if ($type === 'all' || $type === 'destination') {
                $destinations = Destination::search($query)
                    ->take(10)
                    ->get();

                $results['destinations'] = $destinations->map(function ($dest) {
                    return [
                        'id' => $dest->id,
                        'name' => $dest->name,
                        'slug' => $dest->slug,
                        'type' => 'destination',
                        'image' => $dest->image_url,  // Use accessor for full URL
                        'location' => $dest->location,
                        'rating' => $dest->rating,
                        'category_id' => $dest->category_id,
                        'category_name' => $dest->category?->name,
                    ];
                });
            }

            // Search culinaries
            if ($type === 'all' || $type === 'culinary') {
                $culinaries = Culinary::search($query)
                    ->take(10)
                    ->get();

                $results['culinaries'] = $culinaries->map(function ($culinary) {
                    return [
                        'id' => $culinary->id,
                        'name' => $culinary->name,
                        'slug' => $culinary->slug,
                        'type' => 'culinary',
                        'image' => $culinary->image_url,  // Use accessor for full URL
                        'location' => $culinary->location,
                        'rating' => $culinary->rating,
                        'category_id' => $culinary->category_id,
                        'category_name' => $culinary->category?->name,
                    ];
                });
            }

            // Search events
            if ($type === 'all' || $type === 'event') {
                $events = Event::search($query)
                    ->take(10)
                    ->get();

                $results['events'] = $events->map(function ($event) {
                    return [
                        'id' => $event->id,
                        'name' => $event->name,
                        'slug' => $event->slug,
                        'type' => 'event',
                        'image' => $event->image_url,  // Use accessor for full URL
                        'location' => $event->location,
                        'start_date' => $event->start_date->format('Y-m-d'),
                        'category_id' => $event->category_id,
                        'category_name' => $event->category?->name,
                    ];
                });
            }

            return response()->json([
                'success' => true,
                'message' => 'Search results retrieved successfully',
                'data' => $results,
                'errors' => null,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Search failed',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }
}
