import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/banners.dart';
import '../services/env.dart';
import '../services/manage_http_response.dart';

class BannerService {
  static Future<ApiResponse<Banner>> uploadBanner({
    required String image,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(Environment.banner),
        headers: Environment.headers,
        body: jsonEncode({'image': image}),
      );

      return ManageHttpResponse.handleResponse<Banner>(
        response: response,
        onSuccess: (json) => Banner.fromJson(json),
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error al subir el banner: $e',
        statusCode: 500,
      );
    }
  }

  static Future<ApiResponse<List<Banner>>> getBanners() async {
    try {
      final response = await http.get(
        Uri.parse(Environment.banner),
        headers: Environment.headers,
      );

      return ManageHttpResponse.handleResponse<List<Banner>>(
        response: response,
        onSuccess: (json) => (json['banners'] as List)
            .map((banner) => Banner.fromJson(banner))
            .toList(),
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error al obtener los banners: $e',
        statusCode: 500,
      );
    }
  }
}
