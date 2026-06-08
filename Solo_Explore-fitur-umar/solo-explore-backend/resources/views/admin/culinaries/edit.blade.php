@extends('admin.layouts.app')

@section('title', 'Edit Kuliner')
@section('header', 'Edit Kuliner')

@section('content')
<div class="bg-white rounded-lg shadow p-6">
    <form action="{{ route('admin.culinaries.update', $culinary) }}" method="POST" enctype="multipart/form-data">
        @csrf
        @method('PUT')
        
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
                <label class="block text-gray-700 mb-2">Nama Kuliner *</label>
                <input type="text" name="name" required 
                    class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                    value="{{ old('name', $culinary->name) }}">
                @error('name')<p class="text-red-500 text-sm mt-1">{{ $message }}</p>@enderror
            </div>

            <div>
                <label class="block text-gray-700 mb-2">Kategori *</label>
                <select name="category_id" required 
                    class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500">
                    @foreach($categories as $category)
                        <option value="{{ $category->id }}" {{ $culinary->category_id == $category->id ? 'selected' : '' }}>
                            {{ $category->name }}
                        </option>
                    @endforeach
                </select>
                @error('category_id')<p class="text-red-500 text-sm mt-1">{{ $message }}</p>@enderror
            </div>

            <div class="md:col-span-2">
                <label class="block text-gray-700 mb-2">Deskripsi *</label>
                <textarea name="description" rows="4" required 
                    class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500">{{ old('description', $culinary->description) }}</textarea>
                @error('description')<p class="text-red-500 text-sm mt-1">{{ $message }}</p>@enderror
            </div>

            <div>
                <label class="block text-gray-700 mb-2">Lokasi *</label>
                <input type="text" name="location" required 
                    class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                    value="{{ old('location', $culinary->location) }}">
                @error('location')<p class="text-red-500 text-sm mt-1">{{ $message }}</p>@enderror
            </div>

            <div class="md:col-span-2">
                <label class="block text-gray-700 mb-2">Gambar</label>
                <div class="space-y-3">
                    <div class="flex gap-4">
                        <label class="flex items-center">
                            <input type="radio" name="image_type" value="keep" checked class="mr-2" onchange="toggleImageInputCulinaryEdit()">
                            Tetap Gunakan Gambar Lama
                        </label>
                        <label class="flex items-center">
                            <input type="radio" name="image_type" value="upload" class="mr-2" onchange="toggleImageInputCulinaryEdit()">
                            Upload File Baru
                        </label>
                        <label class="flex items-center">
                            <input type="radio" name="image_type" value="url" class="mr-2" onchange="toggleImageInputCulinaryEdit()">
                            URL Gambar Baru
                        </label>
                    </div>
                    <input type="file" name="image" id="image_upload_culinary_edit" accept="image/*"
                        class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500 hidden">
                    <input type="url" name="image_url" id="image_url_culinary_edit" placeholder="https://example.com/image.jpg"
                        class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500 hidden">
                    @if($culinary->image)
                        <img src="{{ $culinary->image_url }}" class="mt-2 w-32 h-32 object-cover rounded">
                    @endif
                </div>
                @error('image')<p class="text-red-500 text-sm mt-1">{{ $message }}</p>@enderror
                @error('image_url')<p class="text-red-500 text-sm mt-1">{{ $message }}</p>@enderror
            </div>

            <div>
                <label class="block text-gray-700 mb-2">Latitude *</label>
                <input type="text" name="latitude" required placeholder="-7.5678"
                    class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                    value="{{ old('latitude', $culinary->latitude) }}">
                <p class="text-xs text-gray-500 mt-1">Contoh: -7.5678 (gunakan titik, bukan koma)</p>
                @error('latitude')<p class="text-red-500 text-sm mt-1">{{ $message }}</p>@enderror
            </div>

            <div>
                <label class="block text-gray-700 mb-2">Longitude *</label>
                <input type="text" name="longitude" required placeholder="110.8234"
                    class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                    value="{{ old('longitude', $culinary->longitude) }}">
                <p class="text-xs text-gray-500 mt-1">Contoh: 110.8234 (gunakan titik, bukan koma)</p>
                @error('longitude')<p class="text-red-500 text-sm mt-1">{{ $message }}</p>@enderror
            </div>

            <script>
            function toggleImageInputCulinaryEdit() {
                const imageType = document.querySelector('input[name="image_type"]:checked').value;
                const uploadInput = document.getElementById('image_upload_culinary_edit');
                const urlInput = document.getElementById('image_url_culinary_edit');
                
                if (imageType === 'upload') {
                    uploadInput.classList.remove('hidden');
                    urlInput.classList.add('hidden');
                    urlInput.value = '';
                } else if (imageType === 'url') {
                    uploadInput.classList.add('hidden');
                    uploadInput.value = '';
                    urlInput.classList.remove('hidden');
                } else {
                    uploadInput.classList.add('hidden');
                    uploadInput.value = '';
                    urlInput.classList.add('hidden');
                    urlInput.value = '';
                }
            }
            </script>

            <div>
                <label class="block text-gray-700 mb-2">Rating (0-5)</label>
                <input type="number" step="0.1" min="0" max="5" name="rating" 
                    class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                    value="{{ old('rating', $culinary->rating) }}">
                @error('rating')<p class="text-red-500 text-sm mt-1">{{ $message }}</p>@enderror
            </div>

            <!-- 🟢 PERUBAHAN: Memisahkan Kembali Teks Angka Range Harga Murni -->
            @php
                // Menghilangkan simbol "Rp" dan titik pemisah ribuan agar tersisa angka murni
                $cleanPrice = str_replace(['Rp', '.', ' '], '', $culinary->price_range);
                $prices = explode('-', $cleanPrice);
                $min_val = isset($prices[0]) ? trim($prices[0]) : '';
                $max_val = isset($prices[1]) ? trim($prices[1]) : '';
            @endphp
            <div>
                <label class="block text-gray-700 mb-2">Range Harga *</label>
                <div class="flex items-center gap-2">
                    <div class="flex rounded-lg shadow-sm w-full">
                        <span class="px-3 inline-flex items-center rounded-l-lg border border-r-0 border-gray-300 bg-gray-50 text-gray-500 text-xs">Rp</span>
                        <input type="number" id="min_price_edit" placeholder="Min" value="{{ $min_val }}" onchange="combinePriceRangeEdit()" required
                            class="w-full px-3 py-2 border rounded-r-lg focus:outline-none focus:ring-2 focus:ring-green-500">
                    </div>
                    <span class="text-gray-500">-</span>
                    <div class="flex rounded-lg shadow-sm w-full">
                        <span class="px-3 inline-flex items-center rounded-l-lg border border-r-0 border-gray-300 bg-gray-50 text-gray-500 text-xs">Rp</span>
                        <input type="number" id="max_price_edit" placeholder="Max" value="{{ $max_val }}" onchange="combinePriceRangeEdit()" required
                            class="w-full px-3 py-2 border rounded-r-lg focus:outline-none focus:ring-2 focus:ring-green-500">
                    </div>
                </div>
                <input type="hidden" name="price_range" id="price_range_edit" value="{{ old('price_range', $culinary->price_range) }}">
                @error('price_range')<p class="text-red-500 text-sm mt-1">{{ $message }}</p>@enderror
            </div>

            <!-- 🟢 PERUBAHAN: Memisahkan Kembali Isian Picker Jam Buka Kuliner -->
            @php
                $hours = explode(' - ', $culinary->opening_hours);
                $open_val = isset($hours[0]) ? trim($hours[0]) : '';
                $close_val = isset($hours[1]) ? trim($hours[1]) : '';
            @endphp
            <div>
                <label class="block text-gray-700 mb-2">Jam Buka *</label>
                <div class="flex items-center gap-2">
                    <input type="time" id="open_time_edit" value="{{ $open_val }}" onchange="combineOpeningHoursEdit()" required
                        class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500">
                    <span class="text-gray-500">s/d</span>
                    <input type="time" id="close_time_edit" value="{{ $close_val }}" onchange="combineOpeningHoursEdit()" required
                        class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500">
                </div>
                <input type="hidden" name="opening_hours" id="opening_hours_edit" value="{{ old('opening_hours', $culinary->opening_hours) }}">
                @error('opening_hours')<p class="text-red-500 text-sm mt-1">{{ $message }}</p>@enderror
            </div>

            <script>
            function combinePriceRangeEdit() {
                const min = document.getElementById('min_price_edit').value;
                const max = document.getElementById('max_price_edit').value;
                if(min && max) {
                    document.getElementById('price_range_edit').value = 'Rp ' + parseInt(min).toLocaleString('id-ID') + ' - Rp ' + parseInt(max).toLocaleString('id-ID');
                }
            }

            function combineOpeningHoursEdit() {
                const open = document.getElementById('open_time_edit').value;
                const close = document.getElementById('close_time_edit').value;
                if (open && close) {
                    document.getElementById('opening_hours_edit').value = open + ' - ' + close;
                }
            }
            </script>

            <div class="md:col-span-2">
                <label class="block text-gray-700 mb-2">Menu Items</label>
                <textarea name="menu_items" rows="3"
                    class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500">{{ old('menu_items', $culinary->menu_items) }}</textarea>
                @error('menu_items')<p class="text-red-500 text-sm mt-1">{{ $message }}</p>@enderror
            </div>
        </div>

        <div class="flex gap-4 mt-6">
            <button type="submit" class="bg-green-600 text-white px-6 py-2 rounded-lg hover:bg-green-700">
                <i class="fas fa-save mr-2"></i>Update
            </button>
            <a href="{{ route('admin.culinaries.index') }}" class="bg-gray-500 text-white px-6 py-2 rounded-lg hover:bg-gray-600">
                <i class="fas fa-times mr-2"></i>Batal
            </a>
        </div>
    </form>
</div>
@endsection