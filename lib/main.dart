import 'package:admindartproyect/views/main_screen.dart';
import 'package:admindartproyect/views/sidebar_screens/upload_banner_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(AdminApp());

class AdminApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Panel',
      initialRoute: '/',
      routes: {
        '/': (context) => MyApp(),
        '/banners': (context) => UploadBannerScreen(),
      },
      onGenerateRoute: (settings) {
        // If a named route is requested but not defined in routes, this is called
        print('Route ${settings.name} not found, redirecting to home');
        return MaterialPageRoute(builder: (context) => MyApp());
      },
    );
  }
}
