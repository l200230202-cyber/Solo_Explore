@extends('admin.layouts.app')

@section('title', 'Destinasi')
@section('header', 'Kelola Destinasi')

@section('content')
<div class="max-w-7xl mx-auto">
    <div class="flex flex-col md:flex-row justify-between items-center mb-6 gap-4">
        <form action="{{ route('admin.destinations.index') }}" method="GET" class="relative w-full md:w-96">
            <input type="text" name="search" placeholder="Cari destinasi atau lokasi..." 
                value="{{ request('search') }}"
                class="w-full pl-10 pr-4 py-2.5 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-green-500/20 focus:border-green-600 transition-all">
            <i class="fas fa-search absolute left-3.5 top-3.5 text-gray-400"></i>
        </form>
        
        <a href="{{ route('admin.destinations.create') }}" class="bg-gradient-to-r from-green-600 to-emerald-700 text-white px-5 py-2.5 rounded-xl hover:shadow-lg hover:shadow-green-700/20 transition-all flex items-center gap-2 font-semibold text-sm">
            <i class="fas fa-plus"></i> Tambah Destinasi
        </a>
    </div>

    <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-left">
                <thead class="bg-gray-50 border-b border-gray-100">
                    <tr>
                        <th class="px-6 py-4 text-xs font-bold text-gray-500 uppercase">Gambar</th>
                        <th class="px-6 py-4 text-xs font-bold text-gray-500 uppercase">Destinasi</th>
                        <th class="px-6 py-4 text-xs font-bold text-gray-500 uppercase">Kategori</th>
                        <th class="px-6 py-4 text-xs font-bold text-gray-500 uppercase text-right">Aksi</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-50">
                    @forelse($destinations as $destination)
                    <tr class="hover:bg-gray-50/50 transition-colors">
                        <td class="px-6 py-4">
                            <img src="{{ $destination->image_url }}" class="w-14 h-14 rounded-xl object-cover shadow-sm">
                        </td>
                        <td class="px-6 py-4">
                            <div class="font-bold text-gray-800">{{ $destination->name }}</div>
                            <div class="text-xs text-gray-500 flex items-center gap-1 mt-0.5">
                                <i class="fas fa-map-marker-alt"></i> {{ $destination->location }}
                            </div>
                        </td>
                        <td class="px-6 py-4">
                            <span class="px-3 py-1 bg-green-50 text-green-700 rounded-lg text-xs font-semibold border border-green-100">
                                {{ $destination->category->name }}
                            </span>
                        </td>
                        <td class="px-6 py-4">
                            <div class="flex items-center justify-end gap-2">
                                <a href="{{ route('admin.destinations.edit', $destination) }}" 
                                    class="p-2 text-blue-600 hover:bg-blue-50 rounded-lg transition-all" title="Edit">
                                    <i class="fas fa-edit"></i>
                                </a>
                                <form action="{{ route('admin.destinations.destroy', $destination) }}" method="POST" 
                                    onsubmit="return confirm('Yakin ingin menghapus?')">
                                    @csrf @method('DELETE')
                                    <button type="submit" class="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-all" title="Hapus">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="4" class="px-6 py-12 text-center text-gray-400">
                            <i class="fas fa-box-open text-4xl mb-3 opacity-20"></i>
                            <p>Belum ada data destinasi.</p>
                        </td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        <div class="px-6 py-4 border-t border-gray-100 bg-gray-50">
            {{ $destinations->links() }}
        </div>
    </div>
</div>
@endsection