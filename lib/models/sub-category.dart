class SubCategory {
  final String categoryId;
  final String categoryName;
  final String image;
  final String subCategoryName;

  SubCategory({
    required this.categoryId,
    required this.categoryName,
    required this.image,
    required this.subCategoryName,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? '',
      image: json['image'] ?? '',
      subCategoryName: json['subCategoryName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'image': image,
      'subCategoryName': subCategoryName,
    };
  }
}
