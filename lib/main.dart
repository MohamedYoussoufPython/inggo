import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'core/services/connectivity_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment (optional — .env may not exist during CI/debug builds)
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env file not found — will use empty defaults or fallback values
  }

  // Init Supabase — fail fast with clear error if config missing
  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    debugPrint('═══════════════════════════════════════════════════');
    debugPrint('ERREUR FATALE: SUPABASE_URL et/ou SUPABASE_ANON_KEY manquants.');
    debugPrint('Vérifiez que le fichier .env existe à la racine du projet.');
    debugPrint('═══════════════════════════════════════════════════');
    // Fail fast — don't attempt to initialize Supabase with empty credentials
    throw StateError(
      'SUPABASE_URL et SUPABASE_ANON_KEY sont requis dans le fichier .env. '
      'Copiez .env.example vers .env et remplissez les valeurs.',
    );
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // Start connectivity monitoring
  ConnectivityService.instance.startMonitoring();

  // System UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: InggoApp()));
}
