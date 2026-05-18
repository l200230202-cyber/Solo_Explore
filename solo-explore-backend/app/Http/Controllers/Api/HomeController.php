<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\RecommendationService;
use App\Models\Destination;
use App\Models\Culinary; // Pastikan Model Culinary di-import
use Illuminate\Http\Request;

class HomeController extends Controller
{
    public function index(RecommendationService $recService)
    {
        // 1. Ambil data rekomendasi
        $personalized = $recService->getPersonalizedData();

        // 2. Fungsi Helper untuk membetulkan URL Gambar
        $fixImageUrl = function($items) {
            return $items->map(function($item) {
                if ($item->image && !str_starts_with($item->image, 'http')) {
                    $item->image = url('storage/' . $item->image);
                } else if (!$item->image) {
                    // Placeholder jika gambar kosong
                    $item->image = 'https://via.placeholder.com/400x300?text=No+Image';
                }
                return $item;
            });
        };

        // 3. FALLBACK: Jika data personal kosong, ambil data default
        if (!isset($personalized['for_you_destinations']) || $personalized['for_you_destinations']->isEmpty()) {
            $personalized['for_you_destinations'] = Destination::where('is_recommended', 1)->latest()->limit(5)->get();
            // Jika masih kosong juga (database benar-benar sepi), ambil apa saja yang ada
            if ($personalized['for_you_destinations']->isEmpty()) {
                $personalized['for_you_destinations'] = Destination::latest()->limit(5)->get();
            }
        }

        if (!isset($personalized['for_you_culinaries']) || $personalized['for_you_culinaries']->isEmpty()) {
            $personalized['for_you_culinaries'] = Culinary::latest()->limit(5)->get();
        }

        // 4. Poles URL Gambar
        $personalized['for_you_destinations'] = $fixImageUrl($personalized['for_you_destinations']);
        $personalized['for_you_culinaries'] = $fixImageUrl($personalized['for_you_culinaries']);

        // 5. Ambil data Trending (Terbaru)
        $allDestinations = Destination::latest()->limit(10)->get();
        $allDestinations = $fixImageUrl($allDestinations);

        // 6. Respon JSON
        return response()->json([
            'status' => 'success',
            'message' => 'Data Home Berhasil Dimuat',
            'data' => [
                'personalized' => [
                    'for_you_destinations' => $personalized['for_you_destinations'],
                    'for_you_culinaries' => $personalized['for_you_culinaries'],
                ],
                'trending' => $allDestinations,
            ]
        ]);
    }
}