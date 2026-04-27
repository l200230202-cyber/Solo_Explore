<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable, SoftDeletes;

    protected $fillable = [
        'name',
        'email',
        'password',
        'phone',
        'avatar',
        'bio',
        'level',
        'points',
        'total_destinations',
        'is_verified',
        'is_admin',
        'provider',
        'provider_id',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
        'is_verified' => 'boolean',
        'level' => 'integer',
        'points' => 'integer',
        'total_destinations' => 'integer',
    ];

    // Relationships
    public function visits()
    {
        return $this->hasMany(Visit::class);
    }

    public function reviews()
    {
        return $this->hasMany(Review::class);
    }

    public function bookmarks()
    {
        return $this->hasMany(Bookmark::class);
    }

    public function badges()
    {
        return $this->belongsToMany(Badge::class, 'user_badges')
            ->withTimestamps()
            ->withPivot('earned_at');
    }

    public function rewards()
    {
        return $this->belongsToMany(Reward::class, 'user_rewards')
            ->withTimestamps()
            ->withPivot(['claimed_at', 'used_at', 'status', 'code']);
    }

    public function tripPlans()
    {
        return $this->hasMany(TripPlan::class);
    }

    public function notifications()
    {
        return $this->hasMany(Notification::class);
    }

    // Scopes
    public function scopeVerified($query)
    {
        return $query->where('is_verified', true);
    }

    // Methods
    public function addPoints(int $points): void
    {
        $this->increment('points', $points);
        $this->updateLevel();
    }

    public function updateLevel(): void
    {
        $level = match(true) {
            $this->points >= 2000 => 5,
            $this->points >= 1500 => 4,
            $this->points >= 1000 => 3,
            $this->points >= 500 => 2,
            default => 1,
        };
        
        $this->update(['level' => $level]);
    }

    public function getLevelTitleAttribute(): string
    {
        return match($this->level) {
            5 => 'Master Explorer',
            4 => 'Veteran Traveler',
            3 => 'Experienced Wanderer',
            2 => 'Active Explorer',
            default => 'Beginner Traveler',
        };
    }
}
