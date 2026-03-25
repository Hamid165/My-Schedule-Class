import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/schedule.dart';
import 'providers/schedule_provider.dart';
import 'providers/theme_provider.dart';
import 'services/schedule_service.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ─── Inisialisasi Hive (database lokal) ───
  await Hive.initFlutter();

  // Daftarkan TypeAdapter untuk model Schedule
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(ScheduleAdapter());
  }

  // Buat dan inisialisasi ScheduleService
  final scheduleService = ScheduleService();
  await scheduleService.init();

  runApp(
    // ─── Multi-Provider setup ───
    MultiProvider(
      providers: [
        // Theme provider
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // Schedule provider - inject service sebagai dependency
        ChangeNotifierProvider(
          create: (_) => ScheduleProvider(scheduleService),
        ),
      ],
      child: const JadwalKelasApp(),
    ),
  );
}

/// Root widget aplikasi
class JadwalKelasApp extends StatelessWidget {
  const JadwalKelasApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Jadwal Kuliah',
      debugShowCheckedModeBanner: false,

      // Tema dari AppTheme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,

      home: const HomeScreen(),
    );
  }
}
