class Category {
  final String name;
  final String image;
  final String banner;

  Category({
    required this.name,
    required this.image,
    required this.banner,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      banner: json['banner'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'banner': banner,
    };
  }
}
