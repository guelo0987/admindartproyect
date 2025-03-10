import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../services/env.dart';
import '../services/manage_http_response.dart';

class CategoryService {
  static Future<ApiResponse<Category>> createCategory({
    required String name,
    required String image,
    required String banner,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(Environment.categories),
        headers: Environment.headers,
        body: jsonEncode({
          'name': name,
          'image': image,
          'banner': image, // Using same image for banner in this case
        }),
      );

      return ManageHttpResponse.handleResponse<Category>(
        response: response,
        onSuccess: (json) => Category.fromJson(json),
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error al crear la categoría: $e',
        statusCode: 500,
      );
    }
  }

  static Future<ApiResponse<List<Category>>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse(Environment.categories),
        headers: Environment.headers,
      );

      return ManageHttpResponse.handleResponse<List<Category>>(
        response: response,
        onSuccess: (json) => (json['categories'] as List)
            .map((category) => Category.fromJson(category))
            .toList(),
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error al obtener las categorías: $e',
        statusCode: 500,
      );
    }
  }
}
