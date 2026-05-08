import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/inggo_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/services/supabase_service.dart';
import 'l10n/app_localizations.dart';
import 'provider/auth_provider.dart';
import 'provider/driver_provider.dart';

class InggoApp extends ConsumerStatefulWidget {
  const InggoApp({super.key});

  @override
  ConsumerState<InggoApp> createState() => _InggoAppState();
}

class _InggoAppState extends ConsumerState<InggoApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Start listening for notifications as soon as the app builds
    // and the user is authenticated. We use a post-frame callback
    // so that the auth state is already resolved.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeStartNotifications();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When the app goes to background or is closed, set driver offline
    if (state == AppLifecycleState.detached || state == AppLifecycleState.paused) {
      _goDriverOffline();
    }
    // When the app comes back to foreground, re-sync driver state
    if (state == AppLifecycleState.resumed) {
      _syncDriverState();
    }
  }

  void _goDriverOffline() {
    final driverState = ref.read(driverProvider);
    if (driverState.isOnline) {
      final userId = SupabaseService.instance.currentUserId;
      if (userId != null) {
        // Fire and forget — don't block the lifecycle transition
        SupabaseService.instance.update('drivers', userId, {
          'is_online': false,
        });
      }
    }
  }

  void _syncDriverState() {
    final driverState = ref.read(driverProvider);
    if (driverState.driver != null) {
      ref.read(driverProvider.notifier).loadDriver();
    }
  }

  void _maybeStartNotifications() {
    final authState = ref.read(authProvider);
    final userId = authState.user?.id;
    if (userId != null && authState.isAuthenticated) {
      NotificationService.instance.startListening(userId);
    }

    // Listen for auth changes to start/stop notifications
    ref.listen<AuthState>(authProvider, (prev, next) {
      final newUserId = next.user?.id;
      if (next.isAuthenticated && newUserId != null) {
        NotificationService.instance.startListening(newUserId);
      } else {
        NotificationService.instance.stopListening();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Inggo',
          debugShowCheckedModeBanner: false,
          theme: InggoTheme.light,
          darkTheme: InggoTheme.dark,
          themeMode: ThemeMode.light,
          locale: authState.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
