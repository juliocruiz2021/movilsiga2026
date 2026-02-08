import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/login_viewmodel.dart';
import '../viewmodels/products_viewmodel.dart';
import 'settings_view.dart';
import 'products_view.dart';

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
    final loginSuccess =
        context.select<LoginViewModel, bool>((vm) => vm.loginSuccess);
    if (loginSuccess && !_navigated) {
      _navigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        final productsVm = context.read<ProductsViewModel>();
        productsVm.resetFilters(reload: false);
        productsVm.resetSession();
        context.read<LoginViewModel>().consumeLoginSuccess();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ProductsView()),
        );
      });
    }
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          const _BackgroundGlow(),
          SafeArea(
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SettingsView()),
          );
        },
        backgroundColor: const Color(0xFF1597FF),
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

    return Consumer<LoginViewModel>(
      builder: (context, vm, _) {
        onSync(vm);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0B5B8E).withOpacity(0.12),
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
                  color: const Color(0xFF083A5A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Accede con tu cuenta para continuar',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF4C6F8A),
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
                    color: const Color(0xFFFFE9EC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    vm.errorMessage!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFFB00020),
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
                    color: const Color(0xFFE7F5FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    vm.infoMessage!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF0A5B8B),
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
                    backgroundColor: const Color(0xFF1597FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: vm.isLoading
                        ? const SizedBox(
                            key: ValueKey('loading'),
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text(
                            'Iniciar sesion',
                            key: ValueKey('label'),
                          ),
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

class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFE8F6FF),
            Color(0xFFBCEBFF),
            Color(0xFFF5FBFF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: _GlowOrb(
              size: 220,
              color: Color(0xFF8AD8FF),
            ),
          ),
          Positioned(
            bottom: -90,
            left: -40,
            child: _GlowOrb(
              size: 200,
              color: Color(0xFF4FB6FF),
            ),
          ),
          Positioned(
            top: 140,
            left: 30,
            child: _GlowOrb(
              size: 120,
              color: Color(0xFFBFE9FF),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.35),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.45),
            blurRadius: 60,
            spreadRadius: 10,
          ),
        ],
      ),
    );
  }
}
