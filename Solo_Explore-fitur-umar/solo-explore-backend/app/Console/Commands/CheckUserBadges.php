<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\User;
use App\Models\Visit;
use App\Models\Destination;
use App\Models\Culinary;
use App\Models\Event;
use App\Models\Badge;

class CheckUserBadges extends Command
{
    protected $signature = 'badges:check {email}';
    protected $description = 'Check and award badges for a specific user';

    public function handle()
    {
        $email = $this->argument('email');
        $user = User::where('email', $email)->first();
        
        if (!$user) {
            $this->error("User with email {$email} not found");
            return;
        }
        
        $this->info("Checking badges for user: {$user->name} (ID: {$user->id})");
        
        $totalVisits = $user->visits()->count();
        $totalDestinations = $user->visits()->where('visitable_type', Destination::class)->count();
        $totalCulinaries = $user->visits()->where('visitable_type', Culinary::class)->count();
        $totalEvents = $user->visits()->where('visitable_type', Event::class)->count();
        
        $this->info("Total visits: {$totalVisits}");
        $this->info("Destination visits: {$totalDestinations}");
        $this->info("Culinary visits: {$totalCulinaries}");
        $this->info("Event visits: {$totalEvents}");
        $this->info("Current badges: " . $user->badges()->count());
        
        // Check and award badges
        $this->checkAndAwardBadges($user);
        
        $this->info("Final badges: " . $user->fresh()->badges()->count());
    }
    
    private function checkAndAwardBadges($user)
    {
        $totalVisits = $user->visits()->count();
        $totalDestinations = $user->visits()->where('visitable_type', Destination::class)->count();
        $totalCulinaries = $user->visits()->where('visitable_type', Culinary::class)->count();
        $totalEvents = $user->visits()->where('visitable_type', Event::class)->count();
        
        // Badge: First Visit (1 visit)
        if ($totalVisits >= 1) {
            $this->awardBadgeIfNotExists($user, 'first-visit');
        }
        
        // Badge: Explorer (5 visits)
        if ($totalVisits >= 5) {
            $this->awardBadgeIfNotExists($user, 'explorer');
        }
        
        // Badge: Adventurer (10 visits)
        if ($totalVisits >= 10) {
            $this->awardBadgeIfNotExists($user, 'adventurer');
        }
        
        // Badge: Master Explorer (20 visits)
        if ($totalVisits >= 20) {
            $this->awardBadgeIfNotExists($user, 'master-explorer');
        }
        
        // Badge: Culture Enthusiast (5 destinations)
        if ($totalDestinations >= 5) {
            $this->awardBadgeIfNotExists($user, 'culture-enthusiast');
        }
        
        // Badge: Food Hunter (5 culinaries)
        if ($totalCulinaries >= 5) {
            $this->awardBadgeIfNotExists($user, 'food-hunter');
        }
    }
    
    private function awardBadgeIfNotExists($user, $badgeSlug)
    {
        $badge = Badge::where('slug', $badgeSlug)->first();
        
        if (!$badge) {
            $this->warn("Badge not found: {$badgeSlug}");
            return;
        }
        
        // Check if user already has this badge
        $hasBadge = \DB::table('user_badges')
            ->where('user_id', $user->id)
            ->where('badge_id', $badge->id)
            ->exists();
        
        if (!$hasBadge) {
            \DB::table('user_badges')->insert([
                'user_id' => $user->id,
                'badge_id' => $badge->id,
                'earned_at' => now(),
            ]);
            
            $this->info("✅ Badge awarded: {$badge->name}");
        } else {
            $this->line("Badge already exists: {$badge->name}");
        }
    }
}