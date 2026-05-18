import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/destination.dart';
import '../models/category.dart';
import '../models/culinary.dart';
import '../models/event.dart';

class ApiService {
  // Gunakan 10.0.2.2 untuk Android emulator, atau IP lokal komputer untuk device fisik
  // Contoh device fisik: 'http://192.168.1.x:8000/api'
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  String? _token;

  Future<Map<String, dynamic>?> addMenu(String name, String price, String address) async {
  if (_token == null) await _loadToken();
  
  final response = await http.post(
    Uri.parse('$baseUrl/culinaries'), // Sesuaikan endpoint Laravel kamu
    headers: {
      'Authorization': 'Bearer $_token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: jsonEncode({
      'name': name,
      'price': price,
      'address': address,
      'is_available': 1,
    }),
  );

  if (response.statusCode == 201 || response.statusCode == 200) {
    return jsonDecode(response.body);
  }
  return null;
}

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  Future<void> _saveToken(String _token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', _token);
    _token = _token;
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _token = null;
  }

  // Di dalam class ApiService
Future<Map<String, dynamic>> replyRating(int ratingId, String replyText) async {
  final response = await http.post(
    Uri.parse('$baseUrl/ratings/$ratingId/reply'),
    headers: {'Authorization': 'Bearer $_token', 'Content-Type': 'application/json'},
    body: jsonEncode({'reply': replyText}),
  );
  return jsonDecode(response.body);
}

