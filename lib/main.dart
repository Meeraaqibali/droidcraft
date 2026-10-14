import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'services.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final theme = ThemeService();
  final projects = ProjectService();
  await Future.wait([theme.load(), projects.load()]);
  runApp(MultiProvider(
    providers: [
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
    final theme = context.watch<ThemeService>();
    return MaterialApp(
      title: 'DroidCraft',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(theme.font),
      darkTheme: AppTheme.dark(theme.font),
      themeMode: theme.mode,
      home: const HomeScreen(),
    );
  }
}
