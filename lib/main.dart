import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rental_admin/features/auth/presentation/pages/admin_login_screen.dart';
import 'package:rental_admin/features/dashboard/presentation/pages/admin_dashboard_screen.dart';
import 'package:rental_admin/core/services/analytics_service.dart';
import 'package:rental_admin/app/theme/app_theme.dart';
import 'package:rental_admin/app/theme/theme_provider.dart';
import 'package:rental_admin/app/config/env.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rental_admin/core/services/push_notification_service.dart';
import 'package:rental_admin/core/services/in_app_update_service.dart';
import 'package:rental_admin/core/services/review_trigger_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print("Handling a background message: ${message.messageId}");
}
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  // Enable edge-to-edge rendering so the app draws behind
  // the status bar AND the Android 3-button/gesture navigation bar.
  // SafeArea widgets in each screen then push content up/down correctly
  // regardless of whether the phone uses gestures or 3-button navigation.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Turbocharge Flutter ImageCache for instant photo rendering
  PaintingBinding.instance.imageCache.maximumSize = 1000;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 250 << 20; // 250 MB

  await ThemeController.instance.init();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  final prefs = await SharedPreferences.getInstance();


  // Set up Firebase Messaging background handler (mobile only)
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // Launch UI INSTANTLY — 0ms blank screen delay
  runApp(const RentalApp());

  // Initialize Analytics and Push Notification Service asynchronously in background
  _initAsyncServices();
}

void _initAsyncServices() async {
  await AnalyticsService.instance.init();
  await PushNotificationService.instance.init();
}

class RentalApp extends StatelessWidget {
  const RentalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeController.instance,
      builder: (context, _) {
        final isDark = false;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
            // Fully transparent so the edge-to-edge app draws behind the nav bar.
            // SafeArea handles the actual content padding for all nav styles
            // (gesture bar, 2-button, 3-button).
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarDividerColor: Colors.transparent,
            systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          ),
          child: MaterialApp(
            navigatorKey: PushNotificationService.instance.navigatorKey,
            title: 'Rental App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            builder: (context, child) {
              return ReviewTriggerWrapper(
                child: InAppUpdateWrapper(child: child ?? const SizedBox.shrink()),
              );
            },
            onGenerateRoute: (settings) {
              final rawName = settings.name ?? '/';
              final uri = Uri.parse(rawName);
              final path = uri.path.toLowerCase();


              if (path == '/admin' ||
                  path == '/admin/' ||
                  path == 'admin' ||
                  path.startsWith('/admin')) {
                final session = Supabase.instance.client.auth.currentSession;
                if (session != null) {
                  return MaterialPageRoute(
                    settings: settings,
                    builder: (_) => const AdminDashboardScreen(),
                  );
                }
                return MaterialPageRoute(
                  settings: settings,
                  builder: (_) => const AdminLoginScreen(),
                );
              }

              if (path == '/admin/login') {
                return MaterialPageRoute(
                  settings: settings,
                  builder: (_) => const AdminLoginScreen(),
                );
              }

              if (path == '/admin/dashboard') {
                // SECURITY: Require valid session — same guard as /admin root
                final dashSession = Supabase.instance.client.auth.currentSession;
                if (dashSession != null) {
                  return MaterialPageRoute(
                    settings: settings,
                    builder: (_) => const AdminDashboardScreen(),
                  );
                }
                return MaterialPageRoute(
                  settings: settings,
                  builder: (_) => const AdminLoginScreen(),
                );
              }


              return MaterialPageRoute(
                settings: settings,
                builder: (_) => const AdminLoginScreen(),
              );
            },
          ),
        );
      },
    );
  }
}
