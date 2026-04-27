<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Event;
use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class EventController extends Controller
{
    public function index(Request $request)
    {
        $query = Event::with('category');
        
        if ($request->has('search')) {
            $search = $request->search;
            $query->where('name', 'like', "%{$search}%")
                  ->orWhere('description', 'like', "%{$search}%");
        }
        
        $events = $query->latest()->paginate(10);
        return view('admin.events.index', compact('events'));
    }

    public function create()
    {
        $categories = Category::all();
        return view('admin.events.create', compact('categories'));
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
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
            'organizer' => 'nullable|string',
        ]);

        // Generate slug
        $validated['slug'] = \Illuminate\Support\Str::slug($validated['name']);
        $originalSlug = $validated['slug'];
        $count = 1;
        while (Event::where('slug', $validated['slug'])->exists()) {
            $validated['slug'] = $originalSlug . '-' . $count;
            $count++;
        }

        // Handle image
        if ($request->hasFile('image')) {
            $validated['image'] = $request->file('image')->store('events', 'public');
        } elseif ($request->filled('image_url')) {
            $validated['image'] = $request->image_url;
        }
        unset($validated['image_url']);

        Event::create($validated);
        return redirect()->route('admin.events.index')->with('success', 'Event berhasil ditambahkan!');
    }

    public function edit(Event $event)
    {
        $categories = Category::all();
        return view('admin.events.edit', compact('event', 'categories'));
    }

    public function update(Request $request, Event $event)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'required|string',
            'location' => 'required|string',
            'latitude' => 'required|numeric|between:-90,90',
            'longitude' => 'required|numeric|between:-180,180',
            'category_id' => 'required|exists:categories,id',
            'image' => 'nullable|image|mimes:jpeg,png,jpg|max:2048',
            'image_url' => 'nullable|url',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
            'organizer' => 'nullable|string',
        ]);

        // Update slug if name changed
        if ($validated['name'] !== $event->name) {
            $validated['slug'] = \Illuminate\Support\Str::slug($validated['name']);
            $originalSlug = $validated['slug'];
            $count = 1;
            while (Event::where('slug', $validated['slug'])->where('id', '!=', $event->id)->exists()) {
                $validated['slug'] = $originalSlug . '-' . $count;
                $count++;
            }
        }

        // Handle image
        if ($request->hasFile('image')) {
            if ($event->image && !filter_var($event->image, FILTER_VALIDATE_URL)) {
                Storage::disk('public')->delete($event->image);
            }
            $validated['image'] = $request->file('image')->store('events', 'public');
        } elseif ($request->filled('image_url')) {
            if ($event->image && !filter_var($event->image, FILTER_VALIDATE_URL)) {
                Storage::disk('public')->delete($event->image);
            }
            $validated['image'] = $request->image_url;
        }
        unset($validated['image_url']);

        $event->update($validated);
        return redirect()->route('admin.events.index')->with('success', 'Event berhasil diupdate!');
    }

    public function destroy(Event $event)
    {
        if ($event->image && !filter_var($event->image, FILTER_VALIDATE_URL)) {
            Storage::disk('public')->delete($event->image);
        }
        $event->delete();
        return redirect()->route('admin.events.index')->with('success', 'Event berhasil dihapus!');
    }
}
