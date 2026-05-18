<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Rating extends Model
{
    use HasFactory;

    // 1. Daftarkan kolom yang bisa diisi dari Flutter/API
    protected $fillable = [
        'user_id',
        'culinary_id',
        'stars',
        'comment',
        'reply',
    ];

    /**
     * Relasi ke User
     * Biar di Dashboard Admin kamu bisa panggil $rating->user->name
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Relasi ke Culinary (Warung/Menu)
     */
    public function culinary()
    {
        // Sesuaikan 'Culinary' dengan nama model warung kamu
        return $this->belongsTo(Culinary::class); 
    }
}