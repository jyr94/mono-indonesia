import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'constants/app_constants.dart';
import 'l10n/app_localizations.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/game_screen.dart';
import 'screens/lobby_screen.dart';
import 'screens/join_room_screen.dart';
import 'screens/onboarding_screen.dart';
import 'models/player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const MonopoliApp());
}

class MonopoliApp extends StatelessWidget {
  const MonopoliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.nunitoTextTheme().copyWith(
          displayLarge: GoogleFonts.baloo2(fontWeight: FontWeight.w800),
          displayMedium: GoogleFonts.baloo2(fontWeight: FontWeight.w800),
          headlineLarge: GoogleFonts.baloo2(fontWeight: FontWeight.w800),
          headlineMedium: GoogleFonts.baloo2(fontWeight: FontWeight.w700),
          titleLarge: GoogleFonts.baloo2(fontWeight: FontWeight.w700),
          titleMedium: GoogleFonts.baloo2(fontWeight: FontWeight.w600),
          bodyLarge: GoogleFonts.nunito(),
          bodyMedium: GoogleFonts.nunito(),
        ),
      ),
      navigatorObservers: [
        FirebaseAnalyticsObserver(
          analytics: FirebaseAnalytics.instance,
        ),
      ],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'),
        Locale('en', 'US'),
      ],
      locale: const Locale('id'),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (_) => const SplashScreen(),
            );
          case '/onboarding':
            return MaterialPageRoute(
              builder: (_) => const OnboardingScreen(),
            );
          case '/home':
            return MaterialPageRoute(
              builder: (_) => const HomeScreen(),
            );
          case '/game':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => GameScreen(
                syncService: args?['syncService'],
                localPlayers: args?['localPlayers'] as List<Player>?,
              ),
            );
          case '/lobby':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => LobbyScreen(
                roomCode: args['roomCode'] as String,
                playerId: args['playerId'] as String,
                playerName: args['playerName'] as String,
                isHost: args['isHost'] as bool,
              ),
            );
          case '/join':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => JoinRoomScreen(
                playerId: args?['playerId'] as String? ?? '',
                playerName: args?['playerName'] as String? ?? 'Player',
              ),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const SplashScreen(),
            );
        }
      },
    );
  }
}
