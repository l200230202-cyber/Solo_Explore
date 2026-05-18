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
        // Gunakan nilai default kosong agar tidak crash jika .env belum ada key-nya
        $this->apiKey = env('DEEPSEEK_API_KEY', '');
    }

    public function generateItinerary(array $destinations, array $culinaries, array $events, array $preferences): array
    {
        if (empty($this->apiKey)) {
            return ['success' => false, 'message' => 'API Key not configured'];
        }

        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
                'Content-Type' => 'application/json',
            ])->timeout(30)->post($this->apiUrl, [
                'model' => 'deepseek-chat',
                'messages' => [
                    ['role' => 'system', 'content' => 'Travel planner.'],
                    ['role' => 'user', 'content' => 'Plan a trip.']
                ],
            ]);

            return ['success' => $response->successful()];
        } catch (\Exception $e) {
            Log::error($e->getMessage());
            return ['success' => false];
        }
    }
}