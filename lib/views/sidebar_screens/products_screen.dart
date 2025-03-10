import 'dart:convert';
import 'dart:io';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:file_picker/file_picker.dart';
import '../../controllers/product_service.dart';
import '../../controllers/category_service.dart';
import '../../controllers/sub-category_service.dart';
import '../../models/product.dart';
import '../../models/category.dart';
import '../../models/sub-category.dart';
import 'dart:typed_data';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Variables para categorías y subcategorías
  List<Category> _categories = [];
  Map<String, List<SubCategory>> _subcategories = {};
  String? _selectedCategoryName;
  String? _selectedSubcategoryName;

  List<String> _selectedImages = [];
  List<String?> _imageUrls = [];
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCategories();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final popularResponse = await ProductService.getPopularProducts();
    final recommendedResponse = await ProductService.getRecommendedProducts();

    if (popularResponse.success && popularResponse.data != null) {
      setState(() {
        _products.addAll(popularResponse.data!);
      });
    }

    if (recommendedResponse.success && recommendedResponse.data != null) {
      setState(() {
        _products.addAll(recommendedResponse.data!);
      });
    }

    setState(() => _isLoading = false);
  }

  Future<void> _loadCategories() async {
    final response = await CategoryService.getCategories();
    if (response.success && response.data != null) {
      setState(() {
        _categories = response.data!;
      });
    }
  }

  Future<void> _loadSubcategories(String categoryName) async {
    final response =
        await SubCategoryService.getSubcategoriesByCategory(categoryName);
    if (response.success && response.data != null) {
      setState(() {
        _subcategories[categoryName] = response.data!;
      });
    }
  }

  Future<void> _pickImages() async {
    if (kIsWeb) {
      final html.FileUploadInputElement input = html.FileUploadInputElement()
        ..accept = 'image/*'
        ..multiple = true;
      input.click();

      await input.onChange.first;
      if (input.files!.isNotEmpty) {
        setState(() {
          _selectedImages = [];
          _imageUrls = [];
        });

        for (var file in input.files!) {
          final reader = html.FileReader();
          reader.readAsDataUrl(file);
          await reader.onLoad.first;
          setState(() {
            _selectedImages.add(file.name);
            _imageUrls.add(reader.result as String);
          });
        }
      }
    } else {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _selectedImages = result.paths
              .where((path) => path != null)
              .map((path) => path!)
              .toList();
        });
      }
    }
  }

  void _save() async {
    if (_formKey.currentState!.validate() && _selectedImages.isNotEmpty) {
      List<String> imageBase64List = [];

      if (kIsWeb) {
        imageBase64List = _imageUrls.map((url) {
          if (url != null) {
            if (!url.startsWith('data:')) {
              return 'data:image/jpeg;base64,${url.split(',').last}';
            }
            return _compressBase64Image(url);
          }
          return '';
        }).toList();
      } else {
        for (String imagePath in _selectedImages) {
          final bytes = await File(imagePath).readAsBytes();
          final compressedBytes = await _compressImageBytes(bytes);
          imageBase64List
              .add('data:image/jpeg;base64,${base64.encode(compressedBytes)}');
        }
      }

      final response = await ProductService.addProduct(
        productName: _nameController.text,
        productPrice: double.parse(_priceController.text),
        quantity: int.parse(_quantityController.text),
        description: _descriptionController.text,
        category: _selectedCategoryName ?? '',
        subCategory: _selectedSubcategoryName ?? '',
        images: imageBase64List,
      );

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto guardado exitosamente')),
        );
        _cancel();
        _loadProducts();
      } else {
        print('Error details: ${response.statusCode} - ${response.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Error: ${response.message ?? "Error desconocido"}')),
        );
      }
    }
  }

  void _cancel() {
    _nameController.clear();
    _priceController.clear();
    _quantityController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedImages = [];
      _imageUrls = [];
      _selectedCategoryName = null;
      _selectedSubcategoryName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Productos'),
      ),
      sideBar: SideBar(
        items: [
          AdminMenuItem(
            title: 'Dashboard',
            route: '/dashboard',
            icon: Icons.dashboard,
          ),
          AdminMenuItem(
            title: 'Categorias',
            route: '/categorias',
            icon: Icons.category,
          ),
          AdminMenuItem(
            title: 'Buyers',
            route: '/buyers',
            icon: Icons.people,
          ),
          AdminMenuItem(
            title: 'Ordenes',
            route: '/ordenes',
            icon: Icons.shopping_bag,
          ),
          AdminMenuItem(
            title: 'Productos',
            route: '/productos',
            icon: Icons.production_quantity_limits_sharp,
          ),
          AdminMenuItem(
            title: 'Banners',
            route: '/banners',
            icon: Icons.backup,
          ),
          AdminMenuItem(
            title: 'Vendedores',
            route: '/vendedores',
            icon: Icons.people_alt_outlined,
          ),
        ],
        selectedRoute: '/productos',
        onSelected: (item) {
          if (item.route != null) {
            Navigator.of(context).pushReplacementNamed(item.route!);
          }
        },
        header: Container(
          height: 50,
          width: double.infinity,
          color: const Color(0xff444444),
          child: const Center(
            child: Text(
              'header',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        footer: Container(
          height: 50,
          width: double.infinity,
          color: const Color(0xff444444),
          child: const Center(
            child: Text(
              'footer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Producto',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Precio',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Cantidad',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),
                // Dropdown para categorías
                DropdownButtonFormField<String>(
                  value: _selectedCategoryName,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category.name,
                      child: Text(category.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryName = value;
                      _selectedSubcategoryName = null;
                    });
                    if (value != null) {
                      _loadSubcategories(value);
                    }
                  },
                  validator: (value) =>
                      value == null ? 'Seleccione una categoría' : null,
                ),
                const SizedBox(height: 16),
                // Dropdown para subcategorías
                DropdownButtonFormField<String>(
                  value: _selectedSubcategoryName,
                  decoration: const InputDecoration(
                    labelText: 'Subcategoría',
                    border: OutlineInputBorder(),
                  ),
                  items: (_selectedCategoryName != null &&
                          _subcategories[_selectedCategoryName] != null)
                      ? _subcategories[_selectedCategoryName]!
                          .map((subcategory) {
                          return DropdownMenuItem(
                            value: subcategory.subCategoryName,
                            child: Text(subcategory.subCategoryName),
                          );
                        }).toList()
                      : [],
                  onChanged: (value) {
                    setState(() {
                      _selectedSubcategoryName = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Seleccione una subcategoría' : null,
                ),
                const SizedBox(height: 16),
                _buildImagesPreview(),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _pickImages,
                  child: const Text('Seleccionar Imágenes'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _save,
                      child: const Text('Guardar'),
                    ),
                    ElevatedButton(
                      onPressed: _cancel,
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  'Productos Existentes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_products.isEmpty)
                  const Text('No hay productos disponibles')
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: Image.network(
                            product.images.first,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(product.productName),
                          subtitle: Text(
                            'Precio: \$${product.productPrice.toStringAsFixed(2)}\n'
                            'Cantidad: ${product.quantity}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  // Implementar edición de producto
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  // Implementar eliminación de producto
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagesPreview() {
    if (_selectedImages.isEmpty) {
      return const Text('No se han seleccionado imágenes.');
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length,
        itemBuilder: (context, index) {
          if (kIsWeb) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.network(_imageUrls[index]!, height: 200),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.file(File(_selectedImages[index]), height: 200),
            );
          }
        },
      ),
    );
  }

  String _compressBase64Image(String base64Image) {
    final parts = base64Image.split(',');
    final mimeType = parts[0];
    final imageData = parts[1];

    final decodedBytes = base64.decode(imageData);

    if (decodedBytes.length > 100000) {
      final compressedData = imageData.substring(0, imageData.length ~/ 2);
      return '$mimeType,$compressedData';
    }

    return base64Image;
  }

  Future<Uint8List> _compressImageBytes(Uint8List bytes) async {
    return bytes;
  }
}
