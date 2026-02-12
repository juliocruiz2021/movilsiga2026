import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/app_db.dart';
import 'theme/app_theme.dart';
import 'utils/debug_tools.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/clients_viewmodel.dart';
import 'viewmodels/connectivity_viewmodel.dart';
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/products_viewmodel.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'views/login_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugTrace('FATAL', 'FlutterError: ${details.exceptionAsString()}');
    if (details.stack != null) {
      debugTrace('FATAL', details.stack.toString());
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugTrace('FATAL', 'PlatformDispatcher error: $error');
    debugTrace('FATAL', stack.toString());
    return true;
  };

  runZonedGuarded(() => runApp(const App()), (error, stack) {
    debugTrace('FATAL', 'runZonedGuarded error: $error');
    debugTrace('FATAL', stack.toString());
  });
}

class App extends StatelessWidget {
  const App({super.key, this.settingsViewModel, this.authViewModel});

  final SettingsViewModel? settingsViewModel;
  final AuthViewModel? authViewModel;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppDb>(create: (_) => AppDb(), dispose: (_, db) => db.close()),
        if (settingsViewModel != null)
          ChangeNotifierProvider.value(value: settingsViewModel!)
        else
          ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        if (authViewModel != null)
          ChangeNotifierProvider.value(value: authViewModel!)
        else
          ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ConnectivityViewModel()),
        ChangeNotifierProxyProvider2<
          SettingsViewModel,
          AuthViewModel,
          LoginViewModel
        >(
          create: (_) => LoginViewModel(),
          update: (_, settings, auth, vm) =>
              (vm ?? LoginViewModel())..updateDependencies(settings, auth),
        ),
        ChangeNotifierProxyProvider2<
          SettingsViewModel,
          AuthViewModel,
          ClientsViewModel
        >(
          create: (_) => ClientsViewModel(),
          update: (_, settings, auth, vm) =>
              (vm ?? ClientsViewModel())..updateDependencies(settings, auth),
        ),
        ChangeNotifierProxyProvider3<
          SettingsViewModel,
          AuthViewModel,
          AppDb,
          ProductsViewModel
        >(
          create: (_) => ProductsViewModel(),
          update: (_, settings, auth, db, vm) =>
              (vm ?? ProductsViewModel())
                ..updateDependencies(settings, auth, db),
        ),
      ],
      child: Consumer<SettingsViewModel>(
        builder: (context, settings, _) {
          final lightTheme = switch (settings.themePreference) {
            AppThemePreference.sky => AppTheme.sky(),
            AppThemePreference.system => AppTheme.systemTheme(),
            AppThemePreference.dark => AppTheme.dark(),
            _ => AppTheme.light(),
          };
          final themeMode = switch (settings.themePreference) {
            AppThemePreference.dark => ThemeMode.dark,
            _ => ThemeMode.light,
          };
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Proyecto1',
            theme: lightTheme,
            darkTheme: AppTheme.dark(),
            themeMode: themeMode,
            home: const LoginView(),
          );
        },
      ),
    );
  }
}
