import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'api_client.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

class ApiService {
  // Configured to point to the remote backend
  static const String baseUrl = 'http://54.162.11.222:8000';
  static String? _sessionCookie;
  static String? _csrfToken;
  
  // Cross-platform client that enables withCredentials on Web
  static final http.Client _client = getClient();

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        // On web, cookies are automatically attached by the browser
        // Setting 'Cookie' manually on web throws a security error
        if (!kIsWeb && _sessionCookie != null) 'Cookie': _sessionCookie!,
        if (_csrfToken != null) 'X-CSRF-Token': _csrfToken!,
      };

  static Map<String, String> get _formHeaders => {
        'Content-Type': 'application/x-www-form-urlencoded',
        if (!kIsWeb && _sessionCookie != null) 'Cookie': _sessionCookie!,
        if (_csrfToken != null) 'X-CSRF-Token': _csrfToken!,
      };

  static void _extractCookies(http.Response response) {
    if (kIsWeb) return; // Browser handles Set-Cookie natively
    
    final setCookie = response.headers['set-cookie'];
    if (setCookie != null) {
      _sessionCookie = setCookie.split(';').first;
    }
  }

  static Map<String, dynamic> _decodeMapResponse(http.Response response) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          response.statusCode,
          response.body.isEmpty
              ? 'Request failed with status ${response.statusCode}.'
              : response.body,
        );
      }
      rethrow;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error =
          decoded is Map ? decoded['detail'] ?? decoded['message'] : null;
      throw ApiException(
        response.statusCode,
        error?.toString() ?? 'Request failed with status ${response.statusCode}.',
      );
    }
    if (decoded is! Map) {
      throw const FormatException('The server returned an unexpected response.');
    }
    return Map<String, dynamic>.from(decoded);
  }

  static void _ensureSuccessful(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    var message = response.body;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        message = (decoded['detail'] ?? decoded['message'] ?? message).toString();
      }
    } on FormatException {
      // Preserve the response body when the server does not return JSON.
    }
    throw ApiException(
      response.statusCode,
      message.isEmpty
          ? 'Request failed with status ${response.statusCode}.'
          : message,
    );
  }

  // ── Auth ──
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/auth/login'),
      headers: _formHeaders,
      body: Uri(queryParameters: {
        'username': username,
        'password': password,
      }).query,
    );
    _extractCookies(response);
    return _decodeMapResponse(response);
  }

  static Future<Map<String, dynamic>> logout() async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/auth/logout'),
      headers: _headers,
    );
    _sessionCookie = null;
    _csrfToken = null;
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> checkAuth() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/auth/check-auth'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getGoogleOAuthUrl({String? redirectUri}) async {
    final uri = Uri.parse('$baseUrl/api/v1/auth/oauth/google')
        .replace(queryParameters: redirectUri != null ? {'redirect_uri': redirectUri} : null);
    final response = await _client.get(uri, headers: _headers);
    return jsonDecode(response.body);
  }

  // ── Users ──
  static Future<Map<String, dynamic>> createUser(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/users/'),
      headers: _headers,
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/users/me'),
      headers: _headers,
    );
    return _decodeMapResponse(response);
  }

  static Future<Map<String, dynamic>> updateUser(String username, Map<String, dynamic> data) async {
    final response = await _client.patch(
      Uri.parse('$baseUrl/api/v1/users/$username'),
      headers: _headers,
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  // ── Medications ──
  static Future<List<dynamic>> getMedications() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/medications/'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> addMedication(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/medications/'),
      headers: _headers,
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateMedication(int id, Map<String, dynamic> data) async {
    final response = await _client.patch(
      Uri.parse('$baseUrl/api/v1/medications/$id'),
      headers: _headers,
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteMedication(int id) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/api/v1/medications/$id'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  // ── Family ──
  static Future<Map<String, dynamic>> sendFamilyRequest(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/family/request'),
      headers: _headers,
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getFamilyRequests() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/family/requests'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> acceptFamilyRequest(int connectionId) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/family/requests/$connectionId/accept'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> rejectFamilyRequest(int connectionId) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/family/requests/$connectionId/reject'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getFamilyMembers() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/family/members'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> removeFamilyMember(int connectionId) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/api/v1/family/members/$connectionId'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  // ── Hospital Services ──
  static Future<Map<String, dynamic>> getHospitals({int page = 1, int itemsPerPage = 10}) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/services/hospital/?page=$page&items_per_page=$itemsPerPage'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getHospital(int providerId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/services/hospital/$providerId'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getHospitalDoctors(int providerId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/services/hospital/$providerId/doctors'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getDoctorSlots(int providerId, int doctorId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/services/hospital/$providerId/doctors/$doctorId/slots'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createHospitalBooking(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/services/hospital/bookings'),
      headers: _headers,
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getHospitalBookings() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/services/hospital/bookings'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  // ── Lab Services ──
  static Future<Map<String, dynamic>> getLabs({int page = 1, int itemsPerPage = 10}) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/services/laboratory/?page=$page&items_per_page=$itemsPerPage'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getLabTests(int providerId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/services/laboratory/$providerId/tests'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> searchLabTests(String query) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/services/laboratory/tests/search?query=$query'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createLabBooking(
    Map<String, dynamic> data, {
    String? prescriptionUrl,
  }) async {
    final payload = Map<String, dynamic>.from(data);
    final normalizedPrescriptionUrl = prescriptionUrl?.trim();
    if (normalizedPrescriptionUrl != null &&
        normalizedPrescriptionUrl.isNotEmpty) {
      if (normalizedPrescriptionUrl.length > 500 ||
          !RegExp(r'^https?://\S+$').hasMatch(normalizedPrescriptionUrl)) {
        throw ArgumentError.value(
          prescriptionUrl,
          'prescriptionUrl',
          'Must be an HTTP or HTTPS URL up to 500 characters.',
        );
      }
      payload['prescription_url'] = normalizedPrescriptionUrl;
    }
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/services/laboratory/bookings'),
      headers: _headers,
      body: jsonEncode(payload),
    );
    return _decodeMapResponse(response);
  }

  static Future<Map<String, dynamic>> getLabBookings() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/services/laboratory/bookings'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  // ── Pharmacy Services ──
  static Future<Map<String, dynamic>> getPharmacies({int page = 1, int itemsPerPage = 10}) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/services/pharmacy/?page=$page&items_per_page=$itemsPerPage'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> searchMedicines(String query) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/services/pharmacy/medicines/search?query=$query'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createPharmacyOrder(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/services/pharmacy/orders'),
      headers: _headers,
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getPharmacyOrders() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/services/pharmacy/orders'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  // ── Blood Bank Services ──
  static Future<Map<String, dynamic>> getBloodBanks({int page = 1, int itemsPerPage = 10}) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/services/blood-bank/?page=$page&items_per_page=$itemsPerPage'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> searchBloodStock(String bloodGroup) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/services/blood-bank/stock/search?blood_group=$bloodGroup'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createBloodRequest(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/services/blood-bank/requests'),
      headers: _headers,
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getBloodRequests() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/services/blood-bank/requests'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  // ── Ambulance Services ──
  static Future<Map<String, dynamic>> getAmbulanceProviders({int page = 1, int itemsPerPage = 10}) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/services/ambulance/?page=$page&items_per_page=$itemsPerPage'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getAvailableAmbulances({double? lat, double? lng}) async {
    final params = <String, String>{};
    if (lat != null) params['latitude'] = lat.toString();
    if (lng != null) params['longitude'] = lng.toString();
    final uri = Uri.parse('$baseUrl/api/v1/services/ambulance/available').replace(queryParameters: params);
    final response = await _client.get(uri, headers: _headers);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createAmbulanceRequest(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/services/ambulance/requests'),
      headers: _headers,
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getAmbulanceRequests() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/services/ambulance/requests'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  // ── Notifications ──
  static Future<Map<String, dynamic>> getNotificationHistory() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/notifications/history'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  // ── Additional OpenAPI features ──
  static Future<Map<String, dynamic>> createFamilyQrInvite(
    String relation,
  ) async {
    if (!const {
      'spouse',
      'parent',
      'child',
      'sibling',
      'grandparent',
      'grandchild',
      'other',
    }.contains(relation)) {
      throw ArgumentError.value(relation, 'relation');
    }
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/family/qr-invites'),
      headers: _headers,
      body: jsonEncode({'relation': relation}),
    );
    return _decodeMapResponse(response);
  }

  static Future<Map<String, dynamic>> redeemFamilyQrInvite(String token) async {
    final normalizedToken = token.trim();
    if (normalizedToken.length < 32 || normalizedToken.length > 128) {
      throw ArgumentError.value(token, 'token', 'Must be 32 to 128 characters.');
    }
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/family/qr-invites/redeem'),
      headers: _headers,
      body: jsonEncode({'token': normalizedToken}),
    );
    return _decodeMapResponse(response);
  }

  static Future<Uint8List> getEmergencyCard(String username) async {
    final normalizedUsername = username.trim();
    if (normalizedUsername.isEmpty) {
      throw ArgumentError.value(username, 'username', 'Must not be empty.');
    }
    final uri = Uri.parse(
      '$baseUrl/api/v1/users/${Uri.encodeComponent(normalizedUsername)}/emergency-card',
    );
    final response = await _client.get(uri, headers: _headers);
    _ensureSuccessful(response);
    if (response.bodyBytes.isEmpty) {
      throw const FormatException('The server returned an empty emergency card.');
    }
    return response.bodyBytes;
  }

  static Future<Map<String, dynamic>> searchHospitalsAndDoctors(
    String query, {
    String? city,
  }) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.length < 2 || normalizedQuery.length > 80) {
      throw ArgumentError.value(
        query,
        'query',
        'Must be between 2 and 80 characters.',
      );
    }
    final params = <String, String>{'query': normalizedQuery};
    final normalizedCity = city?.trim();
    if (normalizedCity != null && normalizedCity.length >= 2) {
      params['city'] = normalizedCity;
    }
    final uri = Uri.parse('$baseUrl/api/v1/services/hospital/search')
        .replace(queryParameters: params);
    final response = await _client.get(uri, headers: _headers);
    return _decodeMapResponse(response);
  }

  // ── Metadata ──
  static Future<Map<String, dynamic>> getMetadataOptions() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/metadata/options'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }
}
