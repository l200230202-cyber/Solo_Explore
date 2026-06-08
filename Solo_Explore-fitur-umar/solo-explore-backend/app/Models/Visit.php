<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Visit extends Model
{
    protected $fillable = [
        'user_id',
        'visitable_type',
        'visitable_id',
        'visit_date',
        'points_earned',
    ];

    protected $casts = [
        'visit_date' => 'date',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function visitable()
    {
        return $this->morphTo();
    }
}
