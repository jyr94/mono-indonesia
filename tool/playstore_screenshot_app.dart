import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:monopoli_indonesia/l10n/app_localizations.dart';
import 'package:monopoli_indonesia/screens/game_screen.dart';
import 'package:monopoli_indonesia/screens/home_screen.dart';

void main() {
  const fallback = String.fromEnvironment('SCREEN', defaultValue: 'game');
  final screen = Uri.base.queryParameters['screen'] ?? fallback;
  runApp(_ScreenshotApp(screen: screen));
}

class _ScreenshotApp extends StatelessWidget {
  final String screen;

  const _ScreenshotApp({required this.screen});

  @override
  Widget build(BuildContext context) {
    final home = switch (screen) {
      'home' => const HomeScreen(),
      'join' => const _JoinPreview(),
      _ => const GameScreen(),
    };

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('id'),
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
      theme: ThemeData(useMaterial3: true, fontFamily: 'Roboto'),
      home: home,
    );
  }
}

class _JoinPreview extends StatelessWidget {
  const _JoinPreview();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gabung Room'),
        backgroundColor: const Color(0xFFC62828),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.group_add_rounded,
              size: 84,
              color: Color(0xFFC62828),
            ),
            const SizedBox(height: 24),
            const Text(
              'Masukkan Kode Room',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            const Text(
              'Bermain bersama teman secara online',
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            TextFormField(
              readOnly: true,
              initialValue: 'NUSA24',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 30,
                letterSpacing: 8,
                fontWeight: FontWeight.w900,
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC62828),
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'GABUNG',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
