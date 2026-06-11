<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Notification;
use App\Models\User;

class NotificationSeeder extends Seeder
{
    public function run(): void
    {
        $user = User::first();
        
        if (!$user) return;

        $notifications = [
            [
                'user_id' => $user->id,
                'type' => 'badge_earned',
                'title' => '🏆 Badge Baru!',
                'message' => 'Selamat! Kamu mendapatkan badge "Explorer" karena telah mengunjungi 5 destinasi.',
                'data' => ['badge_id' => 1, 'badge_name' => 'Explorer'],
                'is_read' => false,
            ],
            [
                'user_id' => $user->id,
                'type' => 'level_up',
                'title' => '⬆️ Level Up!',
                'message' => 'Selamat! Kamu naik ke Level 3. Terus jelajahi Solo Raya!',
                'data' => ['old_level' => 2, 'new_level' => 3],
                'is_read' => false,
            ],
            [
                'user_id' => $user->id,
                'type' => 'reward_available',
                'title' => '🎁 Reward Tersedia!',
                'message' => 'Kamu punya cukup poin untuk klaim reward "Diskon 20% Tiket Masuk". Buruan klaim!',
                'data' => ['reward_id' => 1, 'points_needed' => 500],
                'is_read' => true,
                'read_at' => now()->subHours(2),
            ],
            [
                'user_id' => $user->id,
                'type' => 'event_reminder',
                'title' => '📅 Event Besok!',
                'message' => 'Jangan lupa! Event "Sekaten 2026" akan dimulai besok di Alun-alun Utara.',
                'data' => ['event_id' => 1, 'event_name' => 'Sekaten 2026'],
                'is_read' => true,
                'read_at' => now()->subDays(1),
            ],
            [
                'user_id' => $user->id,
                'type' => 'points_earned',
                'title' => '⭐ Poin Didapat!',
                'message' => 'Kamu mendapat +30 poin dari kunjungan ke Keraton Surakarta!',
                'data' => ['points' => 30, 'destination_id' => 1],
                'is_read' => false,
            ],
        ];

        foreach ($notifications as $notification) {
            Notification::create($notification);
        }
    }
}
