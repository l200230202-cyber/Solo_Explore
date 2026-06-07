<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $this->call([
            CategorySeeder::class,
            UserSeeder::class,
            DestinationSeeder::class,
            CulinarySeeder::class,
            EventSeeder::class,
            BadgeSeeder::class,
            RewardSeeder::class,
            LowPointRewardSeeder::class,
        ]);
    }
}
