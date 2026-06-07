<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class TripPlan extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id',
        'name',
        'title',
        'description',
        'start_date',
        'end_date',
        'total_days',
        'budget',
        'status',
        'ai_generated',
        'ai_itinerary',
    ];

    protected $casts = [
        'start_date' => 'date',
        'end_date' => 'date',
        'total_days' => 'integer',
        'budget' => 'decimal:2',
        'ai_generated' => 'boolean',
    ];

    // Relationships
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function items()
    {
        return $this->hasMany(TripPlanItem::class)->orderBy('day_number')->orderBy('order');
    }

    // Scopes
    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }

    public function scopeDraft($query)
    {
        return $query->where('status', 'draft');
    }

    // Methods
    public function calculateTotalDays()
    {
        if ($this->start_date && $this->end_date) {
            $this->total_days = $this->start_date->diffInDays($this->end_date) + 1;
            $this->save();
        }
    }
}
