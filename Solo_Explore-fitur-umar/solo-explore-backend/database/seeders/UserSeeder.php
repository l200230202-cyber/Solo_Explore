<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // Create admin user
        User::create([
            'name' => 'Admin Solo Explore',
            'email' => 'admin@soloexplore.com',
            'password' => Hash::make('admin123'),
            'phone' => '081234567899',
            'bio' => 'Administrator',
            'level' => 10,
            'points' => 0,
            'total_destinations' => 0,
            'is_verified' => true,
            'is_admin' => true,
        ]);

        // Create test user
        User::create([
            'name' => 'Aditya Pratama',
            'email' => 'aditya@example.com',
            'password' => Hash::make('password123'),
            'phone' => '081234567890',
            'bio' => 'Lanskap Surakarta Explorer',
            'level' => 4,
            'points' => 1250,
            'total_destinations' => 12,
            'is_verified' => true,
            'is_admin' => false,
        ]);

        // Create additional test users
        User::create([
            'name' => 'Budi Santoso',
            'email' => 'budi@example.com',
            'password' => Hash::make('password123'),
            'phone' => '081234567891',
            'bio' => 'Solo Food Hunter',
            'level' => 2,
            'points' => 650,
            'total_destinations' => 5,
            'is_verified' => true,
            'is_admin' => false,
        ]);

        User::create([
            'name' => 'Citra Dewi',
            'email' => 'citra@example.com',
            'password' => Hash::make('password123'),
            'phone' => '081234567892',
            'bio' => 'Culture Enthusiast',
            'level' => 3,
            'points' => 1100,
            'total_destinations' => 8,
            'is_verified' => false,
            'is_admin' => false,
        ]);
    }
}
