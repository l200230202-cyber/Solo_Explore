<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\TripPlan;
use App\Models\TripPlanItem;
use App\Models\Destination;
use App\Models\Culinary;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class TripPlanController extends Controller
{
    /**
     * Get all user trip plans
     * GET /api/trip-plans
     */
    public function index()
    {
        try {
            $tripPlans = auth()->user()->tripPlans()->withCount('items')->get();

            return response()->json([
                'success' => true,
                'message' => 'Trip plans retrieved successfully',
                'data' => $tripPlans->map(function ($plan) {
                    return [
                        'id' => $plan->id,
                        'title' => $plan->title,
                        'description' => $plan->description,
                        'start_date' => $plan->start_date->format('Y-m-d'),
                        'end_date' => $plan->end_date->format('Y-m-d'),
                        'total_days' => $plan->total_days,
                        'status' => $plan->status,
                        'items_count' => $plan->items_count,
                        'created_at' => $plan->created_at->toISOString(),
                    ];
                }),
                'errors' => null,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve trip plans',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }

    /**
     * Get trip plan detail
     * GET /api/trip-plans/{id}
     */
    public function show($id)
    {
        try {
            $tripPlan = auth()->user()->tripPlans()->with('items.plannable')->findOrFail($id);

            return response()->json([
                'success' => true,
                'message' => 'Trip plan retrieved successfully',
                'data' => [
                    'id' => $tripPlan->id,
                    'title' => $tripPlan->title,
                    'description' => $tripPlan->description,
                    'start_date' => $tripPlan->start_date->format('Y-m-d'),
                    'end_date' => $tripPlan->end_date->format('Y-m-d'),
                    'total_days' => $tripPlan->total_days,
                    'status' => $tripPlan->status,
                    'items' => $tripPlan->items->map(function ($item) {
                        $plannable = $item->plannable;
                        if (!$plannable) return null;

                        $type = match($item->plannable_type) {
                            Destination::class => 'destination',
                            Culinary::class => 'culinary',
                            \App\Models\Event::class => 'event',
                            default => 'unknown',
                        };

                        return [
                            'id' => $item->id,
                            'day_number' => $item->day_number,
                            'time' => $item->time,
                            'order' => $item->order,
                            'plannable_type' => $type,
                            'plannable_id' => $item->plannable_id,
                            'name' => $plannable->name,
                            'image' => $plannable->image_url,  // Use accessor for full URL
                            'location' => $plannable->location,
                            'rating' => $plannable->rating ?? ($type === 'event' ? null : 0),  // ✅ FIXED: Events don't have rating
                            'notes' => $item->notes,
                        ];
                    })->filter()->values(),
                    'created_at' => $tripPlan->created_at->toISOString(),
                ],
                'errors' => null,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve trip plan',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }

    /**
     * Create trip plan
     * POST /api/trip-plans
     */
    public function store(Request $request)
    {
        try {
            $validated = $request->validate([
                'title' => 'required|string|max:255',
                'description' => 'nullable|string',
                'start_date' => 'required|date',
                'end_date' => 'required|date|after_or_equal:start_date',
            ]);

            $tripPlan = TripPlan::create([
                'user_id' => auth()->id(),
                'title' => $validated['title'],
                'description' => $validated['description'] ?? null,
                'start_date' => $validated['start_date'],
                'end_date' => $validated['end_date'],
                'status' => 'draft',
            ]);

            $tripPlan->calculateTotalDays();

            return response()->json([
                'success' => true,
                'message' => 'Trip plan created successfully',
                'data' => [
                    'id' => $tripPlan->id,
                    'title' => $tripPlan->title,
                    'start_date' => $tripPlan->start_date->format('Y-m-d'),
                    'end_date' => $tripPlan->end_date->format('Y-m-d'),
                    'total_days' => $tripPlan->total_days,
                    'status' => $tripPlan->status,
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
                'message' => 'Failed to create trip plan',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }

    /**
     * Update trip plan
     * PUT /api/trip-plans/{id}
     */
    public function update(Request $request, $id)
    {
        try {
            $tripPlan = auth()->user()->tripPlans()->findOrFail($id);

            $validated = $request->validate([
                'title' => 'sometimes|string|max:255',
                'description' => 'nullable|string',
                'start_date' => 'sometimes|date',
                'end_date' => 'sometimes|date|after_or_equal:start_date',
                'status' => 'sometimes|in:draft,active,completed',
            ]);

            $tripPlan->update($validated);
            $tripPlan->calculateTotalDays();

            return response()->json([
                'success' => true,
                'message' => 'Trip plan updated successfully',
                'data' => [
                    'id' => $tripPlan->id,
                    'title' => $tripPlan->title,
                    'status' => $tripPlan->status,
                ],
                'errors' => null,
            ], 200);

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
                'message' => 'Failed to update trip plan',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }

    /**
     * Delete trip plan
     * DELETE /api/trip-plans/{id}
     */
    public function destroy($id)
    {
        try {
            $tripPlan = auth()->user()->tripPlans()->findOrFail($id);
            $tripPlan->delete();

            return response()->json([
                'success' => true,
                'message' => 'Trip plan deleted successfully',
                'data' => null,
                'errors' => null,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to delete trip plan',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }

    /**
     * Add item to trip plan
     * POST /api/trip-plans/{id}/items
     */
    public function addItem(Request $request, $id)
    {
        try {
            \Log::info('Adding item to trip plan', [
                'plan_id' => $id,
                'request_data' => $request->all(),
            ]);

            $tripPlan = auth()->user()->tripPlans()->findOrFail($id);

            $validated = $request->validate([
                'plannable_type' => 'required|in:destination,culinary,event',
                'plannable_id' => 'required|integer',
                'day_number' => 'required|integer|min:1',
                'time' => 'nullable|date_format:H:i',
                'notes' => 'nullable|string',
            ]);

            \Log::info('Validation passed', ['validated' => $validated]);

            // Validate plannable exists
            $plannableClass = match($validated['plannable_type']) {
                'destination' => Destination::class,
                'culinary' => Culinary::class,
                'event' => \App\Models\Event::class,
            };
            
            \Log::info('Looking for plannable', [
                'class' => $plannableClass,
                'id' => $validated['plannable_id'],
            ]);

            $plannable = $plannableClass::findOrFail($validated['plannable_id']);

            \Log::info('Plannable found', ['plannable' => $plannable->name]);

            // Get next order number for this day
            $maxOrder = TripPlanItem::where('trip_plan_id', $id)
                ->where('day_number', $validated['day_number'])
                ->max('order') ?? 0;

            $item = TripPlanItem::create([
                'trip_plan_id' => $id,
                'plannable_type' => $plannableClass,
                'plannable_id' => $validated['plannable_id'],
                'day_number' => $validated['day_number'],
                'time' => $validated['time'] ?? null,
                'order' => $maxOrder + 1,
                'notes' => $validated['notes'] ?? null,
            ]);

            \Log::info('Item created successfully', ['item_id' => $item->id]);

            return response()->json([
                'success' => true,
                'message' => 'Item added to trip plan',
                'data' => [
                    'id' => $item->id,
                    'day_number' => $item->day_number,
                    'time' => $item->time,
                    'order' => $item->order,
                ],
                'errors' => null,
            ], 201);

        } catch (ValidationException $e) {
            \Log::error('Validation failed', ['errors' => $e->errors()]);
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'data' => null,
                'errors' => $e->errors(),
            ], 422);
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            \Log::error('Model not found', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'message' => 'Trip plan or item not found',
                'data' => null,
                'errors' => ['server' => ['The requested resource was not found']],
            ], 404);
        } catch (\Exception $e) {
            \Log::error('Failed to add item', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);
            return response()->json([
                'success' => false,
                'message' => 'Failed to add item: ' . $e->getMessage(),
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }

    /**
     * Remove item from trip plan
     * DELETE /api/trip-plans/{id}/items/{itemId}
     */
    public function removeItem($id, $itemId)
    {
        try {
            $tripPlan = auth()->user()->tripPlans()->findOrFail($id);
            $item = $tripPlan->items()->findOrFail($itemId);
            $item->delete();

            return response()->json([
                'success' => true,
                'message' => 'Item removed from trip plan',
                'data' => null,
                'errors' => null,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to remove item',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }

    /**
     * Call DeepSeek AI API for intelligent recommendations
     */
    private function callDeepSeekAI($budget, $interests, $duration, $availableDestinations, $availableCulinaries)
    {
        try {
            $apiKey = env('DEEPSEEK_API_KEY');
            if (!$apiKey) {
                \Log::warning('DeepSeek API key not configured, using fallback algorithm');
                return null;
            }

            $client = new \GuzzleHttp\Client();
            
            // Prepare context for AI
            $destinationsList = collect($availableDestinations)->map(function ($dest) {
                return [
                    'id' => $dest->id,
                    'name' => $dest->name,
                    'category' => $dest->category->name ?? 'Unknown',
                    'price' => $dest->price ?? 0,
                    'rating' => $dest->rating ?? 0,
                    'description' => substr($dest->description ?? '', 0, 100),
                ];
            })->toArray();

            $culinaryList = collect($availableCulinaries)->map(function ($cul) {
                return [
                    'id' => $cul->id,
                    'name' => $cul->name,
                    'price_range' => $cul->price_range ?? 'Unknown',
                    'rating' => $cul->rating ?? 0,
                ];
            })->toArray();

            $prompt = "You are a travel planner AI for Solo, Indonesia. Create a {$duration}-day itinerary with:\n\n";
            $prompt .= "Budget: Rp " . number_format($budget, 0, ',', '.') . "\n";
            $prompt .= "Interests: " . implode(', ', $interests) . "\n\n";
            $prompt .= "Available Destinations:\n" . json_encode($destinationsList, JSON_PRETTY_PRINT) . "\n\n";
            $prompt .= "Available Culinary Places:\n" . json_encode($culinaryList, JSON_PRETTY_PRINT) . "\n\n";
            $prompt .= "Create a daily schedule with:\n";
            $prompt .= "- Morning destination (09:00)\n";
            $prompt .= "- Lunch place (12:00)\n";
            $prompt .= "- Afternoon destination (14:00)\n";
            $prompt .= "- Dinner place (18:00)\n\n";
            $prompt .= "Return ONLY a JSON array with this structure:\n";
            $prompt .= "[\n";
            $prompt .= "  {\"day\": 1, \"time\": \"09:00\", \"type\": \"destination\", \"id\": 1, \"notes\": \"reason\"},\n";
            $prompt .= "  {\"day\": 1, \"time\": \"12:00\", \"type\": \"culinary\", \"id\": 2, \"notes\": \"reason\"}\n";
            $prompt .= "]\n";
            $prompt .= "Stay within budget and match interests. No markdown, just JSON.";

            $response = $client->post('https://api.deepseek.com/v1/chat/completions', [
                'headers' => [
                    'Authorization' => 'Bearer ' . $apiKey,
                    'Content-Type' => 'application/json',
                ],
                'json' => [
                    'model' => 'deepseek-chat',
                    'messages' => [
                        [
                            'role' => 'system',
                            'content' => 'You are a helpful travel planning assistant. Always respond with valid JSON only.'
                        ],
                        [
                            'role' => 'user',
                            'content' => $prompt
                        ]
                    ],
                    'temperature' => 0.7,
                    'max_tokens' => 2000,
                ],
                'timeout' => 30,
            ]);

            $result = json_decode($response->getBody()->getContents(), true);
            
            if (isset($result['choices'][0]['message']['content'])) {
                $content = $result['choices'][0]['message']['content'];
                
                // Extract JSON from response (remove markdown if present)
                $content = preg_replace('/```json\s*/', '', $content);
                $content = preg_replace('/```\s*/', '', $content);
                $content = trim($content);
                
                $aiPlan = json_decode($content, true);
                
                if (json_last_error() === JSON_ERROR_NONE && is_array($aiPlan)) {
                    \Log::info('DeepSeek AI generated plan successfully', ['items' => count($aiPlan)]);
                    return $aiPlan;
                } else {
                    \Log::warning('DeepSeek AI returned invalid JSON', ['content' => $content]);
                }
            }

            return null;

        } catch (\Exception $e) {
            \Log::error('DeepSeek AI API error: ' . $e->getMessage());
            return null;
        }
    }

    /**
     * Generate AI trip plan based on preferences
     * POST /api/trip-plans/{id}/generate
     */
    public function generate(Request $request, $id)
    {
        try {
            $tripPlan = auth()->user()->tripPlans()->findOrFail($id);

            $validated = $request->validate([
                'budget' => 'required|numeric|min:0',
                'interests' => 'required|array',
                'interests.*' => 'string',
                'duration' => 'required|integer|min:1|max:7',
            ]);

            $budget = $validated['budget'];
            $interests = $validated['interests'];
            $duration = $validated['duration'];

            // Bersihkan itinerary lama sebelum generate yang baru
            $tripPlan->items()->delete();

            // Ambil destinasi yang sesuai dengan ketertarikan (kategori slug)
            $availableDestinations = Destination::whereHas('category', function ($query) use ($interests) {
                $query->whereIn('slug', $interests);
            })->with('category')->get();

            // Jika tidak ada yang cocok dengan interest, ambil 15 destinasi acak sebagai cadangan
            if ($availableDestinations->isEmpty()) {
                $availableDestinations = Destination::limit(15)->get();
            }

            // Ambil semua data kuliner yang tersedia
            $availableCulinaries = Culinary::get();

            $generatedItems = [];
            $budgetPerDay = $budget / $duration;
            $destinationBudget = $budgetPerDay * 0.6; // Alokasi 60% budget harian untuk tiket wisata

            // Looping menyusun itinerary per hari
            for ($day = 1; $day <= $duration; $day++) {
                $order = 1;

                // 1. PAGI: Destinasi Wisata
                $morningDestination = $availableDestinations
                    ->where('price', '<=', $destinationBudget)
                    ->whereNotIn('id', collect($generatedItems)->where('plannable_type', Destination::class)->pluck('plannable_id'))
                    ->shuffle()->first();

                if (!$morningDestination && $availableDestinations->isNotEmpty()) {
                    $morningDestination = $availableDestinations->shuffle()->first();
                }

                if ($morningDestination) {
                    $generatedItems[] = TripPlanItem::create([
                        'trip_plan_id' => $id,
                        'plannable_type' => Destination::class,
                        'plannable_id' => $morningDestination->id,
                        'day_number' => $day,
                        'time' => '09:00',
                        'order' => $order++,
                        'notes' => 'Destinasi pagi - ' . $morningDestination->name,
                    ]);
                }

                // 2. SIANG: Tempat Kuliner / Rumah Makan
                $lunchCulinary = $availableCulinaries
                    ->whereNotIn('id', collect($generatedItems)->where('plannable_type', Culinary::class)->pluck('plannable_id'))
                    ->shuffle()->first();

                if (!$lunchCulinary && $availableCulinaries->isNotEmpty()) {
                    $lunchCulinary = $availableCulinaries->shuffle()->first();
                }

                if ($lunchCulinary) {
                    $generatedItems[] = TripPlanItem::create([
                        'trip_plan_id' => $id,
                        'plannable_type' => Culinary::class,
                        'plannable_id' => $lunchCulinary->id,
                        'day_number' => $day,
                        'time' => '12:00',
                        'order' => $order++,
                        'notes' => 'Makan siang - ' . $lunchCulinary->name,
                    ]);
                }

                // 3. SORE: Destinasi Wisata Kedua
                $afternoonDestination = $availableDestinations
                    ->where('price', '<=', $destinationBudget)
                    ->whereNotIn('id', collect($generatedItems)->where('plannable_type', Destination::class)->pluck('plannable_id'))
                    ->shuffle()->first();

                if (!$afternoonDestination && $availableDestinations->isNotEmpty()) {
                    $afternoonDestination = $availableDestinations->shuffle()->first();
                }

                if ($afternoonDestination) {
                    $generatedItems[] = TripPlanItem::create([
                        'trip_plan_id' => $id,
                        'plannable_type' => Destination::class,
                        'plannable_id' => $afternoonDestination->id,
                        'day_number' => $day,
                        'time' => '14:00',
                        'order' => $order++,
                        'notes' => 'Destinasi sore - ' . $afternoonDestination->name,
                    ]);
                }

                // 4. MALAM: Tempat Kuliner Malam
                $dinnerCulinary = $availableCulinaries
                    ->whereNotIn('id', collect($generatedItems)->where('plannable_type', Culinary::class)->pluck('plannable_id'))
                    ->shuffle()->first();

                if (!$dinnerCulinary && $availableCulinaries->isNotEmpty()) {
                    $dinnerCulinary = $availableCulinaries->shuffle()->first();
                }

                if ($dinnerCulinary) {
                    $generatedItems[] = TripPlanItem::create([
                        'trip_plan_id' => $id,
                        'plannable_type' => Culinary::class,
                        'plannable_id' => $dinnerCulinary->id,
                        'day_number' => $day,
                        'time' => '18:00',
                        'order' => $order++,
                        'notes' => 'Makan malam - ' . $dinnerCulinary->name,
                    ]);
                }
            }

            // Hitung perkiraan total biaya berdasarkan item yang didapat
            $estimatedCost = 0;
            foreach ($generatedItems as $item) {
                $plannable = $item->plannable;
                if ($plannable instanceof Destination && $plannable->price) {
                    $estimatedCost += $plannable->price;
                } elseif ($plannable instanceof Culinary && $plannable->price_range) {
                    preg_match_all('/\d+/', $plannable->price_range, $matches);
                    if (count($matches[0]) >= 2) {
                        $avgPrice = (intval($matches[0][0]) + intval($matches[0][1])) / 2;
                        $estimatedCost += $avgPrice;
                    }
                }
            }

            $tripPlan->update(['status' => 'active']);

            return response()->json([
                'success' => true,
                'message' => 'Trip plan generated successfully using local algorithm',
                'data' => [
                    'total_items' => count($generatedItems),
                    'total_days' => $duration,
                    'items_per_day' => $duration > 0 ? count($generatedItems) / $duration : 0,
                    'estimated_cost' => round($estimatedCost),
                    'budget' => $budget,
                    'budget_remaining' => max(0, $budget - $estimatedCost),
                    'ai_powered' => false,
                ],
                'errors' => null,
            ], 200);

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
                'message' => 'Failed to generate plan',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }
}