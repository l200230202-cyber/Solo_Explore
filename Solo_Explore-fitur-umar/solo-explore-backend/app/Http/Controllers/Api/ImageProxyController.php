<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class ImageProxyController extends Controller
{
    /**
     * Proxy external images to avoid CORS issues
     * GET /api/proxy-image?url=https://example.com/image.jpg
     */
    public function proxy(Request $request)
    {
        $url = $request->query('url');

        if (!$url) {
            return response()->json([
                'success' => false,
                'message' => 'URL parameter is required',
            ], 400);
        }

        // Validate URL
        if (!filter_var($url, FILTER_VALIDATE_URL)) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid URL',
            ], 400);
        }

        try {
            // Fetch the image
            $response = Http::timeout(10)->get($url);

            if ($response->failed()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Failed to fetch image',
                ], 404);
            }

            // Get content type
            $contentType = $response->header('Content-Type') ?? 'image/jpeg';

            // Return image with proper headers
            return response($response->body())
                ->header('Content-Type', $contentType)
                ->header('Access-Control-Allow-Origin', '*')
                ->header('Cache-Control', 'public, max-age=86400'); // Cache for 1 day

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error fetching image: ' . $e->getMessage(),
            ], 500);
        }
    }
}
