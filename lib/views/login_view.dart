import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../viewmodels/login_viewmodel.dart';
import '../viewmodels/products_viewmodel.dart';
import 'home_view.dart';
import 'settings_view.dart';
import 'widgets/app_themed_background.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _synced = false;
  bool _navigated = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginSuccess = context.select<LoginViewModel, bool>(
      (vm) => vm.loginSuccess,
    );
    if (loginSuccess && !_navigated) {
      _navigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        final productsVm = context.read<ProductsViewModel>();
        productsVm.resetFilters(reload: false);
        productsVm.resetSession();
        context.read<LoginViewModel>().consumeLoginSuccess();
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeView()));
      });
    }
    return Scaffold(
      body: AppThemedBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  tween: Tween(begin: 0, end: 1),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 16 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: _LoginCard(
                    emailController: _emailController,
                    passwordController: _passwordController,
                    onSync: _syncControllers,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const SettingsView()));
        },
        child: const Icon(Icons.settings),
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.emailController,
    required this.passwordController,
    required this.onSync,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final void Function(LoginViewModel) onSync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<LoginViewModel>(
      builder: (context, vm, _) {
        onSync(vm);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: palette.surface.withValues(alpha: isDark ? 0.90 : 0.92),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: palette.shadow.withValues(alpha: 0.12),
                blurRadius: 28,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Bienvenido',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: palette.textStrong,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Accede con tu cuenta para continuar',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: palette.textMuted,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: vm.updateEmail,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'tu@correo.com',
                  prefixIcon: Icon(Icons.mail_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: vm.obscurePassword,
                onChanged: vm.updatePassword,
                decoration: InputDecoration(
                  labelText: 'Clave',
                  hintText: 'Minimo 6 caracteres',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: vm.toggleObscurePassword,
                    icon: Icon(
                      vm.obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (vm.errorMessage != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: palette.dangerContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    vm.errorMessage!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: palette.danger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (vm.errorMessage == null && vm.infoMessage != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: palette.infoContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    vm.infoMessage!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: palette.infoText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(height: 18),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: vm.canSubmit ? vm.login : null,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: vm.isLoading
                        ? SizedBox(
                            key: const ValueKey('loading'),
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation(
                                palette.onPrimary,
                              ),
                            ),
                          )
                        : const Text('Iniciar sesion', key: ValueKey('label')),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

extension on _LoginViewState {
  void _syncControllers(LoginViewModel vm) {
    if (_synced || !vm.hasLoadedSavedLogin) return;
    _emailController.text = vm.email;
    _passwordController.text = vm.password;
    _synced = true;
  }
}
