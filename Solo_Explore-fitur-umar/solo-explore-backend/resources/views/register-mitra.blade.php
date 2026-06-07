<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pendaftaran Mitra - SoloExplore</title>
    <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
</head>
<body class="bg-gray-50 flex items-center justify-center min-h-screen p-4">

    <div class="bg-white p-8 rounded-2xl shadow-xl w-full max-w-md">
        <div class="text-center mb-6">
            <h2 class="text-2xl font-bold text-emerald-600">SoloExplore</h2>
            <p class="text-gray-500 text-sm mt-1">Formulir Pendaftaran Admin Wisata & Kuliner</p>
        </div>

        @if (session('success'))
            <div class="bg-emerald-50 border border-emerald-400 text-emerald-700 px-4 py-3 rounded-xl mb-4 text-sm">
                {{ session('success') }}
            </div>
        @endif

        <form action="{{ route('register.mitra.store') }}" method="POST" class="space-y-4">
            @csrf

            <div>
                <label class="block text-xs font-bold text-gray-700 tracking-wide uppercase mb-1">Nama Lengkap Pemilik</label>
                <input type="text" name="name" value="{{ old('name') }}" required 
                    class="w-full px-4 py-2 border border-gray-300 rounded-xl focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 outline-none text-sm">
                @error('name') <span class="text-red-500 text-xs">{{ $message }}</span> @enderror
            </div>

            <div>
                <label class="block text-xs font-bold text-gray-700 tracking-wide uppercase mb-1">Nama Tempat Wisata / Kuliner</label>
                <input type="text" name="business_name" value="{{ old('business_name') }}" required placeholder="Contoh: Warung Soto Gading / Pengelola Lokasi"
                    class="w-full px-4 py-2 border border-gray-300 rounded-xl focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 outline-none text-sm">
                @error('business_name') <span class="text-red-500 text-xs">{{ $message }}</span> @enderror
            </div>

            <div>
                <label class="block text-xs font-bold text-gray-700 tracking-wide uppercase mb-1">Alamat Email</label>
                <input type="email" name="email" value="{{ old('email') }}" required 
                    class="w-full px-4 py-2 border border-gray-300 rounded-xl focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 outline-none text-sm">
                @error('email') <span class="text-red-500 text-xs">{{ $message }}</span> @enderror
            </div>

            <div>
                <label class="block text-xs font-bold text-gray-700 tracking-wide uppercase mb-1">Password</label>
                <input type="password" name="password" required 
                    class="w-full px-4 py-2 border border-gray-300 rounded-xl focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 outline-none text-sm">
                @error('password') <span class="text-red-500 text-xs">{{ $message }}</span> @enderror
            </div>

            <div>
                <label class="block text-xs font-bold text-gray-700 tracking-wide uppercase mb-1">Konfirmasi Password</label>
                <input type="password" name="password_confirmation" required 
                    class="w-full px-4 py-2 border border-gray-300 rounded-xl focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 outline-none text-sm">
            </div>

            <button type="submit" 
                class="w-full bg-emerald-600 hover:bg-emerald-700 text-white font-semibold py-2 px-4 rounded-xl transition duration-200 text-sm mt-2 shadow-md shadow-emerald-100">
                Daftar Sebagai Mitra
            </button>
        </form>

        <div class="text-center mt-6 pt-4 border-t border-gray-100">
            <p class="text-xs text-gray-500">Sudah punya akun yang aktif? 
                <a href="/admin/login" class="text-emerald-600 font-bold hover:underline">Login di Sini</a>
            </p>
        </div>
    </div>

</body>
</html>