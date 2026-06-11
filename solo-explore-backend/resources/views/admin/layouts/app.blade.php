<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'Admin Panel') - Solo Explore</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="bg-gray-50/70 font-sans antialiased text-slate-800">
    <div class="flex h-screen overflow-hidden">
        
        <aside class="w-64 bg-slate-900 text-slate-300 flex flex-col z-20 shadow-xl border-r border-slate-950">
            <div class="p-5 border-b border-slate-950 bg-slate-950/40">
                <h1 class="text-2xl font-extrabold text-white tracking-tight flex items-center gap-2">
                    <span class="w-2 h-6 bg-[#9DD770] rounded-full shadow-sm shadow-[#9DD770]/50"></span>Solo Explore
                </h1>
                <p class="text-[10px] font-bold text-slate-500 uppercase tracking-widest mt-1 pl-3.5">Admin Dashboard</p>
            </div>
            
            <nav class="flex-1 overflow-y-auto px-3 py-4 space-y-1 custom-scrollbar">
                
                <a href="{{ route('admin.dashboard') }}" 
                    class="flex items-center px-4 py-3 rounded-xl text-sm font-semibold transition-all duration-200 group
                    {{ request()->routeIs('admin.dashboard') ? 'bg-[#9DD770] text-slate-950 font-extrabold shadow-md shadow-[#9DD770]/10' : 'hover:bg-slate-800/60 hover:text-white' }}">
                    <i class="fas fa-home mr-3 text-base transition-colors duration-150 {{ request()->routeIs('admin.dashboard') ? 'text-slate-950' : 'text-slate-400 group-hover:text-[#9DD770]' }}"></i> 
                    Dashboard
                </a>
                
                <a href="{{ route('admin.destinations.index') }}" 
                    class="flex items-center px-4 py-3 rounded-xl text-sm font-semibold transition-all duration-200 group
                    {{ request()->routeIs('admin.destinations.*') ? 'bg-[#9DD770] text-slate-950 font-extrabold shadow-md shadow-[#9DD770]/10' : 'hover:bg-slate-800/60 hover:text-white' }}">
                    <i class="fas fa-map-marker-alt mr-3 text-base transition-colors duration-150 {{ request()->routeIs('admin.destinations.*') ? 'text-slate-950' : 'text-slate-400 group-hover:text-[#9DD770]' }}"></i> 
                    Destinasi
                </a>
                
                <a href="{{ route('admin.culinaries.index') }}" 
                    class="flex items-center px-4 py-3 rounded-xl text-sm font-semibold transition-all duration-200 group
                    {{ request()->routeIs('admin.culinaries.*') ? 'bg-[#9DD770] text-slate-950 font-extrabold shadow-md shadow-[#9DD770]/10' : 'hover:bg-slate-800/60 hover:text-white' }}">
                    <i class="fas fa-utensils mr-3 text-base transition-colors duration-150 {{ request()->routeIs('admin.culinaries.*') ? 'text-slate-950' : 'text-slate-400 group-hover:text-[#9DD770]' }}"></i> 
                    Kuliner
                </a>

                @if(auth()->user()->role === 'super_admin')
                    <div class="pt-5 pb-1 px-4">
                        <p class="text-[10px] font-extrabold text-slate-500 uppercase tracking-widest">Super Admin Kontrol</p>
                    </div>

                    <a href="{{ route('admin.events.index') }}" 
                        class="flex items-center px-4 py-3 rounded-xl text-sm font-semibold transition-all duration-200 group
                        {{ request()->routeIs('admin.events.*') ? 'bg-[#9DD770] text-slate-950 font-extrabold shadow-md shadow-[#9DD770]/10' : 'hover:bg-slate-800/60 hover:text-white' }}">
                        <i class="fas fa-calendar mr-3 text-base transition-colors duration-150 {{ request()->routeIs('admin.events.*') ? 'text-slate-950' : 'text-slate-400 group-hover:text-[#9DD770]' }}"></i> 
                        Event
                    </a>
                    
                    <a href="{{ route('admin.categories.index') }}" 
                        class="flex items-center px-4 py-3 rounded-xl text-sm font-semibold transition-all duration-200 group
                        {{ request()->routeIs('admin.categories.*') ? 'bg-[#9DD770] text-slate-950 font-extrabold shadow-md shadow-[#9DD770]/10' : 'hover:bg-slate-800/60 hover:text-white' }}">
                        <i class="fas fa-tags mr-3 text-base transition-colors duration-150 {{ request()->routeIs('admin.categories.*') ? 'text-slate-950' : 'text-slate-400 group-hover:text-[#9DD770]' }}"></i> 
                        Kategori
                    </a>

                    <a href="{{ route('admin.users.requests') }}" 
                        class="flex items-center px-4 py-3 rounded-xl text-sm font-semibold transition-all duration-200 group
                        {{ request()->routeIs('admin.users.requests') ? 'bg-[#9DD770] text-slate-950 font-extrabold shadow-md shadow-[#9DD770]/10' : 'hover:bg-slate-800/60 hover:text-white' }}">
                        <i class="fas fa-user-clock mr-3 text-base transition-colors duration-150 {{ request()->routeIs('admin.users.requests') ? 'text-slate-950' : 'text-slate-400 group-hover:text-[#9DD770]' }}"></i> 
                        Permintaan Mitra
                    </a>
                    
                    <a href="{{ route('admin.users.index') }}" 
                        class="flex items-center px-4 py-3 rounded-xl text-sm font-semibold transition-all duration-200 group
                        {{ request()->routeIs('admin.users.*') && !request()->routeIs('admin.users.requests') ? 'bg-[#9DD770] text-slate-950 font-extrabold shadow-md shadow-[#9DD770]/10' : 'hover:bg-slate-800/60 hover:text-white' }}">
                        <i class="fas fa-users mr-3 text-base transition-colors duration-150 {{ request()->routeIs('admin.users.*') && !request()->routeIs('admin.users.requests') ? 'text-slate-950' : 'text-slate-400 group-hover:text-[#9DD770]' }}"></i> 
                        Manajemen User
                    </a>
                @endif
            </nav>
        </aside>

        <div class="flex-1 flex flex-col overflow-hidden">
            <header class="bg-white border-b border-gray-100 z-10">
                <div class="flex items-center justify-between px-8 py-4">
                    <h2 class="text-xl font-extrabold text-gray-800 tracking-tight">@yield('header', 'Dashboard')</h2>
                    
                    <div class="flex items-center gap-4">
                        <span class="text-xs font-bold text-gray-600 bg-gray-50 px-3.5 py-2 rounded-xl border border-gray-100 flex items-center shadow-2xs">
                            <i class="far fa-user mr-2.5 text-gray-400 text-sm"></i>{{ auth()->user()->name }}
                        </span>
                        
                        <form action="{{ route('admin.logout') }}" method="POST">
                            @csrf
                            <button type="submit" class="bg-red-50 hover:bg-red-100 text-red-600 px-4 py-2 rounded-xl text-xs font-extrabold transition duration-150 flex items-center gap-2 border border-red-100/50 shadow-2xs cursor-pointer">
                                <i class="fas fa-sign-out-alt text-sm"></i> Keluar
                            </button>
                        </form>
                    </div>
                </div>
            </header>

            <main class="flex-1 overflow-x-hidden overflow-y-auto bg-gray-50/40 p-8">
                
                @if(session('success'))
                    <div class="bg-emerald-50 border border-emerald-100 text-emerald-900 px-4 py-3.5 rounded-2xl mb-6 text-sm font-semibold shadow-xs flex items-center gap-3">
                        <div class="w-6 h-6 rounded-lg bg-[#9DD770]/20 flex items-center justify-center text-emerald-700 shrink-0">
                            <i class="fas fa-check-circle text-sm"></i>
                        </div>
                        <span>{{ session('success') }}</span>
                    </div>
                @endif

                @if(session('error'))
                    <div class="bg-red-50 border border-red-100 text-red-900 px-4 py-3.5 rounded-2xl mb-6 text-sm font-semibold shadow-xs flex items-center gap-3">
                        <div class="w-6 h-6 rounded-lg bg-red-100 flex items-center justify-center text-red-600 shrink-0">
                            <i class="fas fa-exclamation-triangle text-xs"></i>
                        </div>
                        <span>{{ session('error') }}</span>
                    </div>
                @endif

                @yield('content')
            </main>
        </div>
    </div>
</body>
</html>