import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme.dart';
import 'core/app_router.dart'; // Aktifkan lagi import ini

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setting status bar agar transparan
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const SoloExploreApp());
}

class SoloExploreApp extends StatelessWidget {
  const SoloExploreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoloExplore',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      
      // Kembalikan ke sistem rute utama agar login_screen bisa bekerja
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.generateRoute,
      
      // Baris 'home' dihapus karena kita pakai initialRoute
    );
  }
}