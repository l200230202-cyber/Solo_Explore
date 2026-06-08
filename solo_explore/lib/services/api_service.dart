import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/destination.dart';
import '../models/category.dart';
import '../models/culinary.dart';
import '../models/event.dart';

class ApiService {
  // Gunakan 10.0.2.2 untuk Android emulator, atau IP lokal komputer untuk device fisik
  // Contoh device fisik: 'http://192.168.1.x:8000/api'
  static const String baseUrl = 'http://192.168.0.3:8000/api';
  String? _token;

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    _token = token;
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _token = null;
  }

  Future<bool> hasToken() async {
    if (_token != null) return true; // Jika token sudah ter-load di memori

    // Jika belum ter-load, coba ambil dari SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    return _token != null && _token!.isNotEmpty;
  }

  Map<String, String> _headers({bool needsAuth = false}) {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (needsAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // Auth
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String phone,
    List<int> categoryIds,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers(),
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'phone': phone,
        'category_ids': categoryIds,
      }),
    );

    final data = jsonDecode(response.body);
    if (data['success']) {
      await _saveToken(data['data']['token']);
      return {'success': true, 'user': User.fromJson(data['data']['user'])};
    }
    return {'success': false, 'message': data['message']};
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);
    if (data['success']) {
      await _saveToken(data['data']['token']);
      return {'success': true, 'user': User.fromJson(data['data']['user'])};
    }
    return {'success': false, 'message': data['message']};
  }

  Future<void> logout() async {
    await _loadToken();
    await http.post(
      Uri.parse('$baseUrl/auth/logout'),
      headers: _headers(needsAuth: true),
    );
    await clearToken();
  }

  // Social Login
  Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google'),
        headers: _headers(),
        body: jsonEncode({'token': idToken}),
      );
      final data = jsonDecode(response.body);
      if (data['success']) {
        await _saveToken(data['data']['token']);
        return {'success': true, 'user': User.fromJson(data['data']['user'])};
      }
      return {'success': false, 'message': data['message']};
    } catch (e) {
      return {'success': false, 'message': 'Failed to login with Google: $e'};
    }
  }

  Future<Map<String, dynamic>> loginWithFacebook(String accessToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/facebook'),
        headers: _headers(),
        body: jsonEncode({'token': accessToken}),
      );
      final data = jsonDecode(response.body);
      if (data['success']) {
        await _saveToken(data['data']['token']);
        return {'success': true, 'user': User.fromJson(data['data']['user'])};
      }
      return {'success': false, 'message': data['message']};
    } catch (e) {
      return {'success': false, 'message': 'Failed to login with Facebook: $e'};
    }
  }

  // Password Reset
  Future<bool> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/password/forgot'),
        headers: _headers(),
        body: jsonEncode({'email': email}),
      );
      final data = jsonDecode(response.body);
      return data['success'] ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> resetPassword(
    String token,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/password/reset'),
        headers: _headers(),
        body: jsonEncode({
          'token': token,
          'email': email,
          'password': password,
          'password_confirmation': password,
        }),
      );
      final data = jsonDecode(response.body);
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? 'Terjadi kesalahan',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  Future<bool> verifyResetToken(String token, String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/password/verify-token'),
        headers: _headers(),
        body: jsonEncode({'token': token, 'email': email}),
      );
      final data = jsonDecode(response.body);
      return data['success'] ?? false;
    } catch (e) {
      return false;
    }
  }

  // Categories
  Future<List<Category>> getCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/categories'),
      headers: _headers(),
    );
    final data = jsonDecode(response.body);
    if (data['success']) {
      return (data['data'] as List).map((e) => Category.fromJson(e)).toList();
    }
    return [];
  }

  // =========================================================================
  // Destinations
  // =========================================================================

  Future<List<Destination>> getDestinations({
    String? category,
    bool? featured,
  }) async {
    try {
      await _loadToken();
      var url = '$baseUrl/destinations?per_page=100&';
      if (category != null) url += 'category=$category&';
      if (featured != null) url += 'featured=$featured&';

      final response = await http.get(
        Uri.parse(url),
        headers: _headers(needsAuth: _token != null),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        // ✅ FIXED: Menghindari linter warning & null crash
        final items = data['data']['data'] ?? data['data'];
        if (items is List) {
          return items.map((e) => Destination.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error getDestinations: $e');
      return [];
    }
  }

  Future<Destination?> getDestinationDetail(String slug) async {
    try {
      await _loadToken();
      final response = await http.get(
        Uri.parse('$baseUrl/destinations/$slug'),
        headers: _headers(needsAuth: _token != null),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        // ✅ FIXED: Pengaman data null
        return Destination.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Error getDestinationDetail: $e');
      return null;
    }
  }

  // =========================================================================
  // Culinaries
  // =========================================================================

  Future<List<Culinary>> getCulinaries({bool? featured}) async {
    try {
      await _loadToken();
      var url = '$baseUrl/culinaries?per_page=100&';
      if (featured != null) url += 'featured=$featured';

      final response = await http.get(
        Uri.parse(url),
        headers: _headers(needsAuth: _token != null),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        // ✅ FIXED: Menghindari linter warning
        final items = data['data']['data'] ?? data['data'];
        if (items is List) {
          return items.map((e) => Culinary.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error getCulinaries: $e');
      return [];
    }
  }

  Future<Culinary?> getCulinaryDetail(String slug) async {
    try {
      await _loadToken();
      final response = await http.get(
        Uri.parse('$baseUrl/culinaries/$slug'),
        headers: _headers(needsAuth: _token != null),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        // ✅ FIXED: Pengaman data null
        return Culinary.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Error getCulinaryDetail: $e');
      return null;
    }
  }

  Future<List<dynamic>> getPersonalizedRecommendations(
    String? userInterestCategory,
  ) async {
    await _loadToken();

    String url = '$baseUrl/destinations/recommendations';
    bool isCulinary = false;

    if (userInterestCategory != null &&
        userInterestCategory.toLowerCase().contains('kuliner')) {
      url = '$baseUrl/culinaries/recommendations';
      isCulinary = true;
    }

    try {
      debugPrint('=== [DEBUG API START] ===');
      debugPrint('1. URL Target: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: _headers(needsAuth: _token != null),
      );

      debugPrint('2. Status Code: ${response.statusCode}');
      debugPrint('3. Isi Response Body Mentah: ${response.body}');

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        // ✅ FIXED: Menghindari linter warning
        final items = data['data']['data'] ?? data['data'];

        debugPrint(
          '4. Tipe data "items" setelah diekstrak: ${items.runtimeType}',
        );
        debugPrint(
          '5. Jumlah items yang terdeteksi: ${items is List ? items.length : "Bukan List"}',
        );

        if (items is List) {
          if (isCulinary) {
            return items.map((e) => Culinary.fromJson(e)).toList();
          } else {
            return items.map((e) => Destination.fromJson(e)).toList();
          }
        }
      } else {
        debugPrint('X. Laravel merespon "success: false"');
      }
    } catch (e) {
      debugPrint('X. Terjadi Crash/Error di Flutter: $e');
    }

    debugPrint('=== [DEBUG API END] ===');
    return [];
  }

  // =========================================================================
  // Events (Versi Aman & Stabil)
  // =========================================================================

  Future<List<Event>> getEvents({bool? upcoming}) async {
    try {
      await _loadToken();
      var url = '$baseUrl/events?';
      if (upcoming != null) url += 'upcoming=$upcoming';

      final response = await http.get(
        Uri.parse(url),
        headers: _headers(needsAuth: _token != null),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        // ✅ FIXED: Eksplisit boolean untuk linter
        final items = data['data']['data'] ?? data['data'];
        if (items is List) {
          // ✅ FIXED: Pengaman tipe data list
          return items.map((e) => Event.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      // ✅ FIXED: Menahan crash jika network/server bermasalah
      debugPrint("Error getEvents: $e");
      return [];
    }
  }

  Future<Event?> getEventDetail(String slug) async {
    try {
      await _loadToken();
      final response = await http.get(
        Uri.parse('$baseUrl/events/$slug'),
        headers: _headers(needsAuth: _token != null),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        // ✅ FIXED: Pengaman null data
        return Event.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      // ✅ FIXED: Menahan crash jika internet mati
      debugPrint("Error getEventDetail: $e");
      return null;
    }
  }

  Future<List<Event>> getEventsByMonth({
    required int year,
    required int month,
  }) async {
    try {
      await _loadToken();
      final response = await http.get(
        Uri.parse('$baseUrl/events/month/$year/$month'),
        headers: _headers(needsAuth: _token != null),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        // ✅ FIXED: Eksplisit boolean
        final items = data['data'];
        if (items is List) {
          return items.map((e) => Event.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint("Error parsing di getEventsByMonth: $e");
      return [];
    }
  }

  // Bookmarks
  Future<bool> toggleBookmark(String type, int id) async {
    await _loadToken();
    final response = await http.post(
      Uri.parse('$baseUrl/bookmarks/${type}s/$id'),
      headers: _headers(needsAuth: true),
    );
    final data = jsonDecode(response.body);
    return data['success'] ?? false;
  }

  Future<List<Map<String, dynamic>>> getBookmarks() async {
    await _loadToken();
    final response = await http.get(
      Uri.parse('$baseUrl/bookmarks'),
      headers: _headers(needsAuth: true),
    );
    final data = jsonDecode(response.body);
    if (data['success']) {
      return List<Map<String, dynamic>>.from(data['data']);
    }
    return [];
  }

  // =========================================================================
  // Search (Versi Aman & Stabil untuk Guest)
  // =========================================================================

  Future<Map<String, dynamic>> search(String query) async {
    try {
      await _loadToken();
      final response = await http.get(
        Uri.parse('$baseUrl/search?q=$query'),
        headers: _headers(needsAuth: _token != null),
      );

      final data = jsonDecode(response.body);

      // ✅ PERBAIKAN: Cek eksplisit boolean dan pastikan data['data'] tidak null
      if (data['success'] == true && data['data'] != null) {
        return {
          // ✅ PERBAIKAN: Gunakan '?? []' dan 'as List' yang aman agar tidak null crash
          'destinations': ((data['data']['destinations'] ?? []) as List)
              .map((e) => Destination.fromJson(e))
              .toList(),
          'culinaries': ((data['data']['culinaries'] ?? []) as List)
              .map((e) => Culinary.fromJson(e))
              .toList(),
          'events': ((data['data']['events'] ?? []) as List)
              .map((e) => Event.fromJson(e))
              .toList(),
        };
      }
      return {'destinations': [], 'culinaries': [], 'events': []};
    } catch (e) {
      // ✅ PERBAIKAN: Menahan crash jika internet putus, tetap return map kosong agar UI aman
      debugPrint('Error pada Fitur Search: $e');
      return {'destinations': [], 'culinaries': [], 'events': []};
    }
  }

  // Reviews
  Future<bool> addReviewDestination(
    int id,
    int rating,
    String comment, {
    List<String>? images,
  }) async {
    await _loadToken();
    final response = await http.post(
      Uri.parse('$baseUrl/destinations/$id/reviews'),
      headers: _headers(needsAuth: true),
      body: jsonEncode({
        'rating': rating,
        'comment': comment,
        'images': images,
      }),
    );
    final data = jsonDecode(response.body);
    return data['success'] ?? false;
  }

  Future<bool> addReviewCulinary(
    int id,
    int rating,
    String comment, {
    List<String>? images,
  }) async {
    await _loadToken();
    final response = await http.post(
      Uri.parse('$baseUrl/culinaries/$id/reviews'),
      headers: _headers(needsAuth: true),
      body: jsonEncode({
        'rating': rating,
        'comment': comment,
        'images': images,
      }),
    );
    final data = jsonDecode(response.body);
    return data['success'] ?? false;
  }

  // Visits
  Future<bool> recordVisitDestination(int id) async {
    await _loadToken();
    final response = await http.post(
      Uri.parse('$baseUrl/visits/destinations/$id'),
      headers: _headers(needsAuth: true),
      body: jsonEncode({
        'visit_date': DateTime.now().toIso8601String().split('T')[0],
      }),
    );
    final data = jsonDecode(response.body);
    return data['success'] ?? false;
  }

  Future<bool> recordVisitCulinary(int id) async {
    await _loadToken();
    final response = await http.post(
      Uri.parse('$baseUrl/visits/culinaries/$id'),
      headers: _headers(needsAuth: true),
      body: jsonEncode({
        'visit_date': DateTime.now().toIso8601String().split('T')[0],
      }),
    );
    final data = jsonDecode(response.body);
    return data['success'] ?? false;
  }

  Future<bool> recordVisitEvent(int id) async {
    await _loadToken();
    final response = await http.post(
      Uri.parse('$baseUrl/visits/events/$id'),
      headers: _headers(needsAuth: true),
      body: jsonEncode({
        'visit_date': DateTime.now().toIso8601String().split('T')[0],
      }),
    );
    final data = jsonDecode(response.body);
    return data['success'] ?? false;
  }

  Future<List<Map<String, dynamic>>> getVisits() async {
    await _loadToken();
    final response = await http.get(
      Uri.parse('$baseUrl/visits'),
      headers: _headers(needsAuth: true),
    );
    final data = jsonDecode(response.body);
    if (data['success']) {
      return List<Map<String, dynamic>>.from(data['data']);
    }
    return [];
  }

  // Profile
  Future<Map<String, dynamic>?> getProfile() async {
    await _loadToken();
    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: _headers(needsAuth: true),
    );
    final data = jsonDecode(response.body);
    if (data['success']) {
      return data['data'];
    }
    return null;
  }

  Future<Map<String, dynamic>?> getStats() async {
    await _loadToken();
    final response = await http.get(
      Uri.parse('$baseUrl/profile/stats'),
      headers: _headers(needsAuth: true),
    );
    final data = jsonDecode(response.body);
    if (data['success']) {
      return data['data'];
    }
    return null;
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    await _loadToken();
    final response = await http.put(
      Uri.parse('$baseUrl/profile'),
      headers: _headers(needsAuth: true),
      body: jsonEncode(data),
    );
    final result = jsonDecode(response.body);
    return result['success'] ?? false;
  }

  // Badges
  Future<List<Map<String, dynamic>>> getBadges() async {
    await _loadToken();
    final response = await http.get(
      Uri.parse('$baseUrl/badges'),
      headers: _headers(needsAuth: true),
    );
    final data = jsonDecode(response.body);
    if (data['success']) {
      return List<Map<String, dynamic>>.from(data['data']);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getMyBadges() async {
    await _loadToken();
    final response = await http.get(
      Uri.parse('$baseUrl/badges/my'),
      headers: _headers(needsAuth: true),
    );
    final data = jsonDecode(response.body);
    if (data['success']) {
      return List<Map<String, dynamic>>.from(data['data']);
    }
    return [];
  }

  // Rewards
  Future<List<Map<String, dynamic>>> getRewards() async {
    await _loadToken();
    final response = await http.get(
      Uri.parse('$baseUrl/rewards'),
      headers: _headers(needsAuth: true),
    );
    final data = jsonDecode(response.body);
    if (data['success']) {
      return List<Map<String, dynamic>>.from(data['data']);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getAvailableRewards() async {
    await _loadToken();
    final response = await http.get(
      Uri.parse('$baseUrl/rewards/available'),
      headers: _headers(needsAuth: true),
    );
    final data = jsonDecode(response.body);
    if (data['success']) {
      return List<Map<String, dynamic>>.from(data['data']);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getMyRewards() async {
    await _loadToken();
    final response = await http.get(
      Uri.parse('$baseUrl/rewards/my'),
      headers: _headers(needsAuth: true),
    );
    final data = jsonDecode(response.body);
    if (data['success']) {
      return List<Map<String, dynamic>>.from(data['data']);
    }
    return [];
  }

  Future<bool> claimReward(int id) async {
    await _loadToken();
    final response = await http.post(
      Uri.parse('$baseUrl/rewards/$id/claim'),
      headers: _headers(needsAuth: true),
    );
    final data = jsonDecode(response.body);
    return data['success'] ?? false;
  }

  Future<bool> useReward(int id) async {
    await _loadToken();
    final response = await http.post(
      Uri.parse('$baseUrl/rewards/$id/use'),
      headers: _headers(needsAuth: true),
    );
    final data = jsonDecode(response.body);
    return data['success'] ?? false;
  }

  // Trip Plans
  Future<Map<String, dynamic>> getTripPlans() async {
    await _loadToken();
    final response = await http.get(
      Uri.parse('$baseUrl/trip-plans'),
      headers: _headers(needsAuth: true),
    );
    final data = jsonDecode(response.body);
    return data;
  }

  Future<Map<String, dynamic>> getTripPlan(int id) async {
    await _loadToken();
    final response = await http.get(
      Uri.parse('$baseUrl/trip-plans/$id'),
      headers: _headers(needsAuth: true),
    );
    final data = jsonDecode(response.body);
    return data;
  }

  Future<Map<String, dynamic>> createTripPlan({
    required String name,
    String? description,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await _loadToken();
    final response = await http.post(
      Uri.parse('$baseUrl/trip-plans'),
      headers: _headers(needsAuth: true),
      body: jsonEncode({
        'title': name, // ✅ FIXED: Backend expects 'title' not 'name'
        'description': description,
        'start_date': startDate.toIso8601String().split('T')[0],
        'end_date': endDate.toIso8601String().split('T')[0],
      }),
    );
    final data = jsonDecode(response.body);
    return data;
  }

  Future<Map<String, dynamic>> updateTripPlan(
    int id,
    Map<String, dynamic> planData,
  ) async {
    await _loadToken();
    final response = await http.put(
      Uri.parse('$baseUrl/trip-plans/$id'),
      headers: _headers(needsAuth: true),
      body: jsonEncode(planData),
    );
    final data = jsonDecode(response.body);
    return data;
  }

  Future<Map<String, dynamic>> deleteTripPlan(int id) async {
    await _loadToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/trip-plans/$id'),
      headers: _headers(needsAuth: true),
    );
    final data = jsonDecode(response.body);
    return data;
  }

  Future<bool> addItemToPlan(int planId, Map<String, dynamic> itemData) async {
    await _loadToken();
    final response = await http.post(
      Uri.parse('$baseUrl/trip-plans/$planId/items'),
      headers: _headers(needsAuth: true),
      body: jsonEncode(itemData),
    );
    final data = jsonDecode(response.body);
    return data['success'] ?? false;
  }

  Future<bool> removeItemFromPlan(int planId, int itemId) async {
    await _loadToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/trip-plans/$planId/items/$itemId'),
      headers: _headers(needsAuth: true),
    );
    final data = jsonDecode(response.body);
    return data['success'] ?? false;
  }

  Future<Map<String, dynamic>> generateAIPlan({
    required int planId,
    required double budget,
    required List<String> interests,
    required int duration,
  }) async {
    await _loadToken();
    final response = await http.post(
      Uri.parse('$baseUrl/trip-plans/$planId/generate'),
      headers: _headers(needsAuth: true),
      body: jsonEncode({
        'budget': budget,
        'interests': interests,
        'duration': duration,
      }),
    );
    final data = jsonDecode(response.body);
    return data;
  }

  Future<Map<String, dynamic>> generateTripPlan(
    int planId,
    Map<String, dynamic> data,
  ) async {
    await _loadToken();
    final response = await http.post(
      Uri.parse('$baseUrl/trip-plans/$planId/generate'),
      headers: _headers(needsAuth: true),
      body: jsonEncode(data),
    );
    final decodedData = jsonDecode(response.body);
    return decodedData;
  }

  // Notifications
  Future<Map<String, dynamic>> getNotifications({int page = 1}) async {
    await _loadToken();
    final response = await http.get(
      Uri.parse('$baseUrl/notifications?page=$page'),
      headers: _headers(needsAuth: true),
    );
    final data = jsonDecode(response.body);
    if (data['success']) {
      return {
        'notifications': data['data'],
        'unread_count': data['unread_count'] ?? 0,
        'pagination': data['pagination'],
      };
    }
    return {'notifications': [], 'unread_count': 0};
  }

  Future<int> getUnreadNotificationCount() async {
    await _loadToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/unread-count'),
        headers: _headers(needsAuth: true),
      );
      final data = jsonDecode(response.body);
      return data['count'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<bool> markNotificationAsRead(int notificationId) async {
    await _loadToken();
    final response = await http.post(
      Uri.parse('$baseUrl/notifications/$notificationId/read'),
      headers: _headers(needsAuth: true),
    );
    final data = jsonDecode(response.body);
    return data['success'] ?? false;
  }

  Future<bool> markAllNotificationsAsRead() async {
    await _loadToken();
    final response = await http.post(
      Uri.parse('$baseUrl/notifications/read-all'),
      headers: _headers(needsAuth: true),
    );
    final data = jsonDecode(response.body);
    return data['success'] ?? false;
  }

  Future<bool> deleteNotification(int notificationId) async {
    await _loadToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/notifications/$notificationId'),
      headers: _headers(needsAuth: true),
    );
    final data = jsonDecode(response.body);
    return data['success'] ?? false;
  }

  Future<bool> deleteAllReadNotifications() async {
    await _loadToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/notifications/read/all'),
      headers: _headers(needsAuth: true),
    );
    final data = jsonDecode(response.body);
    return data['success'] ?? false;
  }
}
