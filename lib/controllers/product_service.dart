import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../services/env.dart';
import '../services/manage_http_response.dart';

class ProductService {
  static Future<ApiResponse<Product>> addProduct({
    required String productName,
    required double productPrice,
    required int quantity,
    required String description,
    required String category,
    required String subCategory,
    required List<String> images,
  }) async {
    try {
      // Si las imágenes son muy grandes, subir solo la primera o una versión reducida
      List<String> processedImages = images;
      if (images.isNotEmpty && images[0].length > 100000) {
        // Limitar a solo la primera imagen o reducir su tamaño
        processedImages = [images[0].substring(0, 100000) + '...'];
        print('Imagen demasiado grande, enviando versión reducida');
      }

      // Ensure field names match exactly what the server expects
      final Map<String, dynamic> productData = {
        'productName': productName,
        'productPrice': productPrice,
        'quantity': quantity,
        'description': description,
        'category': category,
        'subCategory': subCategory,
        'images': processedImages,
      };

      print('Sending product data: $productData');
      final requestBody = jsonEncode(productData);
      print('Tamaño de la solicitud JSON: ${requestBody.length} bytes');

      final response = await http.post(
        Uri.parse(Environment.addProduct),
        headers: Environment.headers,
        body: requestBody,
      );

      print('Respuesta completa del servidor: ${response.body}');

      return ManageHttpResponse.handleResponse<Product>(
        response: response,
        onSuccess: (json) => Product.fromJson(json),
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error al crear el producto: $e',
        statusCode: 500,
      );
    }
  }

  static Future<ApiResponse<List<Product>>> getPopularProducts() async {
    try {
      final response = await http.get(
        Uri.parse(Environment.popularProducts),
        headers: Environment.headers,
      );

      return ManageHttpResponse.handleResponse<List<Product>>(
        response: response,
        onSuccess: (json) => (json['products'] as List)
            .map((product) => Product.fromJson(product))
            .toList(),
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error al obtener productos populares: $e',
        statusCode: 500,
      );
    }
  }

  static Future<ApiResponse<List<Product>>> getRecommendedProducts() async {
    try {
      final response = await http.get(
        Uri.parse(Environment.recommendedProducts),
        headers: Environment.headers,
      );

      return ManageHttpResponse.handleResponse<List<Product>>(
        response: response,
        onSuccess: (json) => (json['products'] as List)
            .map((product) => Product.fromJson(product))
            .toList(),
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error al obtener productos recomendados: $e',
        statusCode: 500,
      );
    }
  }
}
