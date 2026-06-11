@extends('admin.layouts.app')

@section('title', 'Tambah Kategori')
@section('header', 'Tambah Kategori')

@section('content')
<div class="max-w-2xl bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
    <form action="{{ route('admin.categories.store') }}" method="POST" class="space-y-6">
        @csrf
        
        <div class="space-y-5">
            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1.5">Nama Kategori <span class="text-red-500">*</span></label>
                <input type="text" name="name" required 
                    class="w-full px-4 py-2.5 bg-gray-50/50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#9DD770] focus:border-[#9DD770] transition-colors text-sm placeholder:text-gray-400"
                    placeholder="Contoh: Kuliner Tradisional, Wisata Sejarah"
                    value="{{ old('name') }}">
                @error('name')
                    <p class="text-red-500 text-xs font-medium mt-1.5 flex items-center gap-1">
                        <i class="fas fa-exclamation-circle"></i> {{ $message }}
                    </p>
                @enderror
            </div>

            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1.5">Deskripsi</label>
                <textarea name="description" rows="4" 
                    class="w-full px-4 py-2.5 bg-gray-50/50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#9DD770] focus:border-[#9DD770] transition-colors text-sm placeholder:text-gray-400"
                    placeholder="Tuliskan deskripsi singkat mengenai kategori ini...">{{ old('description') }}</textarea>
                @error('description')
                    <p class="text-red-500 text-xs font-medium mt-1.5 flex items-center gap-1">
                        <i class="fas fa-exclamation-circle"></i> {{ $message }}
                    </p>
                @enderror
            </div>
        </div>

        <div class="flex items-center gap-3 pt-2 border-t border-gray-50">
            <button type="submit" 
                class="bg-[#9DD770] hover:bg-[#8bc95c] text-green-950 font-extrabold px-6 py-2.5 rounded-xl text-sm shadow-md hover:shadow-[#9DD770]/10 transition duration-200 flex items-center gap-2">
                <i class="fas fa-save"></i> Simpan Kategori
            </button>
            <a href="{{ route('admin.categories.index') }}" 
                class="bg-gray-100 hover:bg-gray-200 text-gray-600 font-semibold px-6 py-2.5 rounded-xl text-sm transition duration-150 flex items-center gap-2">
                <i class="fas fa-times"></i> Batal
            </a>
        </div>
    </form>
</div>
@endsection