import 'dart:convert';
import 'dart:io';
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:file_picker/file_picker.dart';
import '../../controllers/category_service.dart';
import '../../controllers/sub-category_service.dart';
import '../../models/category.dart';
import '../../models/sub-category.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _categoryFormKey = GlobalKey<FormState>();
  final _subcategoryFormKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subcategoryNameController = TextEditingController();
  dynamic _selectedImage; // Can be File or html.File depending on platform
  String? _imageUrl; // For web preview
  String? _selectedCategoryId;
  String? _selectedCategoryName;

  // Add state variables for categories list
  List<Category> _categories = [];
  Map<String, List<SubCategory>> _subcategories = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);

    final response = await CategoryService.getCategories();
    if (response.success && response.data != null) {
      setState(() {
        _categories = response.data!;
        // Cargar subcategorías para cada categoría
        for (var category in _categories) {
          _loadSubcategories(category.name);
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error al cargar categorías: ${response.message}')),
      );
    }

    setState(() => _isLoading = false);
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

  // Método para seleccionar imagen usando file_picker
  Future<void> _pickImage() async {
    if (kIsWeb) {
      // Web implementation
      final html.FileUploadInputElement input = html.FileUploadInputElement()
        ..accept = 'image/*';
      input.click();

      await input.onChange.first;
      if (input.files!.isNotEmpty) {
        final file = input.files![0];
        final reader = html.FileReader();
        reader.readAsDataUrl(file);
        await reader.onLoad.first;
        setState(() {
          _selectedImage = file;
          _imageUrl = reader.result as String;
        });
      }
    } else {
      // Mobile implementation
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedImage = File(result.files.single.path!);
        });
      }
    }
  }

  void _saveCategory() async {
    if (_categoryFormKey.currentState!.validate() && _selectedImage != null) {
      String title = _titleController.text;
      String imageBase64;

      if (kIsWeb) {
        imageBase64 = _imageUrl!;
      } else {
        final bytes = await _selectedImage.readAsBytes();
        imageBase64 = 'data:image/jpeg;base64,${base64.encode(bytes)}';
      }

      final response = await CategoryService.createCategory(
        name: title,
        image: imageBase64,
        banner: imageBase64,
      );

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Categoría guardada exitosamente')),
        );
        _cancelCategory();
        _loadCategories(); // Reload categories after saving
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.message}')),
        );
      }
    }
  }

  void _saveSubcategory() async {
    if (_subcategoryFormKey.currentState!.validate() &&
        _selectedImage != null &&
        _selectedCategoryId != null) {
      String imageBase64;

      if (kIsWeb) {
        imageBase64 = _imageUrl!;
      } else {
        final bytes = await _selectedImage.readAsBytes();
        imageBase64 = 'data:image/jpeg;base64,${base64.encode(bytes)}';
      }

      final response = await SubCategoryService.createSubCategory(
        categoryId: _selectedCategoryId!,
        categoryName: _selectedCategoryName!,
        image: imageBase64,
        subCategoryName: _subcategoryNameController.text,
      );

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subcategoría guardada exitosamente')),
        );
        _cancelSubcategory();
        if (_selectedCategoryName != null) {
          _loadSubcategories(_selectedCategoryName!);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.message}')),
        );
      }
    }
  }

  void _cancelCategory() {
    _titleController.clear();
    setState(() {
      _selectedImage = null;
      _imageUrl = null;
    });
  }

  void _cancelSubcategory() {
    _subcategoryNameController.clear();
    setState(() {
      _selectedImage = null;
      _imageUrl = null;
      _selectedCategoryId = null;
      _selectedCategoryName = null;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subcategoryNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String currentRoute =
        ModalRoute.of(context)?.settings.name ?? '/categorias';

    return AdminScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Categorias'),
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
        selectedRoute: currentRoute,
        onSelected: (item) {
          if (item.route != null && item.route != currentRoute) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Categories Form
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Crear Nueva Categoría',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Form(
                        key: _categoryFormKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                labelText: 'Título',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingrese un título';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildImagePreview(),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _pickImage,
                              child: const Text('Seleccionar imagen'),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: _saveCategory,
                                  child: const Text('Guardar'),
                                ),
                                ElevatedButton(
                                  onPressed: _cancelCategory,
                                  child: const Text('Cancelar'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Subcategories Form
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Crear Nueva Subcategoría',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Form(
                        key: _subcategoryFormKey,
                        child: Column(
                          children: [
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
                                  // Find the category ID
                                  _selectedCategoryId = _categories
                                      .firstWhere((cat) => cat.name == value)
                                      .name;
                                });
                                if (value != null) {
                                  _loadSubcategories(value);
                                }
                              },
                              validator: (value) => value == null
                                  ? 'Seleccione una categoría'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _subcategoryNameController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre de Subcategoría',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) => value?.isEmpty ?? true
                                  ? 'Campo requerido'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            _buildImagePreview(),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _pickImage,
                              child: const Text('Seleccionar imagen'),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: _saveSubcategory,
                                  child: const Text('Guardar Subcategoría'),
                                ),
                                ElevatedButton(
                                  onPressed: _cancelSubcategory,
                                  child: const Text('Cancelar'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Categories and Subcategories List
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Categorías y Subcategorías',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            return ExpansionTile(
                              title: Text(category.name),
                              leading: Image.network(
                                category.image,
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                              ),
                              children: [
                                if (_subcategories[category.name] != null)
                                  ...(_subcategories[category.name]!
                                      .map((subcategory) => ListTile(
                                            leading: Image.network(
                                              subcategory.image,
                                              height: 40,
                                              width: 40,
                                              fit: BoxFit.cover,
                                            ),
                                            title: Text(
                                                subcategory.subCategoryName),
                                          ))
                                      .toList())
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_selectedImage == null) {
      return const Text('No se ha seleccionado ninguna imagen.');
    }

    if (kIsWeb) {
      return Image.network(_imageUrl!, height: 200);
    } else {
      return Image.file(_selectedImage, height: 200);
    }
  }
}
