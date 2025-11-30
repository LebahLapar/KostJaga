import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/splash_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/kost_provider.dart';
import 'providers/tenant_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/complaint_provider.dart';


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
  
  // Load .env file - WAJIB ada!
  try {
    await dotenv.load(fileName: ".env");
    print('✅ Environment variables loaded successfully');
  } catch (e) {
    print('❌ ERROR: .env file not found!');
    print('📝 Please create .env file with your Supabase credentials');
    print('💡 See .env.example for template');
    rethrow;
  }
  
  
  await initializeDateFormatting('id_ID', null);
  
  
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  
  print('✅ Supabase initialized successfully');
  
  runApp(const JagaKostApp());
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
      ],
      child: MaterialApp(
        title: 'JagaKost',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6C63FF),
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}