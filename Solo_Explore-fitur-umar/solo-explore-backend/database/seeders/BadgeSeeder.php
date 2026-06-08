<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Badge;

class BadgeSeeder extends Seeder
{
    public function run(): void
    {
        $badges = [
            [
                'name' => 'First Visit',
                'slug' => 'first-visit',
                'description' => 'Complete your first visit',
                'icon' => 'flag',
                'requirement' => 'Complete 1 visit',
                'required_points' => 50,
            ],
            [
                'name' => 'Explorer',
                'slug' => 'explorer',
                'description' => 'Complete 5 visits',
                'icon' => 'explore',
                'requirement' => 'Complete 5 visits',
                'required_points' => 250,
            ],
            [
                'name' => 'Adventurer',
                'slug' => 'adventurer',
                'description' => 'Complete 10 visits',
                'icon' => 'hiking',
                'requirement' => 'Complete 10 visits',
                'required_points' => 500,
            ],
            [
                'name' => 'Master Explorer',
                'slug' => 'master-explorer',
                'description' => 'Complete 20 visits',
                'icon' => 'workspace_premium',
                'requirement' => 'Complete 20 visits',
                'required_points' => 1000,
            ],
            [
                'name' => 'Palace Seeker',
                'slug' => 'palace-seeker',
                'description' => 'Visit 5 palace destinations',
                'icon' => 'temple_buddhist',
                'requirement' => 'Visit 5 palaces',
                'required_points' => 250,
            ],
            [
                'name' => 'Food Hunter',
                'slug' => 'food-hunter',
                'description' => 'Try 5 different culinary places',
                'icon' => 'restaurant',
                'requirement' => 'Visit 5 culinary places',
                'required_points' => 150,
            ],
            [
                'name' => 'Culture Enthusiast',
                'slug' => 'culture-enthusiast',
                'description' => 'Visit 5 destinations',
                'icon' => 'celebration',
                'requirement' => 'Visit 5 destinations',
                'required_points' => 250,
            ],
            [
                'name' => 'Review Champion',
                'slug' => 'review-champion',
                'description' => 'Write 15 reviews',
                'icon' => 'rate_review',
                'requirement' => 'Write 15 reviews',
                'required_points' => 300,
            ],
            [
                'name' => 'Solo Expert',
                'slug' => 'solo-expert',
                'description' => 'Reach level 5',
                'icon' => 'workspace_premium',
                'requirement' => 'Reach level 5',
                'required_points' => 2000,
            ],
        ];

        foreach ($badges as $badge) {
            Badge::create($badge);
        }
    }
}
