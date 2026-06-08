<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class DeepSeekService
{
    private string $apiKey;
    private string $apiUrl = 'https://api.deepseek.com/v1/chat/completions';

    public function __construct()
    {
        $this->apiKey = env('DEEPSEEK_API_KEY', '');
    }

    /**
     * Generate travel itinerary using DeepSeek AI
     */
    public function generateItinerary(array $destinations, array $culinaries, array $events, array $preferences): array
    {
        if (empty($this->apiKey)) {
            return [
                'success' => false,
                'message' => 'DeepSeek API key not configured'
            ];
        }

        $prompt = $this->buildPrompt($destinations, $culinaries, $events, $preferences);

        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
                'Content-Type' => 'application/json',
            ])->timeout(30)->post($this->apiUrl, [
                'model' => 'deepseek-chat',
                'messages' => [
                    [
                        'role' => 'system',
                        'content' => 'You are a professional travel planner for Solo, Indonesia. Create detailed, practical itineraries based on user preferences and available destinations.'
                    ],
                    [
                        'role' => 'user',
                        'content' => $prompt
                    ]
                ],
                'temperature' => 0.7,
                'max_tokens' => 2000,
            ]);

            if ($response->successful()) {
                $data = $response->json();
                $itinerary = $data['choices'][0]['message']['content'] ?? '';

                return [
                    'success' => true,
                    'itinerary' => $itinerary,
                    'usage' => $data['usage'] ?? []
                ];
            }

            Log::error('DeepSeek API Error', [
                'status' => $response->status(),
                'body' => $response->body()
            ]);

            return [
                'success' => false,
                'message' => 'Failed to generate itinerary: ' . $response->body()
            ];

        } catch (\Exception $e) {
            Log::error('DeepSeek Service Exception', [
                'message' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return [
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Build prompt for AI
     */
    private function buildPrompt(array $destinations, array $culinaries, array $events, array $preferences): string
    {
        $budget = $preferences['budget'] ?? 500000;
        $days = $preferences['days'] ?? 1;
        $interests = $preferences['interests'] ?? 'general';

        $prompt = "Create a {$days}-day travel itinerary for Solo, Indonesia with a budget of Rp {$budget}.\n\n";
        $prompt .= "User interests: {$interests}\n\n";

        // Add selected destinations
        if (!empty($destinations)) {
            $prompt .= "SELECTED DESTINATIONS:\n";
            foreach ($destinations as $dest) {
                $prompt .= "- {$dest['name']}: {$dest['description']}\n";
                $prompt .= "  Location: {$dest['location']}\n";
                $prompt .= "  Price: Rp " . ($dest['price'] ?? 0) . "\n";
                if (!empty($dest['opening_hours'])) {
                    $prompt .= "  Hours: {$dest['opening_hours']}\n";
                }
                $prompt .= "\n";
            }
        }

        // Add selected culinaries
        if (!empty($culinaries)) {
            $prompt .= "SELECTED CULINARY SPOTS:\n";
            foreach ($culinaries as $cul) {
                $prompt .= "- {$cul['name']}: {$cul['description']}\n";
                $prompt .= "  Location: {$cul['location']}\n";
                $prompt .= "  Price Range: " . ($cul['price_range'] ?? 'N/A') . "\n";
                $prompt .= "\n";
            }
        }

        // Add selected events
        if (!empty($events)) {
            $prompt .= "SELECTED EVENTS:\n";
            foreach ($events as $event) {
                $prompt .= "- {$event['name']}: {$event['description']}\n";
                $prompt .= "  Date: {$event['start_date']} to {$event['end_date']}\n";
                $prompt .= "  Location: {$event['location']}\n";
                $prompt .= "\n";
            }
        }

        $prompt .= "\nPlease create a detailed day-by-day itinerary that:\n";
        $prompt .= "1. Includes all selected destinations, culinary spots, and events\n";
        $prompt .= "2. Optimizes the route to minimize travel time\n";
        $prompt .= "3. Stays within the budget\n";
        $prompt .= "4. Includes time estimates for each activity\n";
        $prompt .= "5. Suggests meal times at the selected culinary spots\n";
        $prompt .= "6. Provides practical tips and recommendations\n";
        $prompt .= "\nFormat the itinerary clearly with day numbers, times, and activities.";

        return $prompt;
    }

    /**
     * Generate simple recommendations
     */
    public function generateRecommendations(string $interest, int $budget): array
    {
        if (empty($this->apiKey)) {
            return [
                'success' => false,
                'message' => 'DeepSeek API key not configured'
            ];
        }

        $prompt = "Recommend 5 must-visit places in Solo, Indonesia for someone interested in {$interest} with a budget of Rp {$budget}. Include brief descriptions and estimated costs.";

        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
                'Content-Type' => 'application/json',
            ])->timeout(30)->post($this->apiUrl, [
                'model' => 'deepseek-chat',
                'messages' => [
                    [
                        'role' => 'system',
                        'content' => 'You are a travel expert for Solo, Indonesia.'
                    ],
                    [
                        'role' => 'user',
                        'content' => $prompt
                    ]
                ],
                'temperature' => 0.7,
                'max_tokens' => 1000,
            ]);

            if ($response->successful()) {
                $data = $response->json();
                return [
                    'success' => true,
                    'recommendations' => $data['choices'][0]['message']['content'] ?? ''
                ];
            }

            return [
                'success' => false,
                'message' => 'Failed to generate recommendations'
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ];
        }
    }
}
