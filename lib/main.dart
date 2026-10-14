import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'services.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final auth = AuthService();
  final theme = ThemeService();
  final projects = ProjectService();
  await Future.wait([auth.load(), theme.load()]);
  projects.setAuth(auth);
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: auth),
      ChangeNotifierProvider.value(value: theme),
      ChangeNotifierProvider.value(value: projects),
    ],
    child: const DroidCraftApp(),
  ));
}

class DroidCraftApp extends StatelessWidget {
  const DroidCraftApp({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final theme = context.watch<ThemeService>();
    return MaterialApp(
      title: 'DroidCraft',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: theme.mode,
      home: auth.isLoggedIn ? const HomeScreen() : const AuthScreen(),
    );
  }
}
