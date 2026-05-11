import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../screen/splash/splash_screen.dart';
import '../../screen/auth/login_screen.dart';
import '../../screen/auth/register_client_screen.dart';
import '../../screen/auth/register_driver_screen.dart';
import '../../screen/auth/pending_verification_screen.dart';
import '../../screen/customer/home_screen.dart';
import '../../screen/customer/search_screen.dart';
import '../../screen/customer/booking_screen.dart';
import '../../screen/customer/searching_driver_screen.dart';
import '../../screen/customer/trip_in_progress_screen.dart';
import '../../screen/customer/end_trip_screen.dart';
import '../../screen/customer/history_screen.dart';
import '../../screen/customer/favorites_screen.dart';
import '../../screen/customer/profile_screen.dart';
import '../../screen/customer/settings_screen.dart';
import '../../screen/customer/notifications_screen.dart';
import '../../screen/customer/support_screen.dart';
import '../../screen/customer/edit_profile_screen.dart';
import '../../screen/driver/home_screen.dart';
import '../../screen/driver/ride_request_screen.dart';
import '../../screen/driver/ride_screen.dart';
import '../../screen/driver/end_ride_screen.dart';
import '../../screen/driver/earnings_screen.dart';
import '../../screen/driver/documents_screen.dart';
import '../../screen/driver/driver_profile_screen.dart';
import '../../screen/driver/driver_settings_screen.dart';
import '../../screen/common/about_screen.dart';
import '../../model/ride_model.dart';

class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter get router => _router;

  static final _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;
      final currentPath = state.matchedLocation;

      // Public routes - no auth needed
      final publicRoutes = ['/splash', '/login', '/register-client', '/register-driver', '/pending-verification'];

      // Registration pages are allowed even with a session
      // (OTP verification creates a temporary session during signup)
      final registrationRoutes = ['/register-client', '/register-driver'];

      // Authenticated user on login/register → redirect to home
      // But allow staying on registration pages during OTP verification
      if (session != null && !registrationRoutes.contains(currentPath) && currentPath != '/splash' && currentPath != '/pending-verification') {
        if (publicRoutes.contains(currentPath)) {
          return '/client/home';
        }
      }

      // Not logged in → login
      if (session == null && !publicRoutes.contains(currentPath)) {
        return '/login';
      }

      return null;
    },
    routes: [
      // ─── Splash ───
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // ─── Auth ───
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register-client',
        builder: (context, state) => const RegisterClientScreen(),
      ),
      GoRoute(
        path: '/register-driver',
        builder: (context, state) => const RegisterDriverScreen(),
      ),
      GoRoute(
        path: '/pending-verification',
        builder: (context, state) => const PendingVerificationScreen(),
      ),

      // ─── Common Routes ───
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/support',
        builder: (context, state) => const SupportScreen(),
      ),

      // ─── Client Routes ───
      GoRoute(
        path: '/client/home',
        builder: (context, state) => const CustomerHomeScreen(),
      ),
      GoRoute(
        path: '/client/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/client/booking',
        builder: (context, state) => const BookingScreen(),
      ),
      GoRoute(
        path: '/client/searching',
        builder: (context, state) => const SearchingDriverScreen(),
      ),
      GoRoute(
        path: '/client/trip',
        builder: (context, state) => const TripInProgressScreen(),
      ),
      GoRoute(
        path: '/client/end-trip',
        builder: (context, state) => const EndTripScreen(),
      ),
      GoRoute(
        path: '/client/history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/client/favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/client/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/client/edit-profile',
        builder: (context, state) => const EditProfileScreen(isDriver: false),
      ),
      GoRoute(
        path: '/client/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/client/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/client/support',
        builder: (context, state) => const SupportScreen(),
      ),

      // ─── Driver Routes ───
      GoRoute(
        path: '/driver/home',
        builder: (context, state) => const DriverHomeScreen(),
      ),
      GoRoute(
        path: '/driver/ride-request',
        builder: (context, state) {
          final ride = state.extra as RideModel?;
          if (ride == null) return const DriverHomeScreen();
          return RideRequestScreen(ride: ride);
        },
      ),
      GoRoute(
        path: '/driver/ride',
        builder: (context, state) => const DriverRideScreen(),
      ),
      GoRoute(
        path: '/driver/end-ride',
        builder: (context, state) => const EndRideScreen(),
      ),
      GoRoute(
        path: '/driver/earnings',
        builder: (context, state) => const EarningsScreen(),
      ),
      GoRoute(
        path: '/driver/documents',
        builder: (context, state) => const DocumentsScreen(),
      ),
      GoRoute(
        path: '/driver/profile',
        builder: (context, state) => const DriverProfileScreen(),
      ),
      GoRoute(
        path: '/driver/edit-profile',
        builder: (context, state) => const EditProfileScreen(isDriver: true),
      ),
      GoRoute(
        path: '/driver/settings',
        builder: (context, state) => const DriverSettingsScreen(),
      ),
    ],
  );
}
