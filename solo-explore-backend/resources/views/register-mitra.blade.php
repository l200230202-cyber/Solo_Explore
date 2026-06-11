<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pendaftaran Mitra - SoloExplore</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-50 flex items-center justify-center min-h-screen p-4 font-sans">

    <div class="bg-white p-8 rounded-2xl shadow-xl w-full max-w-md border border-gray-100">
        <div class="text-center mb-6">
            <h2 class="text-3xl font-extrabold text-green-950 tracking-tight">SoloExplore</h2>
            <p class="text-gray-500 text-sm mt-1 font-medium">Formulir Pendaftaran Admin Wisata & Kuliner</p>
        </div>

        @if (session('success'))
            <div class="bg-green-50 border border-green-200 text-green-800 px-4 py-3 rounded-xl mb-4 text-sm font-medium shadow-xs flex items-center gap-2">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-[#9DD770] shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <span>{{ session('success') }}</span>
            </div>
        @endif

        <form action="{{ route('register.mitra.store') }}" method="POST" class="space-y-4">
            @csrf

            <div>
                <label class="block text-xs font-bold text-gray-700 tracking-wide uppercase mb-1">Nama Lengkap Pemilik</label>
                <input type="text" name="name" value="{{ old('name') }}" required 
                    class="w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#9DD770] focus:border-[#9DD770] transition-colors text-sm placeholder:text-gray-400">
                @error('name') <span class="text-red-500 text-xs mt-1 block font-medium">{{ $message }}</span> @enderror
            </div>

            <div>
                <label class="block text-xs font-bold text-gray-700 tracking-wide uppercase mb-1">Nama Tempat Wisata / Kuliner</label>
                <input type="text" name="business_name" value="{{ old('business_name') }}" required placeholder="Contoh: Warung Soto Gading / Pengelola Lokasi"
                    class="w-full px-4 py-2.5 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#9DD770] focus:border-[#9DD770] transition-colors text-sm placeholder:text-gray-400">
                @error('business_name') <span class="text-red-500 text-xs mt-1 block font-medium">{{ $message }}</span> @enderror
            </div>

            <div>
                <label class="block text-xs font-bold text-gray-700 tracking-wide uppercase mb-1">Alamat Email</label>
                <input type="email" name="email" value="{{ old('email') }}" required 
                    class="w-full px-4 py-2.5 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#9DD770] focus:border-[#9DD770] transition-colors text-sm placeholder:text-gray-400">
                @error('email') <span class="text-red-500 text-xs mt-1 block font-medium">{{ $message }}</span> @enderror
            </div>

            <div>
                <label class="block text-xs font-bold text-gray-700 tracking-wide uppercase mb-1">Password</label>
                <input type="password" name="password" required 
                    class="w-full px-4 py-2.5 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#9DD770] focus:border-[#9DD770] transition-colors text-sm placeholder:text-gray-400">
                @error('password') <span class="text-red-500 text-xs mt-1 block font-medium">{{ $message }}</span> @enderror
            </div>

            <div>
                <label class="block text-xs font-bold text-gray-700 tracking-wide uppercase mb-1">Konfirmasi Password</label>
                <input type="password" name="password_confirmation" required 
                    class="w-full px-4 py-2.5 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#9DD770] focus:border-[#9DD770] transition-colors text-sm placeholder:text-gray-400">
            </div>

            <button type="submit" 
                class="w-full bg-[#9DD770] hover:bg-[#8bc95c] text-green-950 font-extrabold py-3 px-4 rounded-xl shadow-md hover:shadow-[#9DD770]/10 transition duration-200 text-sm mt-2 focus:outline-none focus:ring-2 focus:ring-[#9DD770] focus:ring-offset-2">
                Daftar Sebagai Mitra
            </button>
        </form>

        <div class="text-center mt-6 pt-4 border-t border-gray-100">
            <p class="text-xs text-gray-500 font-medium">Sudah punya akun yang aktif? 
                <a href="/admin/login" class="text-green-700 font-extrabold hover:text-[#9DD770] hover:underline transition duration-150">Login di Sini</a>
            </p>
        </div>
    </div>

</body>
</html>