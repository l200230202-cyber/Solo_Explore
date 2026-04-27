<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Carbon\Carbon;

class Event extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'category_id',
        'name',
        'slug',
        'description',
        'location',
        'address',
        'latitude',
        'longitude',
        'image',
        'images',
        'rating',
        'total_reviews',
        'start_date',
        'end_date',
        'start_time',
        'end_time',
        'organizer',
        'contact',
        'ticket_price',
        'is_free',
        'is_featured',
        'views',
    ];

    protected $casts = [
        'images' => 'array',
        'start_date' => 'date',
        'end_date' => 'date',
        'is_free' => 'boolean',
        'is_featured' => 'boolean',
        'views' => 'integer',
    ];

    // Relationships
    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function bookmarks()
    {
        return $this->morphMany(Bookmark::class, 'bookmarkable');
    }

    public function reviews()
    {
        return $this->morphMany(Review::class, 'reviewable');
    }

    // Scopes
    public function scopeFeatured($query)
    {
        return $query->where('is_featured', true);
    }

    public function scopeUpcoming($query)
    {
        return $query->where('start_date', '>=', Carbon::today());
    }

    public function scopeByMonth($query, $year, $month)
    {
        return $query->whereYear('start_date', $year)
                     ->whereMonth('start_date', $month);
    }

    public function scopeByCategory($query, $category)
    {
        return $query->where('category', $category);
    }

    public function scopeSearch($query, $search)
    {
        return $query->where(function ($q) use ($search) {
            $q->where('name', 'like', "%{$search}%")
              ->orWhere('location', 'like', "%{$search}%")
              ->orWhere('description', 'like', "%{$search}%");
        });
    }

    // Methods
    public function incrementViews()
    {
        $this->increment('views');
    }

    public function updateRating()
    {
        $avgRating = $this->reviews()->avg('rating');
        $totalReviews = $this->reviews()->count();
        
        $this->update([
            'rating' => $avgRating ?? 0,
            'total_reviews' => $totalReviews,
        ]);
    }

    public function isBookmarkedBy($userId)
    {
        return $this->bookmarks()->where('user_id', $userId)->exists();
    }

    public function isUpcoming()
    {
        return $this->start_date >= Carbon::today();
    }

    public function isOngoing()
    {
        $today = Carbon::today();
        return $this->start_date <= $today && 
               ($this->end_date === null || $this->end_date >= $today);
    }

    public function getImageUrlAttribute()
    {
        if (filter_var($this->image, FILTER_VALIDATE_URL)) {
            return $this->image;
        }
        return asset('storage/' . $this->image);
    }
}
