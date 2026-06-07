<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Visit;

class ShowVisits extends Command
{
    protected $signature = 'visits:show';
    protected $description = 'Show all visits in database';

    public function handle()
    {
        $visits = Visit::with('user')->get();
        
        $this->info("Total visits in database: " . $visits->count());
        
        foreach ($visits as $visit) {
            $this->line("Visit ID: {$visit->id}, User: {$visit->user->email}, Type: {$visit->visitable_type}, Date: {$visit->visit_date}");
        }
        
        // Group by user
        $userVisits = $visits->groupBy('user_id');
        $this->info("\nVisits by user:");
        foreach ($userVisits as $userId => $userVisitList) {
            $user = $userVisitList->first()->user;
            $this->line("User: {$user->email} - {$userVisitList->count()} visits");
        }
    }
}