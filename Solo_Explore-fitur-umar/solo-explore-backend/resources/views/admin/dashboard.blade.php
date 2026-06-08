@extends('admin.layouts.app')

@section('title', 'Dashboard')
@section('header', 'Overview Solo Explore')

@section('content')
<div class="space-y-6">
    <!-- Welcome Card -->
    <div class="bg-gradient-to-r from-green-800 to-green-600 rounded-3xl p-8 text-white shadow-lg shadow-green-900/20">
        <h2 class="text-3xl font-bold mb-2">Halo, {{ auth()->user()->name }}! 👋</h2>
        <p class="text-green-100">Selamat datang kembali. Hari ini adalah hari yang produktif untuk mengelola destinasi & kuliner terbaik di Solo Raya.</p>
    </div>

    <!-- Stats Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        @php
            $stats = [
                ['label' => 'Total Destinasi', 'val' => $stats['destinations'], 'icon' => 'fa-map-marked-alt', 'color' => 'text-blue-500'],
                ['label' => 'Total Kuliner', 'val' => $stats['culinaries'], 'icon' => 'fa-utensils', 'color' => 'text-emerald-500'],
                ['label' => 'Total Event', 'val' => $stats['events'], 'icon' => 'fa-calendar-alt', 'color' => 'text-purple-500'],
                ['label' => 'Total Users', 'val' => $stats['users'], 'icon' => 'fa-users', 'color' => 'text-yellow-500'],
            ];
        @endphp
        @foreach($stats as $s)
        <div class="bg-white p-6 rounded-3xl border border-gray-100 shadow-sm flex items-center justify-between">
            <div>
                <p class="text-gray-500 text-sm font-medium">{{ $s['label'] }}</p>
                <p class="text-3xl font-black text-gray-800 mt-1">{{ $s['val'] }}</p>
            </div>
            <div class="{{ $s['color'] }} bg-gray-50 p-4 rounded-2xl">
                <i class="fas {{ $s['icon'] }} text-2xl"></i>
            </div>
        </div>
        @endforeach
    </div>

    <!-- Recent Data Area -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <!-- Destinasi Terbaru -->
        <div class="bg-white p-6 rounded-3xl border border-gray-100 shadow-sm">
            <div class="flex items-center justify-between mb-6">
                <h3 class="font-bold text-gray-800 text-lg">Destinasi Terbaru</h3>
                <a href="{{ route('admin.destinations.index') }}" class="text-green-600 font-bold text-sm hover:underline">Lihat Semua</a>
            </div>
            <div class="space-y-4">
                @forelse($recentDestinations as $dest)
                <div class="flex items-center gap-4 group">
                    <img src="{{ $dest->image_url }}" class="w-16 h-16 rounded-2xl object-cover shadow-inner">
                    <div class="flex-1">
                        <p class="font-bold text-gray-800 group-hover:text-green-700 transition-colors">{{ $dest->name }}</p>
                        <p class="text-xs text-gray-400 mt-0.5"><i class="fas fa-map-pin mr-1"></i> {{ $dest->location }}</p>
                    </div>
                </div>
                @empty
                <p class="text-gray-400 text-sm italic">Belum ada data destinasi.</p>
                @endforelse
            </div>
        </div>

        <!-- Event Terbaru -->
        <div class="bg-white p-6 rounded-3xl border border-gray-100 shadow-sm">
            <div class="flex items-center justify-between mb-6">
                <h3 class="font-bold text-gray-800 text-lg">Event Mendatang</h3>
                <a href="#" class="text-green-600 font-bold text-sm hover:underline">Lihat Semua</a>
            </div>
            <div class="space-y-4">
                @forelse($recentEvents as $e)
                <div class="flex items-center gap-4 bg-gray-50 p-4 rounded-2xl">
                    <div class="bg-white w-14 h-14 rounded-xl flex flex-col items-center justify-center border border-gray-100">
                        <span class="text-[10px] text-gray-400 font-bold uppercase">{{ \Carbon\Carbon::parse($e->start_date)->format('M') }}</span>
                        <span class="text-xl font-black text-green-700">{{ \Carbon\Carbon::parse($e->start_date)->format('d') }}</span>
                    </div>
                    <div>
                        <p class="font-bold text-gray-800">{{ $e->name }}</p>
                        <p class="text-xs text-gray-400">{{ \Carbon\Carbon::parse($e->start_date)->format('H:i') }} WIB</p>
                    </div>
                </div>
                @empty
                <p class="text-gray-400 text-sm italic">Belum ada data event.</p>
                @endforelse
            </div>
        </div>
    </div>
</div>
@endsection