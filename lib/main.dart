// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/settings_repository.dart';
import 'services/bluetooth_service.dart';
import 'services/alert_service.dart';
import 'presentation/screens/home_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar with dark icons
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.bgCard,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize repository
  final repo = await SettingsRepository.getInstance();

  runApp(SecureGuardApp(repo: repo));
}

class SecureGuardApp extends StatelessWidget {
  final SettingsRepository repo;

  const SecureGuardApp({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BluetoothService>(
          create: (_) => BluetoothService(),
        ),
        ChangeNotifierProxyProvider<BluetoothService, AlertService>(
          create: (ctx) => AlertService(
            bluetoothService: ctx.read<BluetoothService>(),
            repo: repo,
          ),
          update: (ctx, bt, prev) =>
              prev ??
              AlertService(
                bluetoothService: bt,
                repo: repo,
              ),
        ),
      ],
      child: MaterialApp(
        title: 'SecureGuard',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const HomeShell(),
        builder: (context, child) {
          // Ensure text doesn't scale beyond design limits
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(
                MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
              ),
            ),
            child: child!,
          );
        },
      ),
    );
  }
}