Future<bool> deleteRating(int ratingId) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/ratings/$ratingId'),
    headers: {'Authorization': 'Bearer $_token'},
  );
  return response.statusCode == 200;
}

  Map<String, String> _headers({bool needsAuth = false}) {
    final headers = {'Accept': 'application/json', 'Content-Type': 'application/json'};
    if (needsAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

 Future<Map<String, dynamic>> register(
    String name, 
    String email, 
    String password, 
    String phone, 
    String role, // <--- Pastikan role masuk di sini
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
        'role': role, // <--- Sekarang variabel ini sudah dikenal
      }),
    );
    
    final data = jsonDecode(response.body);
    // Tambahkan pengecekan success dan simpan token jika perlu
    return data;
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
    await http.post(Uri.parse('$baseUrl/auth/logout'), headers: _headers(needsAuth: true));
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

  Future<Map<String, dynamic>> resetPassword(String token, String email, String password) async {
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
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  Future<bool> verifyResetToken(String token, String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/password/verify-token'),
        headers: _headers(),
        body: jsonEncode({
          'token': token,
          'email': email,
        }),
      );
      final data = jsonDecode(response.body);
      return data['success'] ?? false;
    } catch (e) {
      return false;
    }
  }

  // Categories
  Future<List<Category>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories'), headers: _headers());
    final data = jsonDecode(response.body);
    if (data['success']) {
      return (data['data'] as List).map((e) => Category.fromJson(e)).toList();
    }
    return [];
  }

  // Destinations
  Future<List<Destination>> getDestinations({String? category, bool? featured}) async {
    await _loadToken();
    var url = '$baseUrl/destinations?per_page=100&';
    if (category != null) url += 'category=$category&';
    if (featured != null) url += 'featured=$featured&';
    
    final response = await http.get(Uri.parse(url), headers: _headers(needsAuth: _token != null));
    final data = jsonDecode(response.body);
    if (data['success']) {
      final items = data['data']['data'] ?? data['data'];
      return (items as List).map((e) => Destination.fromJson(e)).toList();
    }
    return [];
  }

  Future<Destination?> getDestinationDetail(String slug) async {
    await _loadToken();
    final response = await http.get(
      Uri.parse('$baseUrl/destinations/$slug'),
      headers: _headers(needsAuth: _token != null),
    );
    final data = jsonDecode(response.body);
    if (data['success']) {
      return Destination.fromJson(data['data']);
    }
    return null;
  }

  // Culinaries
  Future<List<Culinary>> getCulinaries({bool? featured}) async {
    await _loadToken();
    var url = '$baseUrl/culinaries?per_page=100&';
    if (featured != null) url += 'featured=$featured';
    
    final response = await http.get(Uri.parse(url), headers: _headers(needsAuth: _token != null));
    final data = jsonDecode(response.body);
    if (data['success']) {
      final items = data['data']['data'] ?? data['data'];
      return (items as List).map((e) => Culinary.fromJson(e)).toList();
    }
    return [];
  }

  Future<Culinary?> getCulinaryDetail(String slug) async {
    await _loadToken();
    final response = await http.get(
      Uri.parse('$baseUrl/culinaries/$slug'),
      headers: _headers(needsAuth: _token != null),
    );
    final data = jsonDecode(response.body);
    if (data['success']) {
      return Culinary.fromJson(data['data']);
    }
    return null;
  }

  // Events
  Future<List<Event>> getEvents({bool? upcoming}) async {
    await _loadToken();
    var url = '$baseUrl/events?';
    if (upcoming != null) url += 'upcoming=$upcoming';
    
    final response = await http.get(Uri.parse(url), headers: _headers(needsAuth: _token != null));
    final data = jsonDecode(response.body);
    if (data['success']) {
      final items = data['data']['data'] ?? data['data'];
      return (items as List).map((e) => Event.fromJson(e)).toList();
    }
    return [];
  }

  Future<Event?> getEventDetail(String slug) async {
    await _loadToken();
    final response = await http.get(
      Uri.parse('$baseUrl/events/$slug'),
      headers: _headers(needsAuth: _token != null),
    );
    final data = jsonDecode(response.body);
    if (data['success']) {
      return Event.fromJson(data['data']);
    }
    return null;
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

  // Search
  Future<Map<String, dynamic>> search(String query) async {
    await _loadToken();
    final response = await http.get(
      Uri.parse('$baseUrl/search?q=$query'),
      headers: _headers(needsAuth: _token != null),
    );
    final data = jsonDecode(response.body);
    if (data['success']) {
      return {
        'destinations': (data['data']['destinations'] as List).map((e) => Destination.fromJson(e)).toList(),
        'culinaries': (data['data']['culinaries'] as List).map((e) => Culinary.fromJson(e)).toList(),
        'events': (data['data']['events'] as List).map((e) => Event.fromJson(e)).toList(),
      };
    }
    return {'destinations': [], 'culinaries': [], 'events': []};
  }

  // Reviews
  Future<bool> addReviewDestination(int id, int rating, String comment, {List<String>? images}) async {
    await _loadToken();
    final response = await http.post(
      Uri.parse('$baseUrl/destinations/$id/reviews'),
      headers: _headers(needsAuth: true),
      body: jsonEncode({
        'rating': rating,
        'comment': comment,
        'images': images,  // ✅ FIXED: Removed ? operator
      }),
    );
    final data = jsonDecode(response.body);
    return data['success'] ?? false;
  }

  Future<bool> addReviewCulinary(int id, int rating, String comment, {List<String>? images}) async {
    await _loadToken();
    final response = await http.post(
      Uri.parse('$baseUrl/culinaries/$id/reviews'),
      headers: _headers(needsAuth: true),
      body: jsonEncode({
        'rating': rating,
        'comment': comment,
        'images': images,  // ✅ FIXED: Removed ? operator
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
        'visit_date': DateTime.now().toIso8601String().split('T')[0],  // ✅ FIXED: Add visit_date
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
        'visit_date': DateTime.now().toIso8601String().split('T')[0],  // ✅ FIXED: Add visit_date
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
        'title': name,  // ✅ FIXED: Backend expects 'title' not 'name'
        'description': description,
        'start_date': startDate.toIso8601String().split('T')[0],
        'end_date': endDate.toIso8601String().split('T')[0],
      }),
    );
    final data = jsonDecode(response.body);
    return data;
  }

  Future<Map<String, dynamic>> updateTripPlan(int id, Map<String, dynamic> planData) async {
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

  // ============================================================
  // TARUH DI SINI (DI BAWAH FUNGSI DELETE NOTIFICATION)
  // ============================================================
  
  Future<Map<String, dynamic>> fetchHomeData() async {
    try {
      // Kita pakai baseUrl dan _headers() yang sudah lo buat di atas
      final response = await http.get(
        Uri.parse('$baseUrl/home'), 
        headers: _headers() // Pakai helper headers lo biar aman
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        // Kita ambil isi dari key 'data' karena di Laravel HomeController 
        // lo ngirimnya: return response()->json(['data' => [...]])
        return responseData['data'] ?? {}; 
      } else {
        print("Server Error di Home: ${response.statusCode}");
        return {};
      }
    } catch (e) {
      print("Error koneksi di Home: $e");
      return {};
    }
  }
  
Future<Map<String, dynamic>> getHomeData() async {
    try {
      // Kita langsung tulis alamatnya di sini biar gak pusing nyari variabel baseUrl
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/home'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Gagal memuat data home dari Laravel');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }
}