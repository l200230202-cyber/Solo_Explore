<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Reward extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'slug',
        'description',
        'image',
        'required_points',
        'type',
        'value',
        'valid_until',
        'is_active',
    ];

    protected $casts = [
        'required_points' => 'integer',
        'valid_until' => 'date',
        'is_active' => 'boolean',
    ];

    // Relationships
    public function users()
    {
        return $this->belongsToMany(User::class, 'user_rewards')
            ->withTimestamps()
            ->withPivot(['claimed_at', 'used_at', 'status', 'code']);
    }

    // Scopes
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeAvailableFor($query, $userPoints)
    {
        return $query->where('required_points', '<=', $userPoints);
    }
}
