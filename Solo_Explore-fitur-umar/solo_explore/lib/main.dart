import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart'; // 🟢 WAJIB TAMBAH: Untuk mendaftarkan database lokal bahasa
import 'core/theme.dart';
import 'core/app_router.dart';

// 🟢 FIX: Mengubah main menjadi async agar bisa menunggu proses inisialisasi lokal selesai
void main() async {
  // 🟢 FIX: Memastikan seluruh binding framework Flutter siap sebelum menjalankan kode async
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🟢 FIX: Daftarkan bahasa Indonesia ('id_ID') ke dalam sistem formatter intl secara global
  await initializeDateFormatting('id_ID', null);

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
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}