<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AuthController extends Controller
{
    public function showLogin()
    {
        // MODIFIKASI: Cek menggunakan role baru
        if (Auth::check() && in_array(Auth::user()->role, ['super_admin', 'admin_mitra']) && Auth::user()->is_active) {
            return redirect()->route('admin.dashboard');
        }
        return view('admin.auth.login');
    }

    public function login(Request $request)
    {
        $credentials = $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        if (Auth::attempt($credentials, $request->filled('remember'))) {
            $user = Auth::user();

            // MODIFIKASI: Cek apakah user adalah super_admin atau admin_mitra
            if (in_array($user->role, ['super_admin', 'admin_mitra'])) {
                
                // KUNCI KEAMANAN: Jika dia admin_mitra tapi belum diaktifkan (is_active == false), tendang keluar
                if (!$user->is_active) {
                    Auth::logout();
                    return back()->withErrors([
                        'email' => 'Akun Anda sedang ditinjau oleh Super Admin. Mohon tunggu aktivasi.',
                    ])->onlyInput('email');
                }

                // Jika lolos semua pemeriksaan, barulah boleh masuk
                $request->session()->regenerate();
                return redirect()->intended(route('admin.dashboard'))
                    ->with('success', 'Welcome back, ' . $user->name);
            }
            
            // Jika role-nya bukan super_admin atau admin_mitra (misal user biasa)
            Auth::logout();
            return back()->withErrors([
                'email' => 'You do not have admin access.',
            ])->onlyInput('email');
        }

        return back()->withErrors([
            'email' => 'The provided credentials do not match our records.',
        ])->onlyInput('email');
    }

    public function logout(Request $request)
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();
        
        return redirect()->route('admin.login')
            ->with('success', 'You have been logged out successfully.');
    }
}