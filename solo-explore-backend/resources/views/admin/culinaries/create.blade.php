@extends('admin.layouts.app')

@section('title', 'Tambah Kuliner')
@section('header', 'Tambah Kuliner Baru')

@section('content')
<div class="max-w-5xl mx-auto my-3">
    <div class="bg-white rounded-2xl shadow-xl border border-gray-100 overflow-hidden">
        <div class="bg-gradient-to-r from-green-600 to-emerald-700 px-8 py-5 text-white flex items-center justify-between">
            <div>
                <h3 class="text-lg font-bold">Formulir Informasi Kuliner</h3>
                <p class="text-xs text-green-100 mt-1">Pastikan tanda bintang (*) diisi dengan data yang valid.</p>
            </div>
            <div class="p-3 bg-white/10 rounded-full text-xl"><i class="fas fa-store"></i></div>
        </div>

        <form action="{{ route('admin.culinaries.store') }}" method="POST" enctype="multipart/form-data" class="p-8">
            @csrf
            <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                <div class="lg:col-span-2 space-y-6">
                    <div>
                        <label class="flex items-center text-sm font-semibold text-gray-700 mb-2"><i class="fas fa-utensils text-green-600 mr-2 text-xs"></i> Nama Tempat / Kuliner *</label>
                        <input type="text" name="name" required class="w-full px-4 py-2.5 border border-gray-300 rounded-xl focus:ring-2 focus:ring-green-500/20 focus:border-green-600" value="{{ old('name') }}">
                    </div>
                    <div>
                        <label class="flex items-center text-sm font-semibold text-gray-700 mb-2"><i class="fas fa-quote-left text-green-600 mr-2 text-xs"></i> Deskripsi Warung / Menu *</label>
                        <textarea name="description" rows="5" required class="w-full px-4 py-2.5 border border-gray-300 rounded-xl focus:ring-2 focus:ring-green-500/20 focus:border-green-600">{{ old('description') }}</textarea>
                    </div>
                    <div>
                        <label class="flex items-center text-sm font-semibold text-gray-700 mb-2"><i class="fas fa-list-ul text-green-600 mr-2 text-xs"></i> Daftar Menu Populer</label>
                        <textarea name="menu_items" rows="3" class="w-full px-4 py-2.5 border border-gray-300 rounded-xl">{{ old('menu_items') }}</textarea>
                    </div>
                    <div class="bg-gray-50 p-5 rounded-2xl border border-gray-200">
                        <label class="flex items-center text-sm font-semibold text-gray-700 mb-3"><i class="fas fa-image text-green-600 mr-2 text-xs"></i> Unggah Gambar Visual *</label>
                        <div class="space-y-4">
                            <div class="flex p-1 bg-gray-200/80 rounded-xl max-w-xs">
                                <label class="flex-1 text-center py-2 text-xs font-bold rounded-lg cursor-pointer has-[:checked]:bg-white has-[:checked]:text-green-700"><input type="radio" name="image_type" value="upload" checked class="hidden" onchange="toggleImageInputCulinary()"> File Lokal</label>
                                <label class="flex-1 text-center py-2 text-xs font-bold rounded-lg cursor-pointer has-[:checked]:bg-white has-[:checked]:text-green-700"><input type="radio" name="image_type" value="url" class="hidden" onchange="toggleImageInputCulinary()"> URL Link</label>
                            </div>
                            <div id="wrapper_upload" class="border-2 border-dashed border-gray-300 rounded-xl p-4 text-center bg-white"><input type="file" name="image" id="image_upload_culinary" accept="image/*" class="w-full text-sm"></div>
                            <input type="url" name="image_url" id="image_url_culinary" placeholder="https://domain.com/foto.jpg" class="w-full px-4 py-2.5 border border-gray-300 rounded-xl hidden">
                        </div>
                    </div>
                </div>
                <div class="space-y-6">
                    <div class="bg-gray-50/60 p-5 rounded-2xl border border-gray-100">
                        <label class="flex items-center text-sm font-semibold text-gray-700 mb-2"><i class="fas fa-tags text-green-600 mr-2 text-xs"></i> Klasifikasi Kategori *</label>
                        <select name="category_id" required class="w-full px-4 py-2.5 border border-gray-300 bg-white rounded-xl">
                            <option value="">Pilih Kategori</option>
                            @foreach($categories as $category)<option value="{{ $category->id }}">{{ $category->name }}</option>@endforeach
                        </select>
                    </div>
                    <div>
                        <label class="flex items-center text-sm font-semibold text-gray-700 mb-2"><i class="fas fa-money-bill-wave text-green-600 mr-2 text-xs"></i> Estimasi Range Harga *</label>
                        <div class="grid grid-cols-2 gap-2">
                            <div class="flex rounded-xl border border-gray-300 bg-white"><span class="px-2.5 text-gray-400 text-xs border-r flex items-center">Rp</span><input type="number" id="min_price" placeholder="Min" onchange="combinePriceRange()" required class="w-full px-2 py-2 text-sm"></div>
                            <div class="flex rounded-xl border border-gray-300 bg-white"><span class="px-2.5 text-gray-400 text-xs border-r flex items-center">Rp</span><input type="number" id="max_price" placeholder="Max" onchange="combinePriceRange()" required class="w-full px-2 py-2 text-sm"></div>
                        </div>
                        <input type="hidden" name="price_range" id="price_range">
                    </div>
                    <div>
                        <label class="flex items-center text-sm font-semibold text-gray-700 mb-2"><i class="fas fa-clock text-green-600 mr-2 text-xs"></i> Jam Buka - Tutup *</label>
                        <div class="flex items-center gap-2 bg-white p-2 border border-gray-300 rounded-xl"><input type="time" id="open_time" onchange="combineOpeningHours()" required class="w-full p-1.5 text-sm"><span class="text-xs">s/d</span><input type="time" id="close_time" onchange="combineOpeningHours()" required class="w-full p-1.5 text-sm"></div>
                        <input type="hidden" name="opening_hours" id="opening_hours">
                    </div>
                    <div>
                        <label class="flex items-center text-sm font-semibold text-gray-700 mb-2"><i class="fas fa-map-marked-alt text-green-600 mr-2 text-xs"></i> Alamat Jalan *</label>
                        <input type="text" name="location" required class="w-full px-4 py-2.5 border border-gray-300 rounded-xl" value="{{ old('location') }}">
                    </div>
                    <div class="bg-gray-50/60 p-5 rounded-2xl border border-gray-100 space-y-4">
                        <span class="text-xs font-bold text-gray-500 uppercase">Koordinat Maps</span>
                        <div><label class="block text-xs font-medium text-gray-600 mb-1">Latitude *</label><input type="text" name="latitude" required class="w-full px-3 py-2 border rounded-xl text-sm"></div>
                        <div><label class="block text-xs font-medium text-gray-600 mb-1">Longitude *</label><input type="text" name="longitude" required class="w-full px-3 py-2 border rounded-xl text-sm"></div>
                    </div>
                </div>
            </div>
            <script>
            function toggleImageInputCulinary() {
                const imageType = document.querySelector('input[name="image_type"]:checked').value;
                document.getElementById('wrapper_upload').classList.toggle('hidden', imageType !== 'upload');
                document.getElementById('image_url_culinary').classList.toggle('hidden', imageType !== 'url');
            }
            function combinePriceRange() {
                const min = document.getElementById('min_price').value;
                const max = document.getElementById('max_price').value;
                document.getElementById('price_range').value = 'Rp ' + parseInt(min).toLocaleString('id-ID') + ' - Rp ' + parseInt(max).toLocaleString('id-ID');
            }
            function combineOpeningHours() {
                document.getElementById('opening_hours').value = document.getElementById('open_time').value + ' - ' + document.getElementById('close_time').value;
            }
            </script>
            <div class="flex items-center justify-end gap-3 mt-8 pt-6 border-t"><a href="{{ route('admin.culinaries.index') }}" class="px-5 py-2.5 text-sm font-semibold text-gray-600 bg-gray-100 rounded-xl">Batal</a><button type="submit" class="px-6 py-2.5 text-sm font-semibold text-white bg-green-600 rounded-xl">Simpan Data</button></div>
        </form>
    </div>
</div>
@endsection