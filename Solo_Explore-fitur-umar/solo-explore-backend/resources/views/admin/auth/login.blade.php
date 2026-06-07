<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login - Solo Explore</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gradient-to-br from-blue-500 to-blue-700 min-h-screen flex items-center justify-center">
    <div class="bg-white p-8 rounded-lg shadow-2xl w-96">
        <div class="text-center mb-6">
            <h1 class="text-3xl font-bold text-blue-900">Solo Explore</h1>
            <p class="text-gray-600">Admin Panel</p>
        </div>

        @if($errors->any())
            <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
                {{ $errors->first() }}
            </div>
        @endif

        <form action="{{ route('admin.login') }}" method="POST">
            @csrf
            <div class="mb-4">
                <label class="block text-gray-700 mb-2">Email</label>
                <input type="email" name="email" required 
                    class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="admin@soloexplore.com">
            </div>

            <div class="mb-6 relative">
                <label class="block text-gray-700 mb-2">Password</label>
                <input type="password" name="password" id="password" required 
                    class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="••••••••">
                <!-- Ikon Mata -->
                <button type="button" onclick="togglePassword()" class="absolute right-3 top-10 text-gray-500 hover:text-blue-600 focus:outline-none">
                    <svg id="eye-icon" xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path id="eye-path" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0zM2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                    </svg>
                </button>
            </div>

            <button type="submit" class="w-full bg-blue-600 text-white py-2 rounded-lg hover:bg-blue-700 transition">
                Login
            </button>
        </form>
    </div>

    <script>
        function togglePassword() {
            const passwordInput = document.getElementById('password');
            const eyePath = document.getElementById('eye-path');
            
            if (passwordInput.type === 'password') {
                passwordInput.type = 'text';
                // Ikon mata tertutup (eye-off)
                eyePath.setAttribute('d', 'M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.542-7a9.7 9.7 0 012.26-3.442m3.636 0A9.7 9.7 0 0112 5c4.478 0 8.268 2.943 9.542 7a10.05 10.05 0 01-1.042 2.142m-1.378 1.378l-7.778-7.778m0 0l-1.414 1.414m1.414-1.414l7.778 7.778m-7.778-7.778l-7.778-7.778');
            } else {
                passwordInput.type = 'password';
                // Ikon mata terbuka (eye)
                eyePath.setAttribute('d', 'M15 12a3 3 0 11-6 0 3 3 0 016 0zM2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z');
            }
        }
    </script>
</body>
</html>