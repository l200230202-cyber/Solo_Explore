@extends('admin.layouts.app')

@section('title', 'Destinasi')
@section('header', 'Kelola Destinasi')

@section('content')
<div class="bg-white rounded-lg shadow">
    <div class="p-6 border-b flex justify-between items-center">
        <form action="{{ route('admin.destinations.index') }}" method="GET" class="flex gap-2">
            <input type="text" name="search" placeholder="Cari destinasi..." 
                value="{{ request('search') }}"
                class="px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500">
            <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700">
                <i class="fas fa-search"></i>
            </button>
        </form>
        <a href="{{ route('admin.destinations.create') }}" class="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700">
            <i class="fas fa-plus mr-2"></i>Tambah Destinasi
        </a>
    </div>

    <div class="overflow-x-auto">
        <table class="w-full">
            <thead class="bg-gray-50">
                <tr>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Gambar</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Nama</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Lokasi</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Kategori</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Rating</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Aksi</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-200">
                @forelse($destinations as $destination)
                <tr>
                    <td class="px-6 py-4">
                        <img src="{{ $destination->image_url }}" class="w-16 h-16 rounded object-cover">
                    </td>
                    <td class="px-6 py-4">{{ $destination->name }}</td>
                    <td class="px-6 py-4">{{ $destination->location }}</td>
                    <td class="px-6 py-4">{{ $destination->category->name }}</td>
                    <td class="px-6 py-4">
                        <span class="text-yellow-500">
                            <i class="fas fa-star"></i> {{ $destination->rating ?? 'N/A' }}
                        </span>
                    </td>
                    <td class="px-6 py-4">
                        <div class="flex gap-2">
                            <a href="{{ route('admin.destinations.edit', $destination) }}" 
                                class="bg-blue-500 text-white px-3 py-1 rounded hover:bg-blue-600">
                                <i class="fas fa-edit"></i>
                            </a>
                            <form action="{{ route('admin.destinations.destroy', $destination) }}" method="POST" 
                                onsubmit="return confirm('Yakin ingin menghapus?')">
                                @csrf
                                @method('DELETE')
                                <button type="submit" class="bg-red-500 text-white px-3 py-1 rounded hover:bg-red-600">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </form>
                        </div>
                    </td>
                </tr>
                @empty
                <tr>
                    <td colspan="6" class="px-6 py-4 text-center text-gray-500">Tidak ada data</td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <div class="p-6">
        {{ $destinations->links() }}
    </div>
</div>
@endsection
