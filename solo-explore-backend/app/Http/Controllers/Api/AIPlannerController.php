<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Destination;
use App\Models\Culinary;
use App\Models\Event;
use App\Models\TripPlan;
use App\Models\TripPlanItem;
use App\Services\DeepSeekService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class AIPlannerController extends Controller
{
    private DeepSeekService $deepSeekService;

    public function __construct(DeepSeekService $deepSeekService)
    {
        $this->deepSeekService = $deepSeekService;
    }

    /**
     * Get available destinations, culinaries, and events for selection
     */
    public function getAvailableItems(Request $request)
    {
        try {
            $destinations = Destination::with('category')
                ->select('id', 'name', 'description', 'location', 'image', 'price', 'rating', 'opening_hours', 'category_id')
                ->get();

            $culinaries = Culinary::with('category')
                ->select('id', 'name', 'description', 'location', 'image', 'price_range', 'rating', 'opening_hours', 'category_id')
                ->get();

            $events = Event::with('category')
                ->where('end_date', '>=', now())
                ->select('id', 'name', 'description', 'location', 'image', 'start_date', 'end_date', 'price', 'category_id')
                ->get();

            return response()->json([
                'success' => true,
                'data' => [
                    'destinations' => $destinations,
                    'culinaries' => $culinaries,
                    'events' => $events,
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to load items: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Generate AI itinerary based on selected items
     */
    public function generateItinerary(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
            'budget' => 'nullable|numeric|min:0',
            'interests' => 'nullable|string',
            'destination_ids' => 'nullable|array',
            'destination_ids.*' => 'exists:destinations,id',
            'culinary_ids' => 'nullable|array',
            'culinary_ids.*' => 'exists:culinaries,id',
            'event_ids' => 'nullable|array',
            'event_ids.*' => 'exists:events,id',
        ]);

        try {
            // Get selected items
            $destinations = [];
            $culinaries = [];
            $events = [];

            if ($request->has('destination_ids')) {
                $destinations = Destination::whereIn('id', $request->destination_ids)->get()->toArray();
            }

            if ($request->has('culinary_ids')) {
                $culinaries = Culinary::whereIn('id', $request->culinary_ids)->get()->toArray();
            }

            if ($request->has('event_ids')) {
                $events = Event::whereIn('id', $request->event_ids)->get()->toArray();
            }

            // Calculate days
            $startDate = new \DateTime($request->start_date);
            $endDate = new \DateTime($request->end_date);
            $days = $startDate->diff($endDate)->days + 1;

            // Prepare preferences
            $preferences = [
                'budget' => $request->budget ?? 500000,
                'days' => $days,
                'interests' => $request->interests ?? 'general',
            ];

            // Generate itinerary using DeepSeek AI
            $aiResult = $this->deepSeekService->generateItinerary(
                $destinations,
                $culinaries,
                $events,
                $preferences
            );

            if (!$aiResult['success']) {
                return response()->json([
                    'success' => false,
                    'message' => $aiResult['message']
                ], 500);
            }

            // Create trip plan
            DB::beginTransaction();

            $tripPlan = TripPlan::create([
                'user_id' => Auth::id(),
                'name' => $request->name,
                'description' => 'AI Generated Itinerary',
                'start_date' => $request->start_date,
                'end_date' => $request->end_date,
                'budget' => $request->budget,
                'ai_generated' => true,
                'ai_itinerary' => $aiResult['itinerary'],
            ]);

            // Add selected items to trip plan
            $order = 1;

            foreach ($request->destination_ids ?? [] as $destId) {
                TripPlanItem::create([
                    'trip_plan_id' => $tripPlan->id,
                    'destination_id' => $destId,
                    'order' => $order++,
                ]);
            }

            foreach ($request->culinary_ids ?? [] as $culId) {
                TripPlanItem::create([
                    'trip_plan_id' => $tripPlan->id,
                    'culinary_id' => $culId,
                    'order' => $order++,
                ]);
            }

            foreach ($request->event_ids ?? [] as $eventId) {
                TripPlanItem::create([
                    'trip_plan_id' => $tripPlan->id,
                    'event_id' => $eventId,
                    'order' => $order++,
                ]);
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'AI itinerary generated successfully',
                'data' => [
                    'trip_plan' => $tripPlan->load('items.destination', 'items.culinary', 'items.event'),
                    'itinerary' => $aiResult['itinerary'],
                ]
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Failed to generate itinerary: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get AI recommendations based on interests
     */
    public function getRecommendations(Request $request)
    {
        $request->validate([
            'interest' => 'required|string',
            'budget' => 'nullable|numeric|min:0',
        ]);

        try {
            $result = $this->deepSeekService->generateRecommendations(
                $request->interest,
                $request->budget ?? 500000
            );

            return response()->json($result);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to get recommendations: ' . $e->getMessage()
            ], 500);
        }
    }
}
