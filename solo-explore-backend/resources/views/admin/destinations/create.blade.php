@extends('admin.layouts.app')

@section('title', 'Tambah Destinasi')
@section('header', 'Tambah Destinasi Baru')

@section('content')
<div class="bg-white rounded-2xl border border-gray-100 shadow-xs p-6 md:p-8 max-w-5xl mx-auto">
    
    <div class="flex items-center gap-3 border-b border-gray-100 pb-5 mb-6">
        <div class="w-10 h-10 rounded-xl bg-green-50 flex items-center justify-center text-green-600">
            <i class="fas fa-map-marked-alt text-base"></i>
        </div>
        <div>
            <h3 class="text-base font-extrabold text-gray-800">Informasi Destinasi</h3>
            <p class="text-xs text-gray-400">Pastikan semua data bertanda asterisk (*) terisi dengan benar</p>
        </div>
    </div>

    <form action="{{ route('admin.destinations.store') }}" method="POST" enctype="multipart/form-data">
        @csrf
        
        <div class="grid grid-cols-1 md:grid-cols-2 gap-x-6 gap-y-5">
            
            <div>
                <label class="block text-xs font-bold text-gray-700 uppercase tracking-wider mb-2">Nama Destinasi *</label>
                <input type="text" name="name" required placeholder="Masukkan nama destinasi"
                    class="w-full px-4 py-2.5 border border-gray-200 rounded-2xl text-sm focus:outline-none focus:ring-2 focus:ring-[#9DD770] focus:border-transparent transition duration-150"
                    value="{{ old('name') }}">
                @error('name')<p class="text-red-500 text-xs mt-1.5 font-semibold"><i class="fas fa-exclamation-circle mr-1"></i>{{ $message }}</p>@enderror
            </div>

            <div>
                <label class="block text-xs font-bold text-gray-700 uppercase tracking-wider mb-2">Kategori *</label>
                <div class="relative">
                    <select name="category_id" required 
                        class="w-full px-4 py-2.5 border border-gray-200 rounded-2xl text-sm appearance-none focus:outline-none focus:ring-2 focus:ring-[#9DD770] focus:border-transparent transition duration-150 bg-white">
                        <option value="" class="text-gray-400">Pilih Kategori</option>
                        @foreach($categories as $category)
                            <option value="{{ $category->id }}" {{ old('category_id') == $category->id ? 'selected' : '' }}>{{ $category->name }}</option>
                        @endforeach
                    </select>
                    <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center px-4 text-gray-400">
                        <i class="fas fa-chevron-down text-xs"></i>
                    </div>
                </div>
                @error('category_id')<p class="text-red-500 text-xs mt-1.5 font-semibold"><i class="fas fa-exclamation-circle mr-1"></i>{{ $message }}</p>@enderror
            </div>

            <div class="md:col-span-2">
                <label class="block text-xs font-bold text-gray-700 uppercase tracking-wider mb-2">Deskripsi *</label>
                <textarea name="description" rows="4" required placeholder="Tuliskan deskripsi lengkap mengenai keunikan atau info dari destinasi ini..."
                    class="w-full px-4 py-2.5 border border-gray-200 rounded-2xl text-sm focus:outline-none focus:ring-2 focus:ring-[#9DD770] focus:border-transparent transition duration-150 leading-relaxed">{{ old('description') }}</textarea>
                @error('description')<p class="text-red-500 text-xs mt-1.5 font-semibold"><i class="fas fa-exclamation-circle mr-1"></i>{{ $message }}</p>@enderror
            </div>

            <div class="md:col-span-2">
                <label class="block text-xs font-bold text-gray-700 uppercase tracking-wider mb-2">Alamat Lokasi *</label>
                <div class="relative">
                    <span class="absolute inset-y-0 left-0 flex items-center pl-4 text-gray-400">
                        <i class="fas fa-map-marker-alt text-sm"></i>
                    </span>
                    <input type="text" name="location" required placeholder="Contoh: Jl. Slamet Riyadi No. 123, Surakarta"
                        class="w-full pl-10 pr-4 py-2.5 border border-gray-200 rounded-2xl text-sm focus:outline-none focus:ring-2 focus:ring-[#9DD770] focus:border-transparent transition duration-150"
                        value="{{ old('location') }}">
                </div>
                @error('location')<p class="text-red-500 text-xs mt-1.5 font-semibold"><i class="fas fa-exclamation-circle mr-1"></i>{{ $message }}</p>@enderror
            </div>

            <div class="md:col-span-2 bg-gray-50/50 border border-gray-100 rounded-2xl p-5">
                <label class="block text-xs font-bold text-gray-700 uppercase tracking-wider mb-3">Metode Input Gambar *</label>
                
                <div class="flex gap-4 mb-4">
                    <label class="flex-1 flex items-center justify-center gap-2 border border-gray-200 bg-white px-4 py-2.5 rounded-xl cursor-pointer text-xs font-bold text-gray-600 hover:bg-gray-50 transition select-none inner-radio-container">
                        <input type="radio" name="image_type" value="upload" checked class="w-4 h-4 text-green-600 focus:ring-[#9DD770]" onchange="toggleImageInput()">
                        <span><i class="fas fa-upload mr-1"></i> Upload File</span>
                    </label>
                    <label class="flex-1 flex items-center justify-center gap-2 border border-gray-200 bg-white px-4 py-2.5 rounded-xl cursor-pointer text-xs font-bold text-gray-600 hover:bg-gray-50 transition select-none inner-radio-container">
                        <input type="radio" name="image_type" value="url" class="w-4 h-4 text-green-600 focus:ring-[#9DD770]" onchange="toggleImageInput()">
                        <span><i class="fas fa-link mr-1"></i> URL Gambar</span>
                    </label>
                </div>

                <div class="relative">
                    <input type="file" name="image" id="image_upload" accept="image/*"
                        class="w-full px-4 py-2 border border-gray-200 bg-white rounded-xl text-sm file:mr-4 file:py-1.5 file:px-3 file:rounded-lg file:border-0 file:text-xs file:font-bold file:bg-gray-100 file:text-gray-700 hover:file:bg-gray-200 file:cursor-pointer">
                    
                    <input type="url" name="image_url" id="image_url" placeholder="https://domain.com/path-ke-gambar.jpg"
                        class="w-full px-4 py-2.5 border border-gray-200 bg-white rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#9DD770] focus:border-transparent hidden">
                </div>
                @error('image')<p class="text-red-500 text-xs mt-1.5 font-semibold"><i class="fas fa-exclamation-circle mr-1"></i>{{ $message }}</p>@enderror
                @error('image_url')<p class="text-red-500 text-xs mt-1.5 font-semibold"><i class="fas fa-exclamation-circle mr-1"></i>{{ $message }}</p>@enderror
            </div>

            <div>
                <label class="block text-xs font-bold text-gray-700 uppercase tracking-wider mb-2">Latitude *</label>
                <input type="text" name="latitude" required placeholder="-7.5678"
                    class="w-full px-4 py-2.5 border border-gray-200 rounded-2xl text-sm focus:outline-none focus:ring-2 focus:ring-[#9DD770] focus:border-transparent transition duration-150"
                    value="{{ old('latitude') }}">
                <p class="text-[11px] text-gray-400 mt-1.5 pl-1"><i class="fas fa-info-circle mr-1"></i>Gunakan pemisah titik (Contoh: -7.5678)</p>
                @error('latitude')<p class="text-red-500 text-xs mt-1.5 font-semibold"><i class="fas fa-exclamation-circle mr-1"></i>{{ $message }}</p>@enderror
            </div>

            <div>
                <label class="block text-xs font-bold text-gray-700 uppercase tracking-wider mb-2">Longitude *</label>
                <input type="text" name="longitude" required placeholder="110.8234"
                    class="w-full px-4 py-2.5 border border-gray-200 rounded-2xl text-sm focus:outline-none focus:ring-2 focus:ring-[#9DD770] focus:border-transparent transition duration-150"
                    value="{{ old('longitude') }}">
                <p class="text-[11px] text-gray-400 mt-1.5 pl-1"><i class="fas fa-info-circle mr-1"></i>Gunakan pemisah titik (Contoh: 110.8234)</p>
                @error('longitude')<p class="text-red-500 text-xs mt-1.5 font-semibold"><i class="fas fa-exclamation-circle mr-1"></i>{{ $message }}</p>@enderror
            </div>

            <div>
                <label class="block text-xs font-bold text-gray-700 uppercase tracking-wider mb-2">Rating (0 - 5)</label>
                <div class="relative">
                    <span class="absolute inset-y-0 left-0 flex items-center pl-4 text-amber-400">
                        <i class="fas fa-star text-sm"></i>
                    </span>
                    <input type="number" step="0.1" min="0" max="5" name="rating" placeholder="4.5"
                        class="w-full pl-10 pr-4 py-2.5 border border-gray-200 rounded-2xl text-sm focus:outline-none focus:ring-2 focus:ring-[#9DD770] focus:border-transparent transition duration-150"
                        value="{{ old('rating') }}">
                </div>
                @error('rating')<p class="text-red-500 text-xs mt-1.5 font-semibold"><i class="fas fa-exclamation-circle mr-1"></i>{{ $message }}</p>@enderror
            </div>

            <div>
                <label class="block text-xs font-bold text-gray-700 uppercase tracking-wider mb-2">Harga Tiket Masuk (Rp)</label>
                <div class="relative">
                    <span class="absolute inset-y-0 left-0 flex items-center pl-4 text-xs font-bold text-gray-400">
                        Rp
                    </span>
                    <input type="number" name="price" placeholder="Kosongkan jika gratis"
                        class="w-full pl-10 pr-4 py-2.5 border border-gray-200 rounded-2xl text-sm focus:outline-none focus:ring-2 focus:ring-[#9DD770] focus:border-transparent transition duration-150"
                        value="{{ old('price') }}">
                </div>
                @error('price')<p class="text-red-500 text-xs mt-1.5 font-semibold"><i class="fas fa-exclamation-circle mr-1"></i>{{ $message }}</p>@enderror
            </div>

            <div>
                <label class="block text-xs font-bold text-gray-700 uppercase tracking-wider mb-2">Jam Operasional</label>
                <div class="relative">
                    <span class="absolute inset-y-0 left-0 flex items-center pl-4 text-gray-400">
                        <i class="far fa-clock text-sm"></i>
                    </span>
                    <input type="text" name="opening_hours" placeholder="Contoh: 08:00 - 17:00"
                        class="w-full pl-10 pr-4 py-2.5 border border-gray-200 rounded-2xl text-sm focus:outline-none focus:ring-2 focus:ring-[#9DD770] focus:border-transparent transition duration-150"
                        value="{{ old('opening_hours') }}">
                </div>
                @error('opening_hours')<p class="text-red-500 text-xs mt-1.5 font-semibold"><i class="fas fa-exclamation-circle mr-1"></i>{{ $message }}</p>@enderror
            </div>

            <div class="md:col-span-2">
                <label class="block text-xs font-bold text-gray-700 uppercase tracking-wider mb-2">Fasilitas Tempat</label>
                <textarea name="facilities" rows="3" placeholder="Contoh: Area Parkir Luas, Mushola, Toilet Umum, Gazebo, Spot Foto"
                    class="w-full px-4 py-2.5 border border-gray-200 rounded-2xl text-sm focus:outline-none focus:ring-2 focus:ring-[#9DD770] focus:border-transparent transition duration-150 leading-relaxed">{{ old('facilities') }}</textarea>
                @error('facilities')<p class="text-red-500 text-xs mt-1.5 font-semibold"><i class="fas fa-exclamation-circle mr-1"></i>{{ $message }}</p>@enderror
            </div>
        </div>

        <div class="flex items-center justify-end gap-3 border-t border-gray-100 pt-6 mt-8">
            <a href="{{ route('admin.destinations.index') }}" 
                class="bg-gray-100 hover:bg-gray-200 text-gray-700 px-5 py-2.5 rounded-xl text-xs font-extrabold transition duration-150 flex items-center gap-2 shadow-2xs">
                <i class="fas fa-times text-sm"></i> Batal
            </a>
            <button type="submit" 
                class="bg-[#9DD770] hover:bg-[#8bc95c] text-green-950 px-6 py-2.5 rounded-xl text-xs font-extrabold transition duration-200 flex items-center gap-2 shadow-sm shadow-[#9DD770]/20 cursor-pointer">
                <i class="fas fa-save text-sm"></i> Simpan Destinasi
            </button>
        </div>
    </form>
</div>

<script>
function toggleImageInput() {
    const imageType = document.querySelector('input[name="image_type"]:checked').value;
    const uploadInput = document.getElementById('image_upload');
    const urlInput = document.getElementById('image_url');
    
    if (imageType === 'upload') {
        uploadInput.classList.remove('hidden');
        uploadInput.required = true;
        urlInput.classList.add('hidden');
        urlInput.required = false;
        urlInput.value = '';
    } else {
        uploadInput.classList.add('hidden');
        uploadInput.required = false;
        uploadInput.value = '';
        urlInput.classList.remove('hidden');
        urlInput.required = true;
    }
}
</script>
@endsection