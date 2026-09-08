import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/social_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
        ChangeNotifierProvider(create: (_) => AuthProvider(prefs)..restore()),
      ],
      child: const LabApp(),
    ),
  );
}

class LabApp extends StatelessWidget {
  const LabApp({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final auth = context.watch<AuthProvider>();
    return MaterialApp(
      title: 'Surla • Social',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff1877f2)),
        scaffoldBackgroundColor: const Color(0xfff0f2f5),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff1877f2),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: theme.dark ? ThemeMode.dark : ThemeMode.light,
      home: !auth.ready || auth.startupError != null
          ? const SplashScreen()
          : auth.user == null
          ? const SignInScreen()
          : ChangeNotifierProvider(
              key: ValueKey(auth.user!.id),
              create: (_) => SocialProvider(auth.prefs, auth.user!.id),
              child: const HomeScreen(),
            ),
    );
  }
}
