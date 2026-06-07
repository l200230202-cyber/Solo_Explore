<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AdminMiddleware
{
    public function handle(Request $request, Closure $next): Response
    {
        // 1. Cek apakah user sudah login atau belum
        if (!auth()->check()) {
            return redirect()->route('admin.login')->with('error', 'Please login first');
        }

        // 2. MODIFIKASI: Cek apakah role-nya sesuai (super_admin atau admin_mitra)
        if (!in_array(auth()->user()->role, ['super_admin', 'admin_mitra'])) {
            abort(403, 'Unauthorized. Admin access only.');
        }

        // 3. TAMBAHAN KEAMANAN: Jika dia admin_mitra tapi is_active masih false (0), tendang keluar
        if (!auth()->user()->is_active) {
            auth()->logout();
            return redirect()->route('admin.login')->with('error', 'Akun Anda belum diaktifkan oleh Super Admin.');
        }

        return $next($request);
    }
}