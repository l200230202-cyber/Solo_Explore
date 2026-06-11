@extends('admin.layouts.app')

@section('title', 'Dashboard')
@section('header', 'Dashboard')

@section('content')
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
    
    <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 transition duration-200 hover:shadow-md">
        <div class="flex items-center">
            <div class="p-3.5 rounded-xl bg-green-50 text-[#9DD770]">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-7 w-7" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                </svg>
            </div>
            <div class="ml-4">
                <p class="text-gray-400 text-xs font-semibold uppercase tracking-wider">Total Destinasi</p>
                <p class="text-3xl font-extrabold text-gray-800 mt-0.5">{{ $stats['destinations'] }}</p>
            </div>
        </div>
    </div>

    <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 transition duration-200 hover:shadow-md">
        <div class="flex items-center">
            <div class="p-3.5 rounded-xl bg-orange-50 text-orange-500">
                <i class="fas fa-utensils text-2xl"></i>
            </div>
            <div class="ml-4">
                <p class="text-gray-400 text-xs font-semibold uppercase tracking-wider">Total Kuliner</p>
                <p class="text-3xl font-extrabold text-gray-800 mt-0.5">{{ $stats['culinaries'] }}</p>
            </div>
        </div>
    </div>

    <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 transition duration-200 hover:shadow-md">
        <div class="flex items-center">
            <div class="p-3.5 rounded-xl bg-purple-50 text-purple-500">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-7 w-7" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 002-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                </svg>
            </div>
            <div class="ml-4">
                <p class="text-gray-400 text-xs font-semibold uppercase tracking-wider">Total Event</p>
                <p class="text-3xl font-extrabold text-gray-800 mt-0.5">{{ $stats['events'] }}</p>
            </div>
        </div>
    </div>

    <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 transition duration-200 hover:shadow-md">
        <div class="flex items-center">
            <div class="p-3.5 rounded-xl bg-blue-50 text-blue-500">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-7 w-7" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
                </svg>
            </div>
            <div class="ml-4">
                <p class="text-gray-400 text-xs font-semibold uppercase tracking-wider">Total Users</p>
                <p class="text-3xl font-extrabold text-gray-800 mt-0.5">{{ $stats['users'] }}</p>
            </div>
        </div>
    </div>
</div>

<div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
    <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
        <div class="p-5 border-b border-gray-50 flex justify-between items-center bg-gray-50/50">
            <h3 class="text-base font-bold text-gray-800">Destinasi Terbaru</h3>
            <span class="text-xs font-medium text-gray-400">Pembaruan Terkini</span>
        </div>
        <div class="p-6 divide-y divide-gray-100">
            @forelse($recentDestinations as $destination)
                <div class="flex items-center py-3 first:pt-0 last:pb-0 group">
                    <img src="{{ $destination->image_url }}" class="w-14 h-14 rounded-xl object-cover shadow-xs border border-gray-100 group-hover:scale-105 transition duration-200">
                    <div class="ml-4">
                        <p class="font-bold text-gray-800 text-sm group-hover:text-[#9DD770] transition duration-150">{{ $destination->name }}</p>
                        <p class="text-xs text-gray-400 flex items-center gap-1 mt-0.5">
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/>
                            </svg>
                            {{ $destination->location }}
                        </p>
                    </div>
                </div>
            @empty
                <div class="text-center py-8">
                    <p class="text-sm text-gray-400">Belum ada data destinasi.</p>
                </div>
            @endforelse
        </div>
    </div>

    <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
        <div class="p-5 border-b border-gray-50 flex justify-between items-center bg-gray-50/50">
            <h3 class="text-base font-bold text-gray-800">Event Terbaru</h3>
            <span class="text-xs font-medium text-gray-400">Agenda Terdekat</span>
        </div>
        <div class="p-6 divide-y divide-gray-100">
            @forelse($recentEvents as $event)
                <div class="flex items-center py-3 first:pt-0 last:pb-0 group">
                    <img src="{{ $event->image_url }}" class="w-14 h-14 rounded-xl object-cover shadow-xs border border-gray-100 group-hover:scale-105 transition duration-200">
                    <div class="ml-4">
                        <p class="font-bold text-gray-800 text-sm group-hover:text-purple-600 transition duration-150">{{ $event->name }}</p>
                        <p class="text-xs text-gray-400 flex items-center gap-1 mt-0.5">
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2 2v12a2 2 0 002 2z" />
                            </svg>
                            {{ \Carbon\Carbon::parse($event->start_date)->format('d M Y') }}
                        </p>
                    </div>
                </div>
            @empty
                <div class="text-center py-8">
                    <p class="text-sm text-gray-400">Belum ada data agenda event.</p>
                </div>
            @endforelse
        </div>
    </div>
</div>
@endsection