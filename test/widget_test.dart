import 'package:flutter_test/flutter_test.dart';

import 'package:proyecto1/main.dart';
import 'package:proyecto1/viewmodels/auth_viewmodel.dart';
import 'package:proyecto1/viewmodels/settings_viewmodel.dart';

void main() {
  testWidgets('Login view renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      App(
        settingsViewModel: SettingsViewModel(loadOnInit: false),
        authViewModel: AuthViewModel(loadOnInit: false),
      ),
    );

    expect(find.text('Bienvenido'), findsOneWidget);
    expect(find.text('Iniciar sesion'), findsOneWidget);
  });
}
