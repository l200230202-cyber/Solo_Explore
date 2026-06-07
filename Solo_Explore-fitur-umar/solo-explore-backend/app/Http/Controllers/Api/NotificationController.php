<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Notification;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    /**
     * Get all notifications for authenticated user
     */
    public function index(Request $request)
    {
        $notifications = $request->user()
            ->notifications()
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $notifications->items(),
            'unread_count' => $request->user()->notifications()->where('is_read', false)->count(),
            'pagination' => [
                'current_page' => $notifications->currentPage(),
                'last_page' => $notifications->lastPage(),
                'per_page' => $notifications->perPage(),
                'total' => $notifications->total(),
            ],
        ]);
    }

    /**
     * Get unread notifications count
     */
    public function unreadCount(Request $request)
    {
        $count = $request->user()
            ->notifications()
            ->where('is_read', false)
            ->count();

        return response()->json([
            'success' => true,
            'count' => $count,
        ]);
    }

    /**
     * Mark notification as read
     */
    public function markAsRead(Request $request, $id)
    {
        $notification = $request->user()
            ->notifications()
            ->findOrFail($id);

        $notification->markAsRead();

        return response()->json([
            'success' => true,
            'message' => 'Notifikasi ditandai sudah dibaca',
        ]);
    }

    /**
     * Mark all notifications as read
     */
    public function markAllAsRead(Request $request)
    {
        $request->user()
            ->notifications()
            ->where('is_read', false)
            ->update([
                'is_read' => true,
                'read_at' => now(),
            ]);

        return response()->json([
            'success' => true,
            'message' => 'Semua notifikasi ditandai sudah dibaca',
        ]);
    }

    /**
     * Delete notification
     */
    public function destroy(Request $request, $id)
    {
        $notification = $request->user()
            ->notifications()
            ->findOrFail($id);

        $notification->delete();

        return response()->json([
            'success' => true,
            'message' => 'Notifikasi berhasil dihapus',
        ]);
    }

    /**
     * Delete all read notifications
     */
    public function deleteAllRead(Request $request)
    {
        $request->user()
            ->notifications()
            ->where('is_read', true)
            ->delete();

        return response()->json([
            'success' => true,
            'message' => 'Semua notifikasi yang sudah dibaca berhasil dihapus',
        ]);
    }

    /**
     * Create notification (for testing or admin)
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'user_id' => 'required|exists:users,id',
            'type' => 'required|string',
            'title' => 'required|string|max:255',
            'message' => 'required|string',
            'data' => 'nullable|array',
        ]);

        $notification = Notification::create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Notifikasi berhasil dibuat',
            'data' => $notification,
        ], 201);
    }
}
