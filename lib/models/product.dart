class Product {
  final String productName;
  final double productPrice;
  final int quantity;
  final String description;
  final String category;
  final String subCategory;
  final List<String> images;
  final bool popular;
  final bool recommend;

  Product({
    required this.productName,
    required this.productPrice,
    required this.quantity,
    required this.description,
    required this.category,
    required this.subCategory,
    required this.images,
    this.popular = true,
    this.recommend = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productName: json['productName'] ?? '',
      productPrice: (json['productPrice'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      subCategory: json['subCategory'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      popular: json['popular'] ?? true,
      recommend: json['recommend'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'productPrice': productPrice,
      'quantity': quantity,
      'description': description,
      'category': category,
      'subCategory': subCategory,
      'images': images,
      'popular': popular,
      'recommend': recommend,
    };
  }
}
