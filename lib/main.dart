import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/themes.dart';
import 'core/constants/app_constants.dart';
import 'core/routes/app_routes.dart';
import 'presentation/screens/login/login_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(), // No cargues usuario aquí
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppThemes.darkTheme,
      debugShowCheckedModeBanner: false,
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          // Siempre muestra la pantalla de login si no hay sesión válida
          return auth.isLoggedIn ? const HomeScreen() : const LoginScreen();
        },
      ),
    );
  }
}

