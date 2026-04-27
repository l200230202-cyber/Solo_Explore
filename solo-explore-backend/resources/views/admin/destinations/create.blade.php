@extends('admin.layouts.app')

@section('title', 'Tambah Destinasi')
@section('header', 'Tambah Destinasi')

@section('content')
<div class="bg-white rounded-lg shadow p-6">
    <form action="{{ route('admin.destinations.store') }}" method="POST" enctype="multipart/form-data">
        @csrf
        
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
                <label class="block text-gray-700 mb-2">Nama Destinasi *</label>
                <input type="text" name="name" required 
                    class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    value="{{ old('name') }}">
                @error('name')<p class="text-red-500 text-sm mt-1">{{ $message }}</p>@enderror
            </div>

            <div>
                <label class="block text-gray-700 mb-2">Kategori *</label>
                <select name="category_id" required 
                    class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500">
                    <option value="">Pilih Kategori</option>
                    @foreach($categories as $category)
                        <option value="{{ $category->id }}">{{ $category->name }}</option>
                    @endforeach
                </select>
                @error('category_id')<p class="text-red-500 text-sm mt-1">{{ $message }}</p>@enderror
            </div>

            <div class="md:col-span-2">
                <label class="block text-gray-700 mb-2">Deskripsi *</label>
                <textarea name="description" rows="4" required 
                    class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500">{{ old('description') }}</textarea>
                @error('description')<p class="text-red-500 text-sm mt-1">{{ $message }}</p>@enderror
            </div>

            <div>
                <label class="block text-gray-700 mb-2">Lokasi *</label>
                <input type="text" name="location" required 
                    class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    value="{{ old('location') }}">
                @error('location')<p class="text-red-500 text-sm mt-1">{{ $message }}</p>@enderror
            </div>

            <div class="md:col-span-2">
                <label class="block text-gray-700 mb-2">Gambar *</label>
                <div class="space-y-3">
                    <div class="flex gap-4">
                        <label class="flex items-center">
                            <input type="radio" name="image_type" value="upload" checked class="mr-2" onchange="toggleImageInput()">
                            Upload File
                        </label>
                        <label class="flex items-center">
                            <input type="radio" name="image_type" value="url" class="mr-2" onchange="toggleImageInput()">
                            URL Gambar
                        </label>
                    </div>
                    <input type="file" name="image" id="image_upload" accept="image/*"
                        class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500">
                    <input type="url" name="image_url" id="image_url" placeholder="https://example.com/image.jpg"
                        class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 hidden">
                </div>
                @error('image')<p class="text-red-500 text-sm mt-1">{{ $message }}</p>@enderror
                @error('image_url')<p class="text-red-500 text-sm mt-1">{{ $message }}</p>@enderror
            </div>

            <div>
                <label class="block text-gray-700 mb-2">Latitude *</label>
                <input type="text" name="latitude" required placeholder="-7.5678"
                    class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    value="{{ old('latitude') }}">
                <p class="text-xs text-gray-500 mt-1">Contoh: -7.5678 (gunakan titik, bukan koma)</p>
                @error('latitude')<p class="text-red-500 text-sm mt-1">{{ $message }}</p>@enderror
            </div>

            <div>
                <label class="block text-gray-700 mb-2">Longitude *</label>
                <input type="text" name="longitude" required placeholder="110.8234"
                    class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    value="{{ old('longitude') }}">
                <p class="text-xs text-gray-500 mt-1">Contoh: 110.8234 (gunakan titik, bukan koma)</p>
                @error('longitude')<p class="text-red-500 text-sm mt-1">{{ $message }}</p>@enderror
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

            <div>
                <label class="block text-gray-700 mb-2">Rating (0-5)</label>
                <input type="number" step="0.1" min="0" max="5" name="rating" 
                    class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    value="{{ old('rating') }}">
                @error('rating')<p class="text-red-500 text-sm mt-1">{{ $message }}</p>@enderror
            </div>

            <div>
                <label class="block text-gray-700 mb-2">Harga Tiket</label>
                <input type="number" name="price" 
                    class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    value="{{ old('price') }}">
                @error('price')<p class="text-red-500 text-sm mt-1">{{ $message }}</p>@enderror
            </div>

            <div>
                <label class="block text-gray-700 mb-2">Jam Buka</label>
                <input type="text" name="opening_hours" placeholder="08:00 - 17:00"
                    class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    value="{{ old('opening_hours') }}">
                @error('opening_hours')<p class="text-red-500 text-sm mt-1">{{ $message }}</p>@enderror
            </div>

            <div class="md:col-span-2">
                <label class="block text-gray-700 mb-2">Fasilitas</label>
                <textarea name="facilities" rows="3" placeholder="Parkir, Toilet, Mushola, dll"
                    class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500">{{ old('facilities') }}</textarea>
                @error('facilities')<p class="text-red-500 text-sm mt-1">{{ $message }}</p>@enderror
            </div>
        </div>

        <div class="flex gap-4 mt-6">
            <button type="submit" class="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700">
                <i class="fas fa-save mr-2"></i>Simpan
            </button>
            <a href="{{ route('admin.destinations.index') }}" class="bg-gray-500 text-white px-6 py-2 rounded-lg hover:bg-gray-600">
                <i class="fas fa-times mr-2"></i>Batal
            </a>
        </div>
    </form>
</div>
@endsection
