<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Category extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'slug',
        'icon',
        'description',
        'order',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'order' => 'integer',
    ];

    // --- Relationships ---

    /**
     * Relasi ke User (Siapa saja yang meminati kategori ini)
     */
    public function users()
    {
        return $this->belongsToMany(User::class, 'user_interests')
                    ->withTimestamps();
    }

    public function destinations()
    {
        return $this->hasMany(Destination::class);
    }

    public function culinaries()
    {
        return $this->hasMany(Culinary::class);
    }

    public function events()
    {
        return $this->hasMany(Event::class);
    }

    // --- Scopes ---
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeOrdered($query)
    {
        return $query->orderBy('order');
    }
}