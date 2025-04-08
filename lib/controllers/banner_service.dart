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

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final dynamic decodedBody = jsonDecode(response.body);
          List<dynamic> bannersList;

          if (decodedBody is Map<String, dynamic> &&
              decodedBody.containsKey('banners')) {
            // If response is a Map with 'banners' key
            bannersList = decodedBody['banners'] as List;
          } else if (decodedBody is List) {
            // If response is directly a List
            bannersList = decodedBody;
          } else {
            return ApiResponse(
              success: false,
              message: 'Formato de respuesta inesperado',
              statusCode: response.statusCode,
            );
          }

          final banners = bannersList.map((banner) {
            if (banner is Map) {
              // Convert to Map<String, dynamic> explicitly
              final Map<String, dynamic> bannerMap = {};
              banner.forEach((key, value) {
                if (key is String) {
                  bannerMap[key] = value;
                }
              });
              return Banner.fromJson(bannerMap);
            } else {
              // Handle case where banner might be just a string URL
              return Banner.fromJson({'image': banner.toString()});
            }
          }).toList();

          return ApiResponse(
            success: true,
            data: banners,
            statusCode: response.statusCode,
          );
        } catch (e) {
          return ApiResponse(
            success: false,
            message: 'Error al procesar la respuesta: $e',
            statusCode: response.statusCode,
          );
        }
      } else {
        try {
          final decodedBody = jsonDecode(response.body);
          return ApiResponse(
            success: false,
            message: decodedBody['message'] ?? 'Error en la solicitud',
            statusCode: response.statusCode,
          );
        } catch (e) {
          return ApiResponse(
            success: false,
            message: 'Error en la solicitud',
            statusCode: response.statusCode,
          );
        }
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error al obtener los banners: $e',
        statusCode: 500,
      );
    }
  }
}
