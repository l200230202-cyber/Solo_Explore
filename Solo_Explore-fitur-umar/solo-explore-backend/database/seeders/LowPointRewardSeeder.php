<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Reward;
use Carbon\Carbon;

class LowPointRewardSeeder extends Seeder
{
    public function run(): void
    {
        $rewards = [
            [
                'name' => 'Sticker Pack Solo Explorer',
                'slug' => 'sticker-pack-solo-explorer',
                'description' => 'Exclusive Solo Explorer sticker pack',
                'image' => 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
                'required_points' => 100,
                'type' => 'merchandise',
                'value' => '1 pack',
                'valid_until' => Carbon::now()->addYear(),
                'is_active' => true,
            ],
            [
                'name' => 'Voucher Es Dawet 10%',
                'slug' => 'voucher-es-dawet-10',
                'description' => '10% discount voucher for traditional Es Dawet',
                'image' => 'https://images.unsplash.com/photo-1551024506-0bccd828d307?w=400',
                'required_points' => 150,
                'type' => 'voucher',
                'value' => '10%',
                'valid_until' => Carbon::now()->addYear(),
                'is_active' => true,
            ],
            [
                'name' => 'Free Postcard Set',
                'slug' => 'free-postcard-set',
                'description' => 'Beautiful Solo heritage postcard collection',
                'image' => 'https://images.unsplash.com/photo-1516975080664-ed2fc6a32937?w=400',
                'required_points' => 200,
                'type' => 'merchandise',
                'value' => '5 pcs',
                'valid_until' => Carbon::now()->addYear(),
                'is_active' => true,
            ],
            [
                'name' => 'Voucher Gudeg Yu Djum 15%',
                'slug' => 'voucher-gudeg-yu-djum-15',
                'description' => '15% discount voucher for Gudeg Yu Djum',
                'image' => 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400',
                'required_points' => 250,
                'type' => 'voucher',
                'value' => '15%',
                'valid_until' => Carbon::now()->addYear(),
                'is_active' => true,
            ],
            [
                'name' => 'Free Museum Entry',
                'slug' => 'free-museum-entry',
                'description' => 'Free entry ticket to Radya Pustaka Museum',
                'image' => 'https://images.unsplash.com/photo-1566127992631-137a642a90f4?w=400',
                'required_points' => 300,
                'type' => 'voucher',
                'value' => 'Free',
                'valid_until' => Carbon::now()->addYear(),
                'is_active' => true,
            ],
        ];

        foreach ($rewards as $reward) {
            Reward::firstOrCreate(['slug' => $reward['slug']], $reward);
        }
    }
}