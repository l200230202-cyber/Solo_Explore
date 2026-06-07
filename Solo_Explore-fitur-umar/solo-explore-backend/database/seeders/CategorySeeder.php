<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Category;

class CategorySeeder extends Seeder
{
    public function run(): void
    {
        $categories = [
            [
                'name' => 'Wisata Alam',
                'slug' => 'wisata-alam',
                'icon' => 'landscape',
                'description' => 'Natural tourism destinations',
                'order' => 1,
            ],
            [
                'name' => 'Budaya',
                'slug' => 'budaya',
                'icon' => 'castle',
                'description' => 'Cultural heritage sites',
                'order' => 2,
            ],
            [
                'name' => 'Kuliner',
                'slug' => 'kuliner',
                'icon' => 'restaurant',
                'description' => 'Culinary destinations',
                'order' => 3,
            ],
            [
                'name' => 'Belanja',
                'slug' => 'belanja',
                'icon' => 'shopping_bag',
                'description' => 'Shopping destinations',
                'order' => 4,
            ],
        ];

        foreach ($categories as $category) {
            Category::create($category);
        }
    }
}
