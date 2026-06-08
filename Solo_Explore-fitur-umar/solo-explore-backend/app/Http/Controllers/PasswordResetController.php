<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Password;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;
use App\Models\User;
use Illuminate\Auth\Events\PasswordReset;

class PasswordResetController extends Controller
{
    /**
     * Send password reset link to email
     */
    public function sendResetLink(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Format email tidak valid',
                'errors' => $validator->errors()
            ], 422);
        }

        // Trim and lowercase email for consistency
        $email = strtolower(trim($request->email));

        // Check if user exists
        $user = User::whereRaw('LOWER(TRIM(email)) = ?', [$email])->first();
        
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Email tidak terdaftar. Pastikan email yang Anda masukkan sudah terdaftar.',
                'errors' => ['email' => ['Email tidak ditemukan di sistem']]
            ], 404);
        }

        // Send password reset link using the actual email from database
        $status = Password::sendResetLink(
            ['email' => $user->email]
        );

        if ($status === Password::RESET_LINK_SENT) {
            return response()->json([
                'success' => true,
                'message' => 'Link reset password telah dikirim ke email Anda. Silakan cek inbox atau folder spam.',
            ]);
        }

        return response()->json([
            'success' => false,
            'message' => 'Gagal mengirim link reset password. Silakan coba lagi.',
        ], 500);
    }

    /**
     * Reset password with token
     */
    public function resetPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'token' => 'required',
            'email' => 'required|email',
            'password' => 'required|min:8|confirmed',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        $status = Password::reset(
            $request->only('email', 'password', 'password_confirmation', 'token'),
            function (User $user, string $password) {
                $user->forceFill([
                    'password' => Hash::make($password)
                ])->setRememberToken(Str::random(60));

                $user->save();

                event(new PasswordReset($user));
            }
        );

        if ($status === Password::PASSWORD_RESET) {
            return response()->json([
                'success' => true,
                'message' => 'Password berhasil direset. Silakan login dengan password baru',
            ]);
        }

        return response()->json([
            'success' => false,
            'message' => $status === Password::INVALID_TOKEN 
                ? 'Token tidak valid atau sudah kadaluarsa' 
                : 'Gagal reset password',
        ], 400);
    }

    /**
     * Verify reset token (optional - untuk cek token valid atau tidak)
     */
    public function verifyToken(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'token' => 'required',
            'email' => 'required|email',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Email tidak ditemukan',
            ], 404);
        }

        // Check if token exists and not expired
        $tokenData = \DB::table('password_reset_tokens')
            ->where('email', $request->email)
            ->first();

        if (!$tokenData) {
            return response()->json([
                'success' => false,
                'message' => 'Token tidak valid',
            ], 400);
        }

        // Check if token matches
        if (!Hash::check($request->token, $tokenData->token)) {
            return response()->json([
                'success' => false,
                'message' => 'Token tidak valid',
            ], 400);
        }

        // Check if token expired (60 minutes)
        $createdAt = \Carbon\Carbon::parse($tokenData->created_at);
        if ($createdAt->addMinutes(60)->isPast()) {
            return response()->json([
                'success' => false,
                'message' => 'Token sudah kadaluarsa',
            ], 400);
        }

        return response()->json([
            'success' => true,
            'message' => 'Token valid',
        ]);
    }
}
