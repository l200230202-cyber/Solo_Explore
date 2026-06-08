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
            'role' => 'super_admin',
            'phone' => '081234567890',
            'bio' => 'SuperAdministrator',
            'level' => 10,
            'points' => 000,
            'total_destinations' => 0,
            'is_verified' => true,
            'is_admin' => true,
        ]);

        // Create test user
        User::create([
            'name' => 'Amwis-admin wisata',
            'email' => 'amwis@gmail.com',
            'password' => Hash::make('password123'),
            'role' => 'admin_mitra',
            'phone' => '081234567891',
            'bio' => 'Pemilik destinasi wisata',
            'level' => 4,
            'points' => 1250,
            'total_destinations' => 12,
            'is_verified' => true,
            'is_admin' => false,
        ]);

        // Create additional test users
        User::create([
            'name' => 'Amner',
            'email' => 'amner@gmail.com',
            'password' => Hash::make('password123'),
            'role' => 'admin_mitra',
            'phone' => '081234567892',
            'bio' => 'Solo Food Hunter',
            'level' => 2,
            'points' => 650,
            'total_destinations' => 5,
            'is_verified' => true,
            'is_admin' => false,
        ]);

        User::create([
            'name' => 'Ubay',
            'email' => 'ubay@gmail.com',
            'password' => Hash::make('password123'),
            'role' => 'user',
            'phone' => '081234567893',
            'bio' => 'Destinatin Hunter',
            'level' => 3,
            'points' => 100,
            'total_destinations' => 8,
            'is_verified' => false,
            'is_admin' => false,
        ]);

        User::create([
            'name' => 'Usman',
            'email' => 'usman@gmail.com',
            'password' => Hash::make('password123'),
            'role' => 'user',
            'phone' => '081234567894',
            'bio' => 'Food Hunter',
            'level' => 4,
            'points' => 200,
            'total_destinations' => 8,
            'is_verified' => false,
            'is_admin' => false,
        ]);
    }
}
