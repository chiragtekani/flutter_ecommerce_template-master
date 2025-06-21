// lib/services/api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://abettech.com/agrofarm/public/api';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Future<Map<String, String>> getHeaders({bool withAuth = false}) async {
    final token = withAuth ? await getToken() : null;
    return {
      'Accept': 'application/json',
      if (withAuth && token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> customerRegister(
      Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/customers/register'),
      headers: {
        ...(await getHeaders()),
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final token = data['token'] ?? data['access_token'];
      if (token != null) {
        await saveToken(token);
      }
    }

    return response;
  }

  static Future<http.Response> customerLogin(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/customer/login'),
      headers: {
        ...(await getHeaders()),
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'] ?? data['access_token'];
      if (token != null) {
        await saveToken(token);
      }
    }

    return response;
  }

  static Future<http.Response> getCustomerProfile() async {
    return http.get(
      Uri.parse('$baseUrl/customer/profile'),
      headers: await getHeaders(withAuth: true),
    );
  }

  static Future<http.Response> customerLogout() async {
    final response = await http.post(
      Uri.parse('$baseUrl/customer/logout'),
      headers: await getHeaders(withAuth: true),
    );
    if (response.statusCode == 200) {
      await removeToken();
    }
    return response;
  }

  static Future<http.Response> getProducts() async {
    return http.get(
      Uri.parse('$baseUrl/products'),
      headers: await getHeaders(),
    );
  }

  static Future<http.Response> getShopsByVillage(int villageId) async {
    return http.get(
      Uri.parse('$baseUrl/locations/villages/$villageId/shops'),
      headers: await getHeaders(),
    );
  }

  static Future<http.Response> getProductsByShop(int shopId) async {
    return http.get(
      Uri.parse('$baseUrl/vendors/${shopId}/products'),
      headers: await getHeaders(),
    );
  }

  static Future<http.Response> addComplaint(Map<String, dynamic> body) async {
    return http.post(
      Uri.parse('$baseUrl/complaints'),
      headers: {
        ...(await getHeaders()),
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> getCustomerComplaints(int customerId) async {
    return http.get(
      Uri.parse('$baseUrl/complaints/customer/$customerId'),
      headers: await getHeaders(),
    );
  }

  static Future<http.Response> updateCustomerProfile(
      Map<String, dynamic> body) async {
    return http.put(
      Uri.parse('$baseUrl/customer/profile'),
      headers: {
        ...(await getHeaders(withAuth: true)),
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> updateCustomerPassword(
      Map<String, dynamic> body) async {
    return http.put(
      Uri.parse('$baseUrl/customer/profile'),
      headers: {
        ...(await getHeaders(withAuth: true)),
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
  }

  /// Fetch all districts
  static Future<http.Response> getDistricts() async {
    return http.get(
      Uri.parse('$baseUrl/locations/districts'),
      headers: await getHeaders(),
    );
  }

  /// Fetch talukas by district ID
  static Future<http.Response> getTalukas(int districtId) async {
    return http.get(
      Uri.parse('$baseUrl/locations/districts/$districtId/talukas'),
      headers: await getHeaders(),
    );
  }

  /// Fetch villages by taluka ID
  static Future<http.Response> getVillages(int talukaId) async {
    return http.get(
      Uri.parse('$baseUrl/locations/talukas/$talukaId/villages'),
      headers: await getHeaders(),
    );
  }

  static Future<http.Response> shopRegister(Map<String, dynamic> body) async {
    return http.post(
      Uri.parse('$baseUrl/vendors/register'),
      headers: {
        ...(await getHeaders()),
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> shopLogin(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/vendors/login'),
      headers: {
        ...(await getHeaders()),
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'] ?? data['access_token'];
      if (token != null) {
        await saveToken(token);
      }
    }

    return response;
  }

  static Future<http.StreamedResponse> addProduct(
    Map<String, String> fields,
    File image,
  ) async {
    final token = await getToken();
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/products'),
    );
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields.addAll(fields);
    request.files.add(await http.MultipartFile.fromPath(
      'product_image',
      image.path,
      contentType: MediaType('image', 'jpeg'),
    ));

    return await request.send();
  }

  static Future<http.Response> shopUpdateProfile(
      Map<String, dynamic> body) async {
    return http.put(
      Uri.parse('$baseUrl/vendors/profile'),
      headers: {
        ...(await getHeaders(withAuth: true)),
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
  }

  static Future<http.StreamedResponse> updateProduct(
    int productId,
    Map<String, String> fields,
    File image,
  ) async {
    final token = await getToken();
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/products/$productId'),
    );
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields.addAll(fields);
    request.files.add(await http.MultipartFile.fromPath(
      'product_image',
      image.path,
      contentType: MediaType('image', 'jpeg'),
    ));

    return await request.send();
  }

  static Future<http.Response> getMyProducts() async {
    return http.get(
      Uri.parse('$baseUrl/products/my'),
      headers: await getHeaders(withAuth: true),
    );
  }
}
