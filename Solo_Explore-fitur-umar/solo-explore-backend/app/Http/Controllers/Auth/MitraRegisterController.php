<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class MitraRegisterController extends Controller
{
    // 1. Menampilkan halaman form pendaftaran
    public function showRegistrationForm()
    {
        return view('register-mitra');
    }

    // 2. Memproses data yang dikirim dari form
    public function register(Request $request)
    {
        // Validasi input data pendaftaran
        $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
            'business_name' => ['required', 'string', 'max:255'], // Nama Wisata/Kuliner
        ]);

        // Simpan data pendaftar ke database tabel 'users'
        User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => 'admin_mitra',  // Mengunci role menjadi admin_mitra
            'is_active' => false,    // KUNCI UTAMA: Di-set false (pending) agar tidak bisa langsung login sebelum di-approve Super Admin
        ]);

        // Setelah berhasil daftar, lempar kembali ke halaman form dengan pesan sukses
        return redirect()->route('register.mitra')->with('success', 'Pendaftaran berhasil! Akun Anda sedang ditinjau oleh Super Admin. Mohon tunggu aktivasi.');
    }
}