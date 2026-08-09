import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://uzkqpzqrzoofwgmrxqib.supabase.co',
    publishableKey:
        'sb_publishable_0ZFzFmG4JzYHraGCvO_nTg_NB_MM7Qw',
  );

  runApp(const SubstackAuthApp());
}

class SubstackAuthApp extends StatelessWidget {
  const SubstackAuthApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    return MaterialApp(
      title: 'Substack Auth Demo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox(),
        );
      },
      home: session != null ? const HomeScreen() : const WelcomeScreen(),
    );
  }
}

