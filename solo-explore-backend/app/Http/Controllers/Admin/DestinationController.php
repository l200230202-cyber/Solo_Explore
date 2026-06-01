<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Destination;
use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class DestinationController extends Controller
{
    public function index(Request $request)
    {
        $user = auth()->user();
        $query = Destination::with('category');
        
        // --- MODIFIKASI: Filter data berdasarkan Role ---
        if ($user->role !== 'super_admin') {
            $query->where('user_id', $user->id);
        }
        // ------------------------------------------------

        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('description', 'like', "%{$search}%");
            });
        }
        
        $destinations = $query->latest()->paginate(10);
        return view('admin.destinations.index', compact('destinations'));
    }

    public function create()
    {
        $categories = Category::all();
        return view('admin.destinations.create', compact('categories'));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'required|string',
            'location' => 'required|string',
            'latitude' => 'required|numeric|between:-90,90',
            'longitude' => 'required|numeric|between:-180,180',
            'category_id' => 'required|exists:categories,id',
            'image' => 'required_without:image_url|nullable|image|mimes:jpeg,png,jpg|max:2048',
            'image_url' => 'required_without:image|nullable|url',
            'rating' => 'nullable|numeric|min:0|max:5',
            'price' => 'nullable|numeric|min:0',
            'opening_hours' => 'nullable|string',
            'facilities' => 'nullable|string',
        ]);

        // --- MODIFIKASI: Otomatis isi user_id dari user yang sedang login ---
        $validated['user_id'] = auth()->id();
        // ------------------------------------------------------------------

        // Generate slug from name
        $validated['slug'] = \Illuminate\Support\Str::slug($validated['name']);
        
        // Make slug unique if already exists
        $originalSlug = $validated['slug'];
        $count = 1;
        while (Destination::where('slug', $validated['slug'])->exists()) {
            $validated['slug'] = $originalSlug . '-' . $count;
            $count++;
        }

        // Handle image upload or URL
        if ($request->hasFile('image')) {
            $validated['image'] = $request->file('image')->store('destinations', 'public');
        } elseif ($request->filled('image_url')) {
            $validated['image'] = $request->image_url;
        }

        // Remove image_url from validated data
        unset($validated['image_url']);

        Destination::create($validated);
        return redirect()->route('admin.destinations.index')->with('success', 'Destinasi berhasil ditambahkan!');
    }

    public function edit(Destination $destination)
    {
        // Opsional: Mencegah admin_mitra lain mengedit paksa lewat URL id orang lain
        if (auth()->user()->role !== 'super_admin' && $destination->user_id !== auth()->id()) {
            abort(403, 'Anda tidak memiliki akses untuk mengedit destinasi ini.');
        }

        $categories = Category::all();
        return view('admin.destinations.edit', compact('destination', 'categories'));
    }

    public function update(Request $request, Destination $destination)
    {
        // Opsional: Mencegah admin_mitra lain mengupdate paksa lewat URL id orang lain
        if (auth()->user()->role !== 'super_admin' && $destination->user_id !== auth()->id()) {
            abort(403, 'Anda tidak memiliki akses untuk mengubah destinasi ini.');
        }

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'required|string',
            'location' => 'required|string',
            'latitude' => 'required|numeric|between:-90,90',
            'longitude' => 'required|numeric|between:-180,180',
            'category_id' => 'required|exists:categories,id',
            'image' => 'nullable|image|mimes:jpeg,png,jpg|max:2048',
            'image_url' => 'nullable|url',
            'rating' => 'nullable|numeric|min:0|max:5',
            'price' => 'nullable|numeric|min:0',
            'opening_hours' => 'nullable|string',
            'facilities' => 'nullable|string',
        ]);

        // Update slug if name changed
        if ($validated['name'] !== $destination->name) {
            $validated['slug'] = \Illuminate\Support\Str::slug($validated['name']);
            
            // Make slug unique if already exists (excluding current destination)
            $originalSlug = $validated['slug'];
            $count = 1;
            while (Destination::where('slug', $validated['slug'])->where('id', '!=', $destination->id)->exists()) {
                $validated['slug'] = $originalSlug . '-' . $count;
                $count++;
            }
        }

        // Handle image upload or URL
        if ($request->hasFile('image')) {
            // Delete old image if it's a local file
            if ($destination->image && !filter_var($destination->image, FILTER_VALIDATE_URL)) {
                Storage::disk('public')->delete($destination->image);
            }
            $validated['image'] = $request->file('image')->store('destinations', 'public');
        } elseif ($request->filled('image_url')) {
            // Delete old image if it's a local file
            if ($destination->image && !filter_var($destination->image, FILTER_VALIDATE_URL)) {
                Storage::disk('public')->delete($destination->image);
            }
            $validated['image'] = $request->image_url;
        }

        // Remove image_url from validated data
        unset($validated['image_url']);

        $destination->update($validated);
        return redirect()->route('admin.destinations.index')->with('success', 'Destinasi berhasil diupdate!');
    }

    public function destroy(Destination $destination)
    {
        // Opsional: Mencegah admin_mitra lain menghapus paksa lewat URL id orang lain
        if (auth()->user()->role !== 'super_admin' && $destination->user_id !== auth()->id()) {
            abort(403, 'Anda tidak memiliki akses untuk menghapus destinasi ini.');
        }

        // Only delete if it's a local file, not external URL
        if ($destination->image && !filter_var($destination->image, FILTER_VALIDATE_URL)) {
            Storage::disk('public')->delete($destination->image);
        }
        $destination->delete();
        return redirect()->route('admin.destinations.index')->with('success', 'Destinasi berhasil dihapus!');
    }
}