<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Badge extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'slug',
        'description',
        'icon',
        'requirement',
        'required_points',
    ];

    protected $casts = [
        'required_points' => 'integer',
    ];

    // Relationships
    public function users()
    {
        return $this->belongsToMany(User::class, 'user_badges')
            ->withTimestamps()
            ->withPivot('earned_at');
    }
}
