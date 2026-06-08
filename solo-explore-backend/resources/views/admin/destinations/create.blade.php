@extends('admin.layouts.app')

@section('title', 'Tambah Destinasi')
@section('header', 'Tambah Destinasi Baru')

@section('content')
<div class="max-w-5xl mx-auto my-3">
    <div class="bg-white rounded-2xl shadow-xl border border-gray-100 overflow-hidden">
        <div class="bg-gradient-to-r from-green-600 to-emerald-700 px-8 py-5 text-white flex items-center justify-between">
            <div>
                <h3 class="text-lg font-bold">Formulir Informasi Destinasi Wisata</h3>
                <p class="text-xs text-green-100 mt-1">Pastikan informasi koordinat dan operasional terisi dengan akurat.</p>
            </div>
            <div class="p-3 bg-white/10 rounded-full text-xl">
                <i class="fas fa-map-marked-alt"></i>
            </div>
        </div>

        <form action="{{ route('admin.destinations.store') }}" method="POST" enctype="multipart/form-data" class="p-8">
            @csrf
            <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                <div class="lg:col-span-2 space-y-6">
                    <div>
                        <label class="flex items-center text-sm font-semibold text-gray-700 mb-2">
                            <i class="fas fa-monument text-green-600 mr-2 text-xs"></i> Nama Destinasi *
                        </label>
                        <input type="text" name="name" required class="w-full px-4 py-2.5 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-green-500/20 focus:border-green-600 transition-all" value="{{ old('name') }}">
                    </div>
                    <div>
                        <label class="flex items-center text-sm font-semibold text-gray-700 mb-2">
                            <i class="fas fa-align-left text-green-600 mr-2 text-xs"></i> Deskripsi Lengkap *
                        </label>
                        <textarea name="description" rows="5" required class="w-full px-4 py-2.5 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-green-500/20 focus:border-green-600 transition-all">{{ old('description') }}</textarea>
                    </div>
                    <div>
                        <label class="flex items-center text-sm font-semibold text-gray-700 mb-2">
                            <i class="fas fa-concierge-bell text-green-600 mr-2 text-xs"></i> Fasilitas Area Wisata
                        </label>
                        <textarea name="facilities" rows="3" class="w-full px-4 py-2.5 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-green-500/20 focus:border-green-600 transition-all">{{ old('facilities') }}</textarea>
                    </div>
                    <div class="bg-gray-50 p-5 rounded-2xl border border-gray-200">
                        <label class="flex items-center text-sm font-semibold text-gray-700 mb-3">
                            <i class="fas fa-camera-retro text-green-600 mr-2 text-xs"></i> Foto Utama Destinasi *
                        </label>
                        <div class="space-y-4">
                            <div class="flex p-1 bg-gray-200/80 rounded-xl max-w-xs">
                                <label class="flex-1 text-center py-2 text-xs font-bold rounded-lg cursor-pointer transition-all flex items-center justify-center gap-1.5 has-[:checked]:bg-white has-[:checked]:text-green-700 text-gray-600">
                                    <input type="radio" name="image_type" value="upload" checked class="hidden" onchange="toggleImageInput()"> File Lokal
                                </label>
                                <label class="flex-1 text-center py-2 text-xs font-bold rounded-lg cursor-pointer transition-all flex items-center justify-center gap-1.5 has-[:checked]:bg-white has-[:checked]:text-green-700 text-gray-600">
                                    <input type="radio" name="image_type" value="url" class="hidden" onchange="toggleImageInput()"> URL Link
                                </label>
                            </div>
                            <div id="wrapper_upload" class="border-2 border-dashed border-gray-300 rounded-xl p-4 text-center hover:border-green-500 transition-all bg-white">
                                <input type="file" name="image" id="image_upload" accept="image/*" class="w-full text-sm text-gray-500">
                            </div>
                            <input type="url" name="image_url" id="image_url" placeholder="https://domain.com/foto.jpg" class="w-full px-4 py-2.5 border border-gray-300 rounded-xl hidden">
                        </div>
                    </div>
                </div>
                <div class="space-y-6">
                    <div class="bg-gray-50/60 p-5 rounded-2xl border border-gray-100">
                        <label class="flex items-center text-sm font-semibold text-gray-700 mb-2">
                            <i class="fas fa-th-large text-green-600 mr-2 text-xs"></i> Klasifikasi Wisata *
                        </label>
                        <select name="category_id" required class="w-full px-4 py-2.5 border border-gray-300 bg-white rounded-xl">
                            <option value="">Pilih Kategori</option>
                            @foreach($categories as $category)
                                <option value="{{ $category->id }}">{{ $category->name }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div>
                        <label class="flex items-center text-sm font-semibold text-gray-700 mb-2">
                            <i class="fas fa-ticket-alt text-green-600 mr-2 text-xs"></i> Harga Tiket Masuk
                        </label>
                        <div class="flex rounded-xl border border-gray-300 bg-white">
                            <span class="px-3.5 inline-flex items-center bg-gray-50 text-gray-400 text-sm border-r">Rp</span>
                            <input type="number" min="0" name="price" class="w-full px-4 py-2 focus:outline-none text-sm" value="{{ old('price') }}">
                        </div>
                    </div>
                    <div>
                        <label class="flex items-center text-sm font-semibold text-gray-700 mb-2">
                            <i class="fas fa-clock text-green-600 mr-2 text-xs"></i> Jam Buka
                        </label>
                        <div class="flex items-center gap-2 bg-white p-2 border border-gray-300 rounded-xl">
                            <input type="time" id="open_time" onchange="combineOpeningHours()" class="w-full p-1.5 text-sm rounded-lg">
                            <span class="text-gray-400 text-xs font-bold">s/d</span>
                            <input type="time" id="close_time" onchange="combineOpeningHours()" class="w-full p-1.5 text-sm rounded-lg">
                        </div>
                        <input type="hidden" name="opening_hours" id="opening_hours" value="{{ old('opening_hours') }}">
                    </div>
                    <div>
                        <label class="flex items-center text-sm font-semibold text-gray-700 mb-2">
                            <i class="fas fa-map-pin text-green-600 mr-2 text-xs"></i> Lokasi Wilayah *
                        </label>
                        <input type="text" name="location" required class="w-full px-4 py-2.5 border border-gray-300 rounded-xl" value="{{ old('location') }}">
                    </div>
                    <div class="bg-gray-50/60 p-5 rounded-2xl border border-gray-100 space-y-4">
                        <span class="text-xs font-bold text-gray-500 uppercase block">Titik Geografis (Maps)</span>
                        <div>
                            <label class="block text-xs font-medium text-gray-600 mb-1">Latitude *</label>
                            <input type="text" name="latitude" required class="w-full px-3 py-2 border border-gray-300 rounded-xl text-sm" value="{{ old('latitude') }}">
                        </div>
                        <div>
                            <label class="block text-xs font-medium text-gray-600 mb-1">Longitude *</label>
                            <input type="text" name="longitude" required class="w-full px-3 py-2 border border-gray-300 rounded-xl text-sm" value="{{ old('longitude') }}">
                        </div>
                    </div>
                </div>
            </div>
            <script>
            function toggleImageInput() {
                const imageType = document.querySelector('input[name="image_type"]:checked').value;
                document.getElementById('wrapper_upload').classList.toggle('hidden', imageType !== 'upload');
                document.getElementById('image_url').classList.toggle('hidden', imageType !== 'url');
            }
            function combineOpeningHours() {
                const open = document.getElementById('open_time').value;
                const close = document.getElementById('close_time').value;
                document.getElementById('opening_hours').value = open + ' - ' + close;
            }
            </script>
            <div class="flex items-center justify-end gap-3 mt-8 pt-6 border-t border-gray-100">
                <a href="{{ route('admin.destinations.index') }}" class="px-5 py-2.5 text-sm font-semibold text-gray-600 bg-gray-100 rounded-xl">Batal</a>
                <button type="submit" class="px-6 py-2.5 text-sm font-semibold text-white bg-green-600 rounded-xl">Simpan</button>
            </div>
        </form>
    </div>
</div>
@endsection