<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Culinary;
use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class CulinaryController extends Controller
{
    public function index(Request $request)
    {
        $user = auth()->user();
        $query = Culinary::with('category');
        
        // --- MODIFIKASI: Filter kuliner jika yang login bukan super_admin ---
        if ($user->role !== 'super_admin') {
            $query->where('user_id', $user->id);
        }
        // --------------------------------------------------------------------
        
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('description', 'like', "%{$search}%");
            });
        }
        
        $culinaries = $query->latest()->paginate(10);
        return view('admin.culinaries.index', compact('culinaries'));
    }

    public function create()
    {
        $categories = Category::all();
        return view('admin.culinaries.create', compact('categories'));
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
            'price_range' => 'nullable|string',
            'opening_hours' => 'nullable|string',
            'facilities' => 'nullable|string',
        ]);

        // --- MODIFIKASI: Otomatis ikat data kuliner dengan ID akun penginput ---
        $validated['user_id'] = auth()->id();
        // ----------------------------------------------------------------------

        // Generate slug
        $validated['slug'] = \Illuminate\Support\Str::slug($validated['name']);
        $originalSlug = $validated['slug'];
        $count = 1;
        while (Culinary::where('slug', $validated['slug'])->exists()) {
            $validated['slug'] = $originalSlug . '-' . $count;
            $count++;
        }

        // Handle image
        if ($request->hasFile('image')) {
            $validated['image'] = $request->file('image')->store('culinaries', 'public');
        } elseif ($request->filled('image_url')) {
            $validated['image'] = $request->image_url;
        }
        unset($validated['image_url']);

        Culinary::create($validated);
        return redirect()->route('admin.culinaries.index')->with('success', 'Kuliner berhasil ditambahkan!');
    }

    public function edit(Culinary $culinary)
    {
        // --- MODIFIKASI: Proteksi bypass URL ID kuliner ---
        if (auth()->user()->role !== 'super_admin' && $culinary->user_id !== auth()->id()) {
            abort(403, 'Anda tidak memiliki akses untuk mengubah data kuliner ini.');
        }
        // ---------------------------------------------------

        $categories = Category::all();
        return view('admin.culinaries.edit', compact('culinary', 'categories'));
    }

    public function update(Request $request, Culinary $culinary)
    {
        // --- MODIFIKASI: Proteksi bypass URL ID kuliner ---
        if (auth()->user()->role !== 'super_admin' && $culinary->user_id !== auth()->id()) {
            abort(403, 'Anda tidak memiliki akses untuk mengubah data kuliner ini.');
        }
        // ---------------------------------------------------

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
            'price_range' => 'nullable|string',
            'opening_hours' => 'nullable|string',
            'facilities' => 'nullable|string',
        ]);

        // Update slug if name changed
        if ($validated['name'] !== $culinary->name) {
            $validated['slug'] = \Illuminate\Support\Str::slug($validated['name']);
            $originalSlug = $validated['slug'];
            $count = 1;
            while (Culinary::where('slug', $validated['slug'])->where('id', '!=', $culinary->id)->exists()) {
                $validated['slug'] = $originalSlug . '-' . $count;
                $count++;
            }
        }

        // Handle image
        if ($request->hasFile('image')) {
            if ($culinary->image && !filter_var($culinary->image, FILTER_VALIDATE_URL)) {
                Storage::disk('public')->delete($culinary->image);
            }
            $validated['image'] = $request->file('image')->store('culinaries', 'public');
        } elseif ($request->filled('image_url')) {
            if ($culinary->image && !filter_var($culinary->image, FILTER_VALIDATE_URL)) {
                Storage::disk('public')->delete($culinary->image);
            }
            $validated['image'] = $request->image_url;
        }
        unset($validated['image_url']);

        $culinary->update($validated);
        return redirect()->route('admin.culinaries.index')->with('success', 'Kuliner berhasil diupdate!');
    }

    public function destroy(Culinary $culinary)
    {
        // --- MODIFIKASI: Proteksi bypass URL ID kuliner ---
        if (auth()->user()->role !== 'super_admin' && $culinary->user_id !== auth()->id()) {
            abort(403, 'Anda tidak memiliki akses untuk menghapus data kuliner ini.');
        }
        // ---------------------------------------------------

        if ($culinary->image && !filter_var($culinary->image, FILTER_VALIDATE_URL)) {
            Storage::disk('public')->delete($culinary->image);
        }
        $culinary->delete();
        return redirect()->route('admin.culinaries.index')->with('success', 'Kuliner berhasil dihapus!');
    }
}