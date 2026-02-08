import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/products_viewmodel.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'views/login_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key, this.settingsViewModel, this.authViewModel});

  final SettingsViewModel? settingsViewModel;
  final AuthViewModel? authViewModel;

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData.light();

    return MultiProvider(
      providers: [
        if (settingsViewModel != null)
          ChangeNotifierProvider.value(value: settingsViewModel!)
        else
          ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        if (authViewModel != null)
          ChangeNotifierProvider.value(value: authViewModel!)
        else
          ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProxyProvider2<SettingsViewModel, AuthViewModel,
            LoginViewModel>(
          create: (_) => LoginViewModel(),
          update: (_, settings, auth, vm) =>
              (vm ?? LoginViewModel())..updateDependencies(settings, auth),
        ),
        ChangeNotifierProxyProvider2<SettingsViewModel, AuthViewModel,
            ProductsViewModel>(
          create: (_) => ProductsViewModel(),
          update: (_, settings, auth, vm) =>
              (vm ?? ProductsViewModel())..updateDependencies(settings, auth),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Proyecto1',
        theme: baseTheme.copyWith(
          textTheme: GoogleFonts.manropeTextTheme(baseTheme.textTheme),
          colorScheme: baseTheme.colorScheme.copyWith(
            primary: const Color(0xFF1B9CFF),
            secondary: const Color(0xFF7FD3FF),
            surface: Colors.white,
          ),
          scaffoldBackgroundColor: const Color(0xFFF4FAFF),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
        home: const LoginView(),
      ),
    );
  }
}
