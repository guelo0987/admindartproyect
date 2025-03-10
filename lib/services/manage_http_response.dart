import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    required this.statusCode,
  });
}

class ManageHttpResponse {
  static Future<ApiResponse<T>> handleResponse<T>({
    required http.Response response,
    required T Function(Map<String, dynamic>) onSuccess,
  }) async {
    try {
      final decodedBody = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse(
          success: true,
          data: onSuccess(decodedBody),
          message: decodedBody['message'],
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse(
          success: false,
          message: decodedBody['message'] ?? 'Error en la solicitud',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error al procesar la respuesta: $e',
        statusCode: response.statusCode,
      );
    }
  }

  static String getErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Solicitud incorrecta';
      case 401:
        return 'No autorizado';
      case 403:
        return 'Acceso prohibido';
      case 404:
        return 'No encontrado';
      case 500:
        return 'Error interno del servidor';
      default:
        return 'Error desconocido';
    }
  }
}