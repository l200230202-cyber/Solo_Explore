<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Category;

class CategoryController extends Controller
{
    /**
     * Get all categories
     * GET /api/categories
     */
    public function index()
    {
        try {
            $categories = Category::active()->ordered()->get();

            return response()->json([
                'success' => true,
                'message' => 'Categories retrieved successfully',
                'data' => $categories->map(function ($category) {
                    return [
                        'id' => $category->id,
                        'name' => $category->name,
                        'slug' => $category->slug,
                        'icon' => $category->icon,
                        'description' => $category->description,
                        'is_active' => $category->is_active,
                    ];
                }),
                'errors' => null,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve categories',
                'data' => null,
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }
}
