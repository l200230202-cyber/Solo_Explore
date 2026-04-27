<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Destination;
use App\Models\Culinary;
use App\Models\Event;
use App\Models\User;
use App\Models\Review;
use App\Models\Visit;

class DashboardController extends Controller
{
    public function index()
    {
        $stats = [
            'destinations' => Destination::count(),
            'culinaries' => Culinary::count(),
            'events' => Event::count(),
            'users' => User::where('is_admin', false)->count(),
            'reviews' => Review::count(),
            'visits' => Visit::count(),
        ];

        $recentDestinations = Destination::latest()->take(5)->get();
        $recentEvents = Event::latest()->take(5)->get();

        return view('admin.dashboard', compact('stats', 'recentDestinations', 'recentEvents'));
    }
}
