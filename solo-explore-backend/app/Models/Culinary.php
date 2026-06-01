<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Culinary extends Model
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
        'price_range',
        'since',
        'facilities',
        'highlights',
        'opening_hours',
        'is_halal',
        'is_featured',
        'views',
        'user_id',
    ];

    protected $casts = [
        'images' => 'array',
        'latitude' => 'decimal:8',
        'longitude' => 'decimal:8',
        'rating' => 'decimal:2',
        'total_reviews' => 'integer',
        'is_halal' => 'boolean',
        'is_featured' => 'boolean',
        'views' => 'integer',
    ];

    // Relationships
    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function reviews()
    {
        return $this->morphMany(Review::class, 'reviewable');
    }

    public function visits()
    {
        return $this->morphMany(Visit::class, 'visitable');
    }

    public function bookmarks()
    {
        return $this->morphMany(Bookmark::class, 'bookmarkable');
    }

    public function tripPlanItems()
    {
        return $this->morphMany(TripPlanItem::class, 'plannable');
    }

    // Scopes
    public function scopeFeatured($query)
    {
        return $query->where('is_featured', true);
    }

    public function scopeHalal($query)
    {
        return $query->where('is_halal', true);
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

    public function getImageUrlAttribute()
    {
        if (filter_var($this->image, FILTER_VALIDATE_URL)) {
            return $this->image;
        }
        return asset('storage/' . $this->image);
    }
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
