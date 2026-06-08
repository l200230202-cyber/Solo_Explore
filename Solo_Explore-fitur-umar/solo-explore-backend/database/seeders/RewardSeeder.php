<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Reward;
use Carbon\Carbon;

class RewardSeeder extends Seeder
{
    public function run(): void
    {
        $rewards = [
            [
                'name' => 'Voucher Wedangan 15%',
                'slug' => 'voucher-wedangan-15',
                'description' => '15% discount voucher for Wedangan Pendopo',
                'image' => 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400',
                'required_points' => 500,
                'type' => 'voucher',
                'value' => '15%',
                'valid_until' => Carbon::now()->addYear(),
            ],
            [
                'name' => 'Free Entrance Keraton',
                'slug' => 'free-entrance-keraton',
                'description' => 'Free entrance ticket to Keraton Surakarta',
                'image' => 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400',
                'required_points' => 800,
                'type' => 'voucher',
                'value' => 'Free',
                'valid_until' => Carbon::now()->addYear(),
            ],
            [
                'name' => 'Batik Workshop',
                'slug' => 'batik-workshop',
                'description' => 'Free batik making workshop at Pasar Klewer',
                'image' => 'https://images.unsplash.com/photo-1452860606245-08befc0ff44b?w=400',
                'required_points' => 1200,
                'type' => 'workshop',
                'value' => 'Free',
                'valid_until' => Carbon::now()->addYear(),
            ],
            [
                'name' => 'Solo Explorer T-Shirt',
                'slug' => 'solo-explorer-tshirt',
                'description' => 'Exclusive Solo Explorer merchandise t-shirt',
                'image' => 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400',
                'required_points' => 1500,
                'type' => 'merchandise',
                'value' => '1 pcs',
                'valid_until' => Carbon::now()->addYear(),
            ],
            [
                'name' => 'Culinary Tour Package',
                'slug' => 'culinary-tour-package',
                'description' => 'Guided culinary tour visiting 5 legendary food places',
                'image' => 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400',
                'required_points' => 2000,
                'type' => 'voucher',
                'value' => 'Free',
                'valid_until' => Carbon::now()->addYear(),
            ],
        ];

        foreach ($rewards as $reward) {
            Reward::create($reward);
        }
    }
}
