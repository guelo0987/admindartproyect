import 'package:admindartproyect/views/sidebar_screens/categories_screen.dart';
import 'package:admindartproyect/views/sidebar_screens/upload_banner_screen.dart';
import 'package:admindartproyect/views/sidebar_screens/products_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Este widget es el punto de entrada de la aplicación
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Dashboard',
      initialRoute: '/dashboard',
      routes: {
        '/dashboard': (context) => SamplePage(title: 'Dashboard'),
        '/categorias': (context) => CategoriesScreen(),
        '/buyers': (context) => SamplePage(title: 'Buyers'),
        '/ordenes': (context) => SamplePage(title: 'Ordenes'),
        '/productos': (context) => ProductsScreen(),
        '/banners': (context) => UploadBannerScreen(),
        '/vendedores': (context) => SamplePage(title: 'Vendedores'),
      },
    );
  }
}

class SamplePage extends StatelessWidget {
  final String title;

  const SamplePage({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Obtenemos la ruta actual para indicar la selección en el menú
    final String currentRoute =
        ModalRoute.of(context)?.settings.name ?? '/dashboard';

    return AdminScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(title),
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
              style: TextStyle(
                color: Colors.white,
              ),
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
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.all(10),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 36,
            ),
          ),
        ),
      ),
    );
  }
}
