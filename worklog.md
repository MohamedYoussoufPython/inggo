---
Task ID: 1
Agent: Main Agent
Task: Build Inggo VTC Flutter app from ZERO + Admin Panel Flask

Work Log:
- Created complete project structure from scratch
- Wrote pubspec.yaml with all required packages (riverpod, go_router, supabase, google_maps, freezed, etc.)
- Wrote analysis_options.yaml with 12 Inggo coding rules
- Created design system: AppColors, AppSpacing, AppTextStyles, AppShadows, AppConstants
- Created InggoTheme (light + dark) with Inter font and #FFC107 primary
- Created AppRouter with GoRouter (all routes + auth redirects)
- Created l10n system (AppLocalizations FR/EN)
- Created utility files: Formatters, Validators, Helpers
- Created extensions: ContextExtensions, StringExtensions
- Created main.dart + app.dart with Supabase + ProviderScope
- Created 8 Freezed models: UserModel, DriverModel, RideModel, PaymentModel, ReviewModel, FavoriteModel, NotificationModel, LandmarkModel
- Created 5 services: SupabaseService, LocationService (5s throttle), NotificationService (Realtime), PaymentService, ConnectivityService
- Created 13 widgets: InggoButton, InggoInput, InggoPhoneInput, InggoOtpInput, InggoCard, RideSummaryCard, InggoBottomNav, InggoToast, InggoBadge, RideStatusBadge, InggoLoading, InggoAppBar, MapWidget, PaymentMethodSelector, OfflineBanner, DriverCard, LanguageSelector
- Created 5 providers: AuthProvider, RideProvider, DriverProvider, NotificationProvider, FavoritesProvider
- Created Auth screens: Splash, Welcome, Login, OTP (120s timeout), RoleSelection, RegisterClient, RegisterDriver, PendingVerification
- Created Client screens: Home, Search (landmarks + tap on map), Booking, SearchingDriver (3min timeout), TripInProgress, EndTrip, History, Favorites, Profile, Settings, Notifications, Support
- Created Driver screens: Home (online/offline toggle), RideRequest (10s timeout), Ride, EndRide, Earnings, Documents, Profile, Settings
- Created Supabase SQL migration with all tables, RLS, indexes, triggers, seed landmarks (30+ Djibouti locations)
- Created Flask Admin Panel: app.py with dashboard, drivers mgmt, rides mgmt, clients mgmt, landmarks CRUD, notifications
- Created admin HTML templates: login, dashboard, drivers, rides, clients, landmarks, send_notification
- Created admin CSS with Inggo theme (yellow/black)

Stage Summary:
- Complete Flutter app code: ~50+ Dart files covering all features
- Admin Panel: Flask + HTML/CSS/JS with full CRUD
- Database: Complete SQL migration with RLS, triggers, seed data
- All critical issues resolved: GPS throttling, landmarks for Djibouti, OTP 120s timeout, admin panel, connectivity service, cancellation policy
