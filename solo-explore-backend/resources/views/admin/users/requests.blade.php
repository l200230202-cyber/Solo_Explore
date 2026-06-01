@extends('admin.layouts.app')

@section('title', 'Permintaan Aktivasi Mitra')
@section('header', 'Permintaan Aktivasi Mitra')

@section('content')
<div class="bg-white rounded-lg shadow-sm p-6">
    <div class="flex justify-between items-center mb-4">
        <h3 class="text-lg font-medium text-gray-900">Daftar Pendaftar Mitra Baru</h3>
        <a href="{{ route('admin.users.index') }}" class="text-blue-600 hover:underline text-sm">
            <i class="fas fa-arrow-left mr-1"></i> Kembali ke Manajemen User
        </a>
    </div>

    <div class="overflow-x-auto">
        <table class="w-full text-left border-collapse">
            <thead>
                <tr class="bg-gray-100 text-gray-700 text-sm font-semibold">
                    <th class="p-3 border-b">Nama Pemilik</th>
                    <th class="p-3 border-b">Email</th>
                    <th class="p-3 border-b">Tanggal Daftar</th>
                    <th class="p-3 border-b text-center">Aksi</th>
                </tr>
            </thead>
            <tbody class="text-gray-600 text-sm">
                @forelse($requests as $request)
                    <tr class="hover:bg-gray-50">
                        <td class="p-3 border-b font-medium text-gray-900">{{ $request->name }}</td>
                        <td class="p-3 border-b">{{ $request->email }}</td>
                        <td class="p-3 border-b">{{ $request->created_at->format('d M Y H:i') }} WIB</td>
                        <td class="p-3 border-b flex justify-center space-x-2">
                            <form action="{{ route('admin.users.approve', $request->id) }}" method="POST" onsubmit="return confirm('Aktifkan akun mitra ini?')">
                                @csrf
                                <button type="submit" class="bg-green-500 text-white px-3 py-1.5 rounded hover:bg-green-600 font-semibold text-xs flex items-center">
                                    <i class="fas fa-check mr-1"></i> Setujui
                                </button>
                            </form>

                            <form action="{{ route('admin.users.reject', $request->id) }}" method="POST" onsubmit="return confirm('Tolak dan hapus pendaftaran ini?')">
                                @csrf
                                <button type="submit" class="bg-red-500 text-white px-3 py-1.5 rounded hover:bg-red-600 font-semibold text-xs flex items-center">
                                    <i class="fas fa-times mr-1"></i> Tolak
                                </button>
                            </form>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="4" class="p-4 text-center text-gray-500 italic">
                            Tidak ada permintaan aktivasi mitra baru saat ini.
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <div class="mt-4">
        {{ $requests->links() }}
    </div>
</div>
@endsection