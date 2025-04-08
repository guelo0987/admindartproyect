import 'dart:convert';
import 'dart:io';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:file_picker/file_picker.dart';
import '../../controllers/banner_service.dart';
import '../../models/banners.dart' as app_banner;

class UploadBannerScreen extends StatefulWidget {
  const UploadBannerScreen({Key? key}) : super(key: key);

  @override
  _UploadBannerScreenState createState() => _UploadBannerScreenState();
}

class _UploadBannerScreenState extends State<UploadBannerScreen> {
  final _formKey = GlobalKey<FormState>();
  dynamic _selectedImage;
  String? _imageUrl;
  List<app_banner.Banner> _banners = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBanners();
  }

  Future<void> _loadBanners() async {
    setState(() {
      _isLoading = true;
    });

    final response = await BannerService.getBanners();

    if (response.success) {
      setState(() {
        _banners = response.data ?? [];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar banners: ${response.message}')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
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

  void _save() async {
    if (_selectedImage != null) {
      String imageBase64;

      if (kIsWeb) {
        imageBase64 = _imageUrl!;
      } else {
        final bytes = await _selectedImage.readAsBytes();
        imageBase64 = 'data:image/jpeg;base64,${base64.encode(bytes)}';
      }

      final response = await BannerService.uploadBanner(image: imageBase64);

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Banner subido exitosamente')),
        );
        _loadBanners();
        _cancel();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.message}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor seleccione una imagen')),
      );
    }
  }

  void _cancel() {
    setState(() {
      _selectedImage = null;
      _imageUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Subir Banner'),
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
        selectedRoute: '/banners',
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Subir Nuevo Banner',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildImagePreview(),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('Seleccionar Banner'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _save,
                          child: const Text('Subir'),
                        ),
                        ElevatedButton(
                          onPressed: _cancel,
                          child: const Text('Cancelar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Banners Existentes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildBannersList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_selectedImage == null) {
      return const Text('No se ha seleccionado ningún banner.');
    }

    if (kIsWeb) {
      return Image.network(_imageUrl!, height: 200);
    } else {
      return Image.file(_selectedImage, height: 200);
    }
  }

  Widget _buildBannersList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_banners.isEmpty) {
      return const Center(child: Text('No hay banners disponibles.'));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2,
      ),
      itemCount: _banners.length,
      itemBuilder: (context, index) {
        final banner = _banners[index];
        return Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.network(
              banner.image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(child: Text('Error al cargar la imagen'));
              },
            ),
          ),
        );
      },
    );
  }
}
