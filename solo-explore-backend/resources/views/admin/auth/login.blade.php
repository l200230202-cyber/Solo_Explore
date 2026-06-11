<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login - Solo Explore</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-[#9DD770] min-h-screen flex items-center justify-center font-sans">
    
    <div class="bg-white p-8 rounded-2xl shadow-xl w-96 border border-green-200/40">
        <div class="text-center mb-6">
            <h1 class="text-3xl font-extrabold text-green-950 tracking-tight">Solo Explore</h1>
            <p class="text-xs font-bold text-green-700 uppercase tracking-wider mt-1">Admin Panel</p>
        </div>

        @if($errors->any())
            <div class="bg-red-50 border border-red-100 text-red-700 px-4 py-3 rounded-xl mb-4 text-sm font-medium flex items-center gap-2">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-red-400 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
                </svg>
                <span>{{ $errors->first() }}</span>
            </div>
        @endif

        <form action="{{ route('admin.login') }}" method="POST" class="space-y-5">
            @csrf
            
            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1">Email</label>
                <input type="email" name="email" required 
                    class="w-full px-4 py-2.5 bg-gray-50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#9DD770] focus:border-[#9DD770] transition-colors placeholder:text-gray-400 text-sm"
                    placeholder="admin@soloexplore.com">
            </div>

            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1">Password</label>
                <input type="password" name="password" required 
                    class="w-full px-4 py-2.5 bg-gray-50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#9DD770] focus:border-[#9DD770] transition-colors placeholder:text-gray-400 text-sm"
                    placeholder="••••••••">
            </div>

            <button type="submit" class="w-full bg-[#9DD770] text-green-950 py-3 rounded-xl font-extrabold shadow-md hover:bg-[#8bc95c] hover:shadow-[#9DD770]/20 transition duration-200 focus:outline-none focus:ring-2 focus:ring-[#9DD770] focus:ring-offset-2 mt-2 text-sm">
                Login
            </button>
        </form>
    </div>
</body>
</html>