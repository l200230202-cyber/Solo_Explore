<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'Admin Panel') - Solo Explore</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="bg-gray-100">
    <div class="flex h-screen">
        <!-- Sidebar -->
        <aside class="w-64 bg-blue-900 text-white">
            <div class="p-4">
                <h1 class="text-2xl font-bold">Solo Explore</h1>
                <p class="text-sm text-blue-200">Admin Panel</p>
            </div>
            <nav class="mt-6">
                <a href="{{ route('admin.dashboard') }}" class="flex items-center px-4 py-3 hover:bg-blue-800 {{ request()->routeIs('admin.dashboard') ? 'bg-blue-800' : '' }}">
                    <i class="fas fa-home mr-3"></i> Dashboard
                </a>
                <a href="{{ route('admin.destinations.index') }}" class="flex items-center px-4 py-3 hover:bg-blue-800 {{ request()->routeIs('admin.destinations.*') ? 'bg-blue-800' : '' }}">
                    <i class="fas fa-map-marker-alt mr-3"></i> Destinasi
                </a>
                <a href="{{ route('admin.culinaries.index') }}" class="flex items-center px-4 py-3 hover:bg-blue-800 {{ request()->routeIs('admin.culinaries.*') ? 'bg-blue-800' : '' }}">
                    <i class="fas fa-utensils mr-3"></i> Kuliner
                </a>
                <a href="{{ route('admin.events.index') }}" class="flex items-center px-4 py-3 hover:bg-blue-800 {{ request()->routeIs('admin.events.*') ? 'bg-blue-800' : '' }}">
                    <i class="fas fa-calendar mr-3"></i> Event
                </a>
                <a href="{{ route('admin.categories.index') }}" class="flex items-center px-4 py-3 hover:bg-blue-800 {{ request()->routeIs('admin.categories.*') ? 'bg-blue-800' : '' }}">
                    <i class="fas fa-tags mr-3"></i> Kategori
                </a>
                <a href="{{ route('admin.users.index') }}" class="flex items-center px-4 py-3 hover:bg-blue-800 {{ request()->routeIs('admin.users.*') ? 'bg-blue-800' : '' }}">
                    <i class="fas fa-users mr-3"></i> Users
                </a>
            </nav>
        </aside>

        <!-- Main Content -->
        <div class="flex-1 flex flex-col overflow-hidden">
            <!-- Header -->
            <header class="bg-white shadow-sm">
                <div class="flex items-center justify-between px-6 py-4">
                    <h2 class="text-xl font-semibold text-gray-800">@yield('header', 'Dashboard')</h2>
                    <div class="flex items-center">
                        <span class="mr-4">{{ auth()->user()->name }}</span>
                        <form action="{{ route('admin.logout') }}" method="POST">
                            @csrf
                            <button type="submit" class="bg-red-500 text-white px-4 py-2 rounded hover:bg-red-600">
                                <i class="fas fa-sign-out-alt mr-2"></i>Logout
                            </button>
                        </form>
                    </div>
                </div>
            </header>

            <!-- Content -->
            <main class="flex-1 overflow-x-hidden overflow-y-auto bg-gray-100 p-6">
                @if(session('success'))
                    <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-4">
                        {{ session('success') }}
                    </div>
                @endif

                @if(session('error'))
                    <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
                        {{ session('error') }}
                    </div>
                @endif

                @yield('content')
            </main>
        </div>
    </div>
</body>
</html>
