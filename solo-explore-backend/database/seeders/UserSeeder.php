<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // Create super admin
        User::create([
            'name' => 'Admin Solo Explore',
            'email' => 'admin@soloexplore.com',
            'password' => Hash::make('admin123'),
            'role' => 'super_admin',
            'phone' => '081234567890',
            'bio' => 'SuperAdministrator',
            'level' => 0,
            'points' => 000,
            'total_destinations' => 0,
            'is_verified' => true,
            'is_admin' => true,
        ]);

        // Create test admin-mitra Wisata
        User::create([
            'name' => 'Amwis-admin wisata',
            'email' => 'amwis@gmail.com',
            'password' => Hash::make('admin123'),
            'role' => 'admin_mitra',
            'phone' => '081234567891',
            'bio' => 'Admin Mitra Wisata',
            'level' => 0,
            'points' => 000,
            'total_destinations' => 0,
            'is_verified' => true,
            'is_admin' => false,
        ]);

        // Create admin-mitra Kuliner
        User::create([
            'name' => 'Amner',
            'email' => 'amner@gmail.com',
            'password' => Hash::make('admin123'),
            'role' => 'admin_mitra',
            'phone' => '081234567892',
            'bio' => 'Admin Mitra Kuliner',
            'level' => 0,
            'points' => 000,
            'total_destinations' => 0,
            'is_verified' => true,
            'is_admin' => false,
        ]);

        // Create user rekomendasi wisata
        $user1 = User::create([
            'name' => 'Ubay',
            'email' => 'ubay@gmail.com',
            'password' => Hash::make('password123'),
            'role' => 'user',
            'phone' => '081234567893',
            'bio' => 'Destinatin Hunter',
            'level' => 0,
            'points' => 000,
            'total_destinations' => 0,
            'is_verified' => false,
            'is_admin' => false,
        ]);
        $user1->interests()->attach([1,2]);

        // 5. Create user rekomendasi kuliner
        $user2 = User::create([
            'name' => 'Usman',
            'email' => 'usman@gmail.com',
            'password' => Hash::make('password123'),
            'role' => 'user',
            'phone' => '081234567894',
            'bio' => 'Food Hunter',
            'level' => 0,
            'points' => 000,
            'total_destinations' => 0,
            'is_verified' => false,
            'is_admin' => false,
        ]);
        $user2->interests()->attach([3,4]);
    }
}
