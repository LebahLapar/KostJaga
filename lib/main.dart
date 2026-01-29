import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/splash_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/kost_provider.dart';
import 'providers/tenant_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/complaint_provider.dart';
import 'providers/tenant_auth_provider.dart';
import 'theme/app_theme.dart';

String get supabaseUrl {
  final url = dotenv.env['SUPABASE_URL'];
  if (url == null || url.isEmpty) {
    throw Exception(
      '❌ SUPABASE_URL not found!\n'
      'Please create .env file in project root with:\n'
      'SUPABASE_URL=your_supabase_url'
    );
  }
  return url;
}

String get supabaseAnonKey {
  final key = dotenv.env['SUPABASE_ANON_KEY'];
  if (key == null || key.isEmpty) {
    throw Exception(
      '❌ SUPABASE_ANON_KEY not found!\n'
      'Please create .env file in project root with:\n'
      'SUPABASE_ANON_KEY=your_supabase_anon_key'
    );
  }
  return key;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load .env file
  try {
    await dotenv.load(fileName: ".env");
    print('✅ Environment variables loaded');
  } catch (e) {
    print('❌ ERROR: .env file not found!');
    rethrow;
  }
  
  await initializeDateFormatting('id_ID', null);
  
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  
  print('✅ Supabase initialized');
  
  runApp(const JagaKostApp());
}

/// Theme Mode Provider for dark/light mode switching
class ThemeModeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == 
          Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}

class JagaKostApp extends StatelessWidget {
  const JagaKostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => KostProvider()),
        ChangeNotifierProvider(create: (_) => TenantProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => ComplaintProvider()),
        ChangeNotifierProvider(create: (_) => TenantAuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeModeProvider()),
      ],
      child: Consumer<ThemeModeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'JagaKost',
            debugShowCheckedModeBanner: false,
            
            // Theme Configuration
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}