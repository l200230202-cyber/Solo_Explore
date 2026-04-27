<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Laravel\Socialite\Facades\Socialite;

class SocialAuthController extends Controller
{
    /**
     * Redirect to Google OAuth
     */
    public function redirectToGoogle()
    {
        return Socialite::driver('google')->stateless()->redirect();
    }

    /**
     * Handle Google OAuth callback
     */
    public function handleGoogleCallback()
    {
        try {
            $googleUser = Socialite::driver('google')->stateless()->user();
            
            return $this->handleSocialLogin($googleUser, 'google');
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to authenticate with Google',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Redirect to Facebook OAuth
     */

    public function redirectToFacebook()
    {
        return Socialite::driver('facebook')->stateless()->redirect();
    }

    /**
     * Handle Facebook OAuth callback
     */
    public function handleFacebookCallback()
    {
        try {
            $facebookUser = Socialite::driver('facebook')->stateless()->user();
            
            return $this->handleSocialLogin($facebookUser, 'facebook');
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to authenticate with Facebook',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Handle social login for mobile app (token-based)
     */
    public function loginWithGoogle(Request $request)
    {
        $request->validate([
            'token' => 'required|string',
        ]);

        try {
            // Verify token with Google
            $googleUser = Socialite::driver('google')->userFromToken($request->token);
            
            return $this->handleSocialLogin($googleUser, 'google');
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid Google token',
                'error' => $e->getMessage()
            ], 401);
        }
    }

    /**
     * Handle social login for mobile app (token-based)
     */
    public function loginWithFacebook(Request $request)
    {
        $request->validate([
            'token' => 'required|string',
        ]);

        try {
            // Verify token with Facebook
            $facebookUser = Socialite::driver('facebook')->userFromToken($request->token);
            
            return $this->handleSocialLogin($facebookUser, 'facebook');
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid Facebook token',
                'error' => $e->getMessage()
            ], 401);
        }
    }

    /**
     * Common handler for social login
     */
    private function handleSocialLogin($socialUser, $provider)
    {
        // Find or create user
        $user = User::where('email', $socialUser->getEmail())->first();

        if (!$user) {
            // Create new user
            $user = User::create([
                'name' => $socialUser->getName(),
                'email' => $socialUser->getEmail(),
                'password' => Hash::make(Str::random(24)), // Random password
                'phone' => null,
                'bio' => null,
                'avatar' => $socialUser->getAvatar(),
                'level' => 1,
                'points' => 0,
                'provider' => $provider,
                'provider_id' => $socialUser->getId(),
                'email_verified_at' => now(),
            ]);
        } else {
            // Update provider info if not set
            if (!$user->provider) {
                $user->update([
                    'provider' => $provider,
                    'provider_id' => $socialUser->getId(),
                    'avatar' => $user->avatar ?? $socialUser->getAvatar(),
                ]);
            }
        }

        // Create token
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login successful',
            'data' => [
                'user' => $user,
                'token' => $token,
            ]
        ]);
    }
}
