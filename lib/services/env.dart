class Environment {
  static const String apiUrl = 'http://localhost:3000';

  // Categories endpoints
  static const String categoriesEndpoint = '/api/categories';

  // Subcategories endpoints
  static const String subcategoriesEndpoint = '/api/subcategories';
  static String getSubcategoriesByCategoryEndpoint(String categoryName) =>
      '/api/category/$categoryName/subcategories';

  // Banner endpoints
  static const String bannerEndpoint = '/api/banner';

  // Product endpoints
  static const String addProductEndpoint = '/api/add-product';
  static const String popularProductsEndpoint = '/api/popular-products';
  static const String recommendedProductsEndpoint = '/api/recommended-products';

  // Full URLs
  static String get categories => '$apiUrl$categoriesEndpoint';
  static String get subcategories => '$apiUrl$subcategoriesEndpoint';
  static String getSubcategoriesByCategory(String categoryName) =>
      '$apiUrl${getSubcategoriesByCategoryEndpoint(categoryName)}';
  static String get banner => '$apiUrl$bannerEndpoint';
  static String get addProduct => '$apiUrl$addProductEndpoint';
  static String get popularProducts => '$apiUrl$popularProductsEndpoint';
  static String get recommendedProducts =>
      '$apiUrl$recommendedProductsEndpoint';

  // Headers
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Headers with token
  static Map<String, String> getAuthHeaders(String token) => {
        ...headers,
        'Authorization': 'Bearer $token',
      };
}
