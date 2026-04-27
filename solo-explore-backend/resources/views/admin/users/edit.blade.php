@extends('admin.layouts.app')

@section('title', 'Edit User')
@section('header', 'Edit User')

@section('content')
<div class="bg-white rounded-lg shadow p-6">
    <form action="{{ route('admin.users.update', $user) }}" method="POST">
        @csrf
        @method('PUT')
        
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
                <label class="block text-gray-700 mb-2">Nama *</label>
                <input type="text" name="name" required 
                    class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    value="{{ old('name', $user->name) }}">
                @error('name')<p class="text-red-500 text-sm mt-1">{{ $message }}</p>@enderror
            </div>

            <div>
                <label class="block text-gray-700 mb-2">Email *</label>
                <input type="email" name="email" required 
                    class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    value="{{ old('email', $user->email) }}">
                @error('email')<p class="text-red-500 text-sm mt-1">{{ $message }}</p>@enderror
            </div>

            <div>
                <label class="block text-gray-700 mb-2">Password (kosongkan jika tidak ingin mengubah)</label>
                <input type="password" name="password" 
                    class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500">
                @error('password')<p class="text-red-500 text-sm mt-1">{{ $message }}</p>@enderror
            </div>

            <div>
                <label class="block text-gray-700 mb-2">Phone</label>
                <input type="text" name="phone" 
                    class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    value="{{ old('phone', $user->phone) }}">
                @error('phone')<p class="text-red-500 text-sm mt-1">{{ $message }}</p>@enderror
            </div>

            <div class="md:col-span-2">
                <label class="flex items-center">
                    <input type="checkbox" name="is_admin" value="1" {{ $user->is_admin ? 'checked' : '' }} class="mr-2">
                    <span class="text-gray-700">Set sebagai Admin</span>
                </label>
            </div>
        </div>

        <div class="flex gap-4 mt-6">
            <button type="submit" class="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700">
                <i class="fas fa-save mr-2"></i>Update
            </button>
            <a href="{{ route('admin.users.index') }}" class="bg-gray-500 text-white px-6 py-2 rounded-lg hover:bg-gray-600">
                <i class="fas fa-times mr-2"></i>Batal
            </a>
        </div>
    </form>
</div>
@endsection
