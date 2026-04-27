# API Updates - Image URL & Category Structure

## Perubahan Struktur Response

### 1. Image Field
Semua API sekarang mengirim URL lengkap untuk gambar, baik dari upload lokal maupun URL eksternal.

**Sebelum:**
```json
{
  "image": "culinaries/abc123.png"  // Path relatif
}
```

**Sekarang:**
```json
{
  "image": "http://localhost:8000/storage/culinaries/abc123.png"  // URL lengkap
}
```

Atau untuk URL eksternal:
```json
{
  "image": "https://images.unsplash.com/photo-123456"  // URL eksternal langsung
}
```

### 2. Category Structure
Category tidak lagi berupa string, tapi menggunakan relasi dengan ID dan nama.

**Sebelum (Culinary & Event):**
```json
{
  "category": "Legendaris"  // String
}
```

**Sekarang:**
```json
{
  "category_id": 3,
  "category_name": "Kuliner"
}
```

## API Endpoints yang Diupdate

### Destination API
- ✅ GET `/api/destinations` - List
- ✅ GET `/api/destinations/{slug}` - Detail
- ✅ GET `/api/destinations/category/{slug}` - By Category

**Response includes:**
- `image` - Full URL (local or external)
- `category_id` - Integer
- `category_name` - String
- `address`, `latitude`, `longitude`
- `facilities`, `highlights`, `opening_hours`

### Culinary API
- ✅ GET `/api/culinaries` - List
- ✅ GET `/api/culinaries/{slug}` - Detail

**Response includes:**
- `image` - Full URL (local or external)
- `category_id` - Integer (bukan string `category` lagi)
- `category_name` - String
- `address`, `latitude`, `longitude`
- `facilities`, `highlights`, `opening_hours`

### Event API
- ✅ GET `/api/events` - List
- ✅ GET `/api/events/{slug}` - Detail
- ✅ GET `/api/events/month/{year}/{month}` - By Month

**Response includes:**
- `image` - Full URL (local or external)
- `category_id` - Integer (bukan string `category` lagi)
- `category_name` - String
- `address`, `latitude`, `longitude`
- `rating`, `total_reviews` (field baru)

### Category API
- ✅ GET `/api/categories` - List

**No changes** - sudah konsisten dari awal.

### Search API
- ✅ GET `/api/search?q=query&type=all`

**Updated:**
- Semua hasil search menggunakan `image_url`
- Destinations, Culinaries, Events sekarang include `category_id` dan `category_name`

### Bookmark API
- ✅ GET `/api/bookmarks`

**Updated:**
- Semua bookmark items menggunakan `image_url`
- Include `category_id` dan `category_name` untuk semua types

### Visit API
- ✅ GET `/api/visits`

**Updated:**
- Semua visit items menggunakan `image_url`

### Trip Plan API
- ✅ GET `/api/trip-plans`
- ✅ GET `/api/trip-plans/{id}`

**Updated:**
- Semua plannable items menggunakan `image_url`

## Model Accessor

Semua model (Destination, Culinary, Event) sekarang memiliki accessor `image_url`:

```php
public function getImageUrlAttribute()
{
    if (filter_var($this->image, FILTER_VALIDATE_URL)) {
        return $this->image;  // URL eksternal
    }
    return asset('storage/' . $this->image);  // File lokal
}
```

Accessor ini otomatis:
- Mendeteksi apakah `image` adalah URL lengkap
- Jika ya, return langsung
- Jika tidak, tambahkan prefix `http://localhost:8000/storage/`

## Testing

### Test dengan Postman/Thunder Client:

1. **Destinations:**
   ```
   GET http://localhost:8000/api/destinations
   ```

2. **Culinaries:**
   ```
   GET http://localhost:8000/api/culinaries
   ```

3. **Events:**
   ```
   GET http://localhost:8000/api/events
   ```

4. **Search:**
   ```
   GET http://localhost:8000/api/search?q=nasi
   ```

### Expected Response Format:

```json
{
  "success": true,
  "message": "...",
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": 1,
        "category_id": 3,
        "category_name": "Kuliner",
        "name": "Nasi Kuning Yu Par",
        "image": "http://localhost:8000/storage/culinaries/abc123.png",
        "latitude": -7.5678,
        "longitude": 110.8234,
        ...
      }
    ],
    ...
  },
  "errors": null
}
```

## Flutter Integration

Di Flutter, sekarang bisa langsung load image dengan:

```dart
Image.network(culinary.image)  // Sudah URL lengkap
```

Tidak perlu lagi manual concat dengan base URL!

## Breaking Changes

⚠️ **PENTING:** Ini adalah breaking change untuk Flutter app!

**Yang perlu diupdate di Flutter:**

1. **Model Classes:**
   - Culinary model: ganti `String? category` → `int? categoryId` + `String? categoryName`
   - Event model: ganti `String? category` → `int? categoryId` + `String? categoryName`

2. **Image Loading:**
   - Field `image` sekarang sudah URL lengkap
   - Hapus manual concat base URL jika ada

3. **Category Display:**
   - Gunakan `categoryName` untuk display
   - Gunakan `categoryId` untuk filter/query

## Migration Checklist

- [x] Update Destination API controller
- [x] Update Culinary API controller
- [x] Update Event API controller
- [x] Update Search API controller
- [x] Update Bookmark API controller
- [x] Update Visit API controller
- [x] Update TripPlan API controller
- [x] Add `image_url` accessor to all models
- [x] Update database structure (category_id FK)
- [x] Update seeders
- [ ] Update Flutter models
- [ ] Update Flutter API service
- [ ] Test all screens in Flutter app
