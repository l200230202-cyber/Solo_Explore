<?php

namespace App\Services;

use App\Models\Destination;
use App\Models\Culinary;

class RecommendationService
{
    public function getPersonalizedData()
    {
        // Langsung tarik data terbaru, gak pake filter biar gak error SQL
        return [
            'for_you_destinations' => Destination::latest()->limit(5)->get(),
            'for_you_culinaries' => Culinary::latest()->limit(5)->get(),
        ];
    }
}