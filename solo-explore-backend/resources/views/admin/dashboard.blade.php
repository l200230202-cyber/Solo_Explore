@extends('admin.layouts.app')

@section('title', 'Dashboard')
@section('header', 'Dashboard')

@section('content')
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-6">
    <!-- Total Destinations -->
    <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center">
            <div class="p-3 rounded-full bg-blue-100 text-blue-600">
                <i class="fas fa-map-marker-alt text-2xl"></i>
            </div>
            <div class="ml-4">
                <p class="text-gray-500 text-sm">Total Destinasi</p>
                <p class="text-2xl font-bold">{{ $stats['destinations'] }}</p>
            </div>
        </div>
    </div>

    <!-- Total Culinaries -->
    <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center">
            <div class="p-3 rounded-full bg-green-100 text-green-600">
                <i class="fas fa-utensils text-2xl"></i>
            </div>
            <div class="ml-4">
                <p class="text-gray-500 text-sm">Total Kuliner</p>
                <p class="text-2xl font-bold">{{ $stats['culinaries'] }}</p>
            </div>
        </div>
    </div>

    <!-- Total Events -->
    <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center">
            <div class="p-3 rounded-full bg-purple-100 text-purple-600">
                <i class="fas fa-calendar text-2xl"></i>
            </div>
            <div class="ml-4">
                <p class="text-gray-500 text-sm">Total Event</p>
                <p class="text-2xl font-bold">{{ $stats['events'] }}</p>
            </div>
        </div>
    </div>

    <!-- Total Users -->
    <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center">
            <div class="p-3 rounded-full bg-yellow-100 text-yellow-600">
                <i class="fas fa-users text-2xl"></i>
            </div>
            <div class="ml-4">
                <p class="text-gray-500 text-sm">Total Users</p>
                <p class="text-2xl font-bold">{{ $stats['users'] }}</p>
            </div>
        </div>
    </div>
</div>

<div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
    <!-- Recent Destinations -->
    <div class="bg-white rounded-lg shadow">
        <div class="p-6 border-b">
            <h3 class="text-lg font-semibold">Destinasi Terbaru</h3>
        </div>
        <div class="p-6">
            @forelse($recentDestinations as $destination)
                <div class="flex items-center mb-4 pb-4 border-b last:border-0">
                    <img src="{{ $destination->image_url }}" class="w-16 h-16 rounded object-cover">
                    <div class="ml-4">
                        <p class="font-semibold">{{ $destination->name }}</p>
                        <p class="text-sm text-gray-500">{{ $destination->location }}</p>
                    </div>
                </div>
            @empty
                <p class="text-gray-500">Belum ada destinasi</p>
            @endforelse
        </div>
    </div>

    <!-- Recent Events -->
    <div class="bg-white rounded-lg shadow">
        <div class="p-6 border-b">
            <h3 class="text-lg font-semibold">Event Terbaru</h3>
        </div>
        <div class="p-6">
            @forelse($recentEvents as $event)
                <div class="flex items-center mb-4 pb-4 border-b last:border-0">
                    <img src="{{ $event->image_url }}" class="w-16 h-16 rounded object-cover">
                    <div class="ml-4">
                        <p class="font-semibold">{{ $event->name }}</p>
                        <p class="text-sm text-gray-500">{{ \Carbon\Carbon::parse($event->start_date)->format('d M Y') }}</p>
                    </div>
                </div>
            @empty
                <p class="text-gray-500">Belum ada event</p>
            @endforelse
        </div>
    </div>
</div>
@endsection
