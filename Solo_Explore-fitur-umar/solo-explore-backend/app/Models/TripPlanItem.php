<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TripPlanItem extends Model
{
    use HasFactory;

    protected $fillable = [
        'trip_plan_id',
        'plannable_id',
        'plannable_type',
        'day_number',
        'time',
        'order',
        'notes',
    ];

    protected $casts = [
        'day_number' => 'integer',
        'order' => 'integer',
    ];

    // Relationships
    public function tripPlan()
    {
        return $this->belongsTo(TripPlan::class);
    }

    public function plannable()
    {
        return $this->morphTo();
    }
}
