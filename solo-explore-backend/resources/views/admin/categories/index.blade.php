@extends('admin.layouts.app')

@section('title', 'Kategori')
@section('header', 'Kelola Kategori')

@section('content')
<div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
    <div class="p-6 border-b border-gray-50 flex flex-col sm:flex-row justify-between items-center gap-4 bg-gray-50/30">
        <form action="{{ route('admin.categories.index') }}" method="GET" class="flex items-center gap-2 w-full sm:w-auto">
            <div class="relative w-full sm:w-64">
                <input type="text" name="search" placeholder="Cari kategori..." 
                    value="{{ request('search') }}"
                    class="w-full pl-4 pr-10 py-2 bg-white border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#9DD770] focus:border-[#9DD770] transition-colors text-sm placeholder:text-gray-400">
                @if(request('search'))
                    <a href="{{ route('admin.categories.index') }}" class="absolute right-3 top-2.5 text-gray-400 hover:text-gray-600 text-xs">
                        <i class="fas fa-times-circle"></i>
                    </a>
                @endif
            </div>
            <button type="submit" class="bg-slate-800 hover:bg-slate-900 text-white px-4 py-2 rounded-xl text-sm transition duration-150 flex items-center justify-center shrink-0 shadow-xs">
                <i class="fas fa-search"></i>
            </button>
        </form>
        
        <a href="{{ route('admin.categories.create') }}" 
            class="w-full sm:w-auto bg-[#9DD770] hover:bg-[#8bc95c] text-green-950 font-extrabold px-5 py-2 rounded-xl text-sm shadow-md hover:shadow-[#9DD770]/10 transition duration-200 flex items-center justify-center gap-2">
            <i class="fas fa-plus text-xs"></i> Tambah Kategori
        </a>
    </div>

    <div class="overflow-x-auto">
        <table class="w-full text-left border-collapse">
            <thead>
                <tr class="bg-gray-50/75 border-b border-gray-100 text-[11px] font-bold text-gray-400 uppercase tracking-wider">
                    <th class="px-6 py-4.5">Nama Kategori</th>
                    <th class="px-6 py-4.5">Deskripsi</th>
                    <th class="px-6 py-4.5 text-center">Total Destinasi</th>
                    <th class="px-6 py-4.5 text-center">Total Kuliner</th>
                    <th class="px-6 py-4.5 text-center">Total Event</th>
                    <th class="px-6 py-4.5 text-right pr-8">Aksi</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-50 text-sm text-gray-700">
                @forelse($categories as $category)
                <tr class="hover:bg-gray-50/40 transition duration-100 group">
                    <td class="px-6 py-4 font-bold text-gray-800 group-hover:text-[#9DD770] transition duration-150">
                        {{ $category->name }}
                    </td>
                    <td class="px-6 py-4 max-w-xs truncate text-gray-500">
                        {{ $category->description ?? '-' }}
                    </td>
                    <td class="px-6 py-4 text-center">
                        <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-semibold bg-green-50 text-green-700">
                            {{ $category->destinations_count }}
                        </span>
                    </td>
                    <td class="px-6 py-4 text-center">
                        <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-semibold bg-orange-50 text-orange-700">
                            {{ $category->culinaries_count }}
                        </span>
                    </td>
                    <td class="px-6 py-4 text-center">
                        <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-semibold bg-purple-50 text-purple-700">
                            {{ $category->events_count }}
                        </span>
                    </td>
                    <td class="px-6 py-4 text-right pr-8">
                        <div class="flex items-center justify-end gap-2">
                            <a href="{{ route('admin.categories.edit', $category) }}" 
                                class="p-2 bg-blue-50 text-blue-600 rounded-xl hover:bg-blue-100 transition duration-150 text-xs font-medium"
                                title="Edit Kategori">
                                <i class="fas fa-edit"></i>
                            </a>
                            <form action="{{ route('admin.categories.destroy', $category) }}" method="POST" 
                                onsubmit="return confirm('Apakah Anda yakin ingin menghapus kategori &quot;{{ $category->name }}&quot;?')">
                                @csrf
                                @method('DELETE')
                                <button type="submit" 
                                    class="p-2 bg-red-50 text-red-600 rounded-xl hover:bg-red-100 transition duration-150 text-xs font-medium"
                                    title="Hapus Kategori">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </form>
                        </div>
                    </td>
                </tr>
                @empty
                <tr>
                    <td colspan="6" class="px-6 py-12 text-center text-gray-400 font-medium">
                        <div class="flex flex-col items-center justify-center gap-2">
                            <i class="fas fa-folder-open text-3xl text-gray-200"></i>
                            <span>Tidak ada data kategori yang ditemukan.</span>
                        </div>
                    </td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    @if($categories->hasPages())
        <div class="p-6 border-t border-gray-50 bg-gray-50/20">
            {{ $categories->links() }}
        </div>
    @endif
</div>
@endsection