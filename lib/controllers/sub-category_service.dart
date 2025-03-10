import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sub-category.dart';
import '../services/env.dart';
import '../services/manage_http_response.dart';

class SubCategoryService {
  static Future<ApiResponse<SubCategory>> createSubCategory({
    required String categoryId,
    required String categoryName,
    required String image,
    required String subCategoryName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(Environment.subcategories),
        headers: Environment.headers,
        body: jsonEncode({
          'categoryId': categoryId,
          'categoryName': categoryName,
          'image': image,
          'subCategoryName': subCategoryName,
        }),
      );

      return ManageHttpResponse.handleResponse<SubCategory>(
        response: response,
        onSuccess: (json) => SubCategory.fromJson(json),
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error al crear la subcategoría: $e',
        statusCode: 500,
      );
    }
  }

  static Future<ApiResponse<List<SubCategory>>> getSubcategoriesByCategory(
      String categoryName) async {
    try {
      final response = await http.get(
        Uri.parse(Environment.getSubcategoriesByCategory(categoryName)),
        headers: Environment.headers,
      );

      return ManageHttpResponse.handleResponse<List<SubCategory>>(
        response: response,
        onSuccess: (json) => (json['subcategories'] as List)
            .map((subCategory) => SubCategory.fromJson(subCategory))
            .toList(),
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error al obtener las subcategorías: $e',
        statusCode: 500,
      );
    }
  }
}
