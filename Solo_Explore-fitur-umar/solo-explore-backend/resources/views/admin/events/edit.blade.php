@extends('admin.layouts.app')

@section('title', 'Edit Event')
@section('header', 'Edit Event')

@section('content')
<div class="bg-white rounded-lg shadow p-6">
    <form action="{{ route('admin.events.update', $event) }}" method="POST" enctype="multipart/form-data">
        @csrf
        @method('PUT')
        
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
                <label class="block text-gray-700 mb-2">Nama Event *</label>
                <input type="text" name="name" required 
                    class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    value="{{ old('name', $event->name) }}">
                @error('name')<p class="text-red-500 text-sm mt-1">{{ $message }}</p>@enderror
            </div>

            <div>
                <label class="block text-gray-700 mb-2">Kategori *</label>
                <select name="category_id" required 
                    class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500">
                    @foreach($categories as $category)
                        <option value="{{ $category->id }}" {{ $event->category_id == $category->id ? 'selected' : '' }}>
                            {{ $category->name }}
                        </option>
                    @endforeach
                </select>
                @error('category_id')<p class="text-red-500 text-sm mt-1">{{ $message }}</p>@enderror
            </div>

            <div class="md:col-span-2">
                <label class="block text-gray-700 mb-2">Deskripsi *</label>
                <textarea name="description" rows="4" required 
                    class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500">{{ old('description', $event->description) }}</textarea>
                @error('description')<p class="text-red-500 text-sm mt-1">{{ $message }}</p>@enderror
            </div>

            <div>
                <label class="block text-gray-700 mb-2">Lokasi *</label>
                <input type="text" name="location" required 
                    class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    value="{{ old('location', $event->location) }}">
                @error('location')<p class="text-red-500 text-sm mt-1">{{ $message }}</p>@enderror
            </div>

            <div class="md:col-span-2">
                <label class="block text-gray-700 mb-2">Gambar</label>
                <div class="space-y-3">
                    <div class="flex gap-4">
                        <label class="flex items-center">
                            <input type="radio" name="image_type" value="keep" checked class="mr-2" onchange="toggleImageInputEventEdit()">
                            Tetap Gunakan Gambar Lama
                        </label>
                        <label class="flex items-center">
                            <input type="radio" name="image_type" value="upload" class="mr-2" onchange="toggleImageInputEventEdit()">
                            Upload File Baru
                        </label>
                        <label class="flex items-center">
                            <input type="radio" name="image_type" value="url" class="mr-2" onchange="toggleImageInputEventEdit()">
                            URL Gambar Baru
                        </label>
                    </div>
                    <input type="file" name="image" id="image_upload_event_edit" accept="image/*"
                        class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 hidden">
                    <input type="url" name="image_url" id="image_url_event_edit" placeholder="https://example.com/image.jpg"
                        class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 hidden">
                    @if($event->image)
                        <img src="{{ $event->image_url }}" class="mt-2 w-32 h-32 object-cover rounded">
                    @endif
                </div>
                @error('image')<p class="text-red-500 text-sm mt-1">{{ $message }}</p>@enderror
                @error('image_url')<p class="text-red-500 text-sm mt-1">{{ $message }}</p>@enderror
            </div>

            <div>
                <label class="block text-gray-700 mb-2">Tanggal Mulai *</label>
                <input type="date" name="start_date" required 
                    class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    value="{{ old('start_date', $event->start_date) }}">
                @error('start_date')<p class="text-red-500 text-sm mt-1">{{ $message }}</p>@enderror
            </div>

            <div>
                <label class="block text-gray-700 mb-2">Tanggal Selesai *</label>
                <input type="date" name="end_date" required 
                    class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    value="{{ old('end_date', $event->end_date) }}">
                @error('end_date')<p class="text-red-500 text-sm mt-1">{{ $message }}</p>@enderror
            </div>

            <div>
                <label class="block text-gray-700 mb-2">Latitude *</label>
                <input type="text" name="latitude" required placeholder="-7.5678"
                    class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    value="{{ old('latitude', $event->latitude) }}">
                <p class="text-xs text-gray-500 mt-1">Contoh: -7.5678 (gunakan titik, bukan koma)</p>
                @error('latitude')<p class="text-red-500 text-sm mt-1">{{ $message }}</p>@enderror
            </div>

            <div>
                <label class="block text-gray-700 mb-2">Longitude *</label>
                <input type="text" name="longitude" required placeholder="110.8234"
                    class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    value="{{ old('longitude', $event->longitude) }}">
                <p class="text-xs text-gray-500 mt-1">Contoh: 110.8234 (gunakan titik, bukan koma)</p>
                @error('longitude')<p class="text-red-500 text-sm mt-1">{{ $message }}</p>@enderror
            </div>

            <script>
            function toggleImageInputEventEdit() {
                const imageType = document.querySelector('input[name="image_type"]:checked').value;
                const uploadInput = document.getElementById('image_upload_event_edit');
                const urlInput = document.getElementById('image_url_event_edit');
                
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
                <label class="block text-gray-700 mb-2">Harga Tiket</label>
                <input type="number" name="price" 
                    class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    value="{{ old('price', $event->price) }}">
                @error('price')<p class="text-red-500 text-sm mt-1">{{ $message }}</p>@enderror
            </div>

            <div>
                <label class="block text-gray-700 mb-2">Penyelenggara</label>
                <input type="text" name="organizer" 
                    class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    value="{{ old('organizer', $event->organizer) }}">
                @error('organizer')<p class="text-red-500 text-sm mt-1">{{ $message }}</p>@enderror
            </div>
        </div>

        <div class="flex gap-4 mt-6">
            <button type="submit" class="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700">
                <i class="fas fa-save mr-2"></i>Update
            </button>
            <a href="{{ route('admin.events.index') }}" class="bg-gray-500 text-white px-6 py-2 rounded-lg hover:bg-gray-600">
                <i class="fas fa-times mr-2"></i>Batal
            </a>
        </div>
    </form>
</div>
@endsection
