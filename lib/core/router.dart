import 'package:go_router/go_router.dart';
import '/screen/shared/splash_screen.dart';
import '/screen/shared/login_screen.dart';
import '/screen/customer/registration_screen.dart';
import '/screen/customer/booking_screen.dart';
import '/screen/customer/profil_screen.dart';
import '/screen/customer/settings_screen.dart';
import '/screen/customer/edit_phone_screen.dart';
import '/screen/customer/support_screen.dart';
import '/screen/customer/cgu_screen.dart';
import '/screen/customer/privacy_screen.dart';
import '/screen/customer/history_screen.dart';
import '/screen/customer/favorites_screen.dart';
import '/screen/customer/notifications_screen.dart';
import '/screen/customer/searching_driver.dart';
import '/screen/customer/trip_in_progress.dart';
import '/screen/customer/end_off_trip.dart';
import '/screen/driver/registration_screen.dart';
import '/screen/driver/pending_screen.dart';
import '/screen/driver/driver_dashboard_shell.dart';
import '/screen/shared/forgot_password_screen.dart';
import '/screen/driver/ride_screen.dart';
import '/screen/driver/ride_request_screen.dart';
import '/screen/driver/history_screen.dart' as driver_history;
import '/screen/driver/documents_screen.dart';
import '/screen/driver/vehicle_screen.dart';
import '/screen/driver/banking_screen.dart';
import '/screen/driver/settings_screen.dart' as driver_settings;
import '/screen/driver/support_screen.dart' as driver_support;
import '/screen/driver/legal_screen.dart';
import '/screen/admin/app/admin_app.dart';

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    // ── Routes Client ──
    GoRoute(
      path: '/register',
      builder: (context, state) => const CustomerRegistrationScreen(),
    ),
    GoRoute(
      path: '/booking',
      builder: (context, state) => const RideBookingScreen(),
    ),

    // ── Routes Profil ──
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfilScreen(),
    ),
    GoRoute(
      path: '/profile/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/profile/edit-phone',
      builder: (context, state) => const EditPhoneScreen(),
    ),
    GoRoute(
      path: '/profile/support',
      builder: (context, state) => const SupportScreen(),
    ),
    GoRoute(
      path: '/profile/cgu',
      builder: (context, state) => const CguScreen(),
    ),
    GoRoute(
      path: '/profile/privacy',
      builder: (context, state) => const PrivacyScreen(),
    ),
    GoRoute(
      path: '/profile/history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/profile/favorites',
      builder: (context, state) => const FavoritesScreen(),
    ),

    // ── Route Notifications ──
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),

    // ── Routes Course ──
    GoRoute(
      path: '/searching',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return SearchScreen(rideId: extra?['rideId']);
      },
    ),
    GoRoute(
      path: '/trip-in-progress',
      builder: (context, state) => const TripInProgressScreen(),
    ),
    GoRoute(
      path: '/end-of-trip',
      builder: (context, state) => const EndOfTripScreen(),
    ),

    // ── Routes Conducteur (NOUVELLES) ──
    GoRoute(
      path: '/driver-register',
      builder: (context, state) => const DriverRegistrationScreen(),
    ),
    GoRoute(
      path: '/driver-pending',
      builder: (context, state) => const DriverPendingScreen(),
    ),
    GoRoute(
      path: '/driver-dashboard',
      builder: (context, state) => const DriverDashboardShell(),
    ),
    GoRoute(
      path: '/ride',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return RideScreen(
          rideId: extra?['rideId'],
          pickupAddress: extra?['pickupAddress'],
          dropoffAddress: extra?['dropoffAddress'],
          price: extra?['price'],
          clientName: extra?['clientName'],
        );
      },
    ),
    GoRoute(
      path: '/driver-history',
      builder: (context, state) => const driver_history.DriverHistoryScreen(),
    ),
    GoRoute(
      path: '/ride-request',
      builder: (context, state) => const RideRequestScreen(),
    ),
    GoRoute(
      path: '/driver-documents',
      builder: (context, state) => const DocumentsScreen(),
    ),
    GoRoute(
      path: '/driver-vehicle',
      builder: (context, state) => const VehicleScreen(),
    ),
    GoRoute(
      path: '/driver-banking',
      builder: (context, state) => const BankingScreen(),
    ),
    GoRoute(
      path: '/driver-settings',
      builder: (context, state) => const driver_settings.DriverSettingsScreen(),
    ),
    GoRoute(
      path: '/driver-support',
      builder: (context, state) => const driver_support.DriverSupportScreen(),
    ),
    GoRoute(
      path: '/driver-legal',
      builder: (context, state) => LegalScreen(type: state.extra as LegalType),
    ),

    // ── Routes Admin ──
    GoRoute(
      path: '/admin',
      redirect: (context, state) => '/admin/dashboard',
    ),
    GoRoute(
      path: '/admin/dashboard',
      builder: (context, state) => const AdminApp(),
    ),
  ],
);
