import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../viewmodels/settings_viewmodel.dart';
import 'widgets/app_themed_background.dart';
import 'widgets/offline_cloud_icon.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final _companyTokenController = TextEditingController();
  final _apiBaseUrlController = TextEditingController();
  final _companyCodeController = TextEditingController();
  bool _synced = false;

  @override
  void dispose() {
    _companyTokenController.dispose();
    _apiBaseUrlController.dispose();
    _companyCodeController.dispose();
    super.dispose();
  }

  void _syncControllers(SettingsViewModel vm) {
    if (_synced || vm.isLoading) return;
    _companyTokenController.text = vm.companyToken;
    _apiBaseUrlController.text = vm.apiBaseUrl;
    _companyCodeController.text = vm.companyCode;
    _synced = true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuracion'),
        actions: const [OfflineCloudIcon()],
      ),
      body: AppThemedBackground(
        child: SafeArea(
          child: Consumer<SettingsViewModel>(
            builder: (context, vm, _) {
              _syncControllers(vm);

              if (vm.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Apariencia',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: palette.textStrong,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Selecciona un tema predefinido para toda la app.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: palette.textMuted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppThemePreference.values.map((option) {
                        final selected = vm.themePreference == option;
                        return ChoiceChip(
                          label: Text(_themeLabel(option)),
                          selected: selected,
                          selectedColor: palette.primary,
                          labelStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: selected
                                ? palette.onPrimary
                                : palette.textStrong,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                          onSelected: (_) => vm.updateThemePreference(option),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Conexion API',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: palette.textStrong,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _apiBaseUrlController,
                      onChanged: vm.updateApiBaseUrl,
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                        labelText: 'Ruta Web API',
                        hintText: 'https://api.tuservicio.com',
                        prefixIcon: Icon(Icons.link),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _companyTokenController,
                      onChanged: vm.updateCompanyToken,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Token empresa',
                        hintText: '********',
                        prefixIcon: Icon(Icons.key),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _companyCodeController,
                      onChanged: vm.updateCompanyCode,
                      textCapitalization: TextCapitalization.none,
                      decoration: const InputDecoration(
                        labelText: 'Codigo empresa',
                        hintText: 'EMP-001',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (vm.message != null)
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
                          vm.message!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: palette.infoText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: vm.isSaving ? null : vm.save,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: vm.isSaving
                              ? SizedBox(
                                  key: const ValueKey('saving'),
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    valueColor: AlwaysStoppedAnimation(
                                      palette.onPrimary,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Guardar configuracion',
                                  key: ValueKey('label'),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _themeLabel(AppThemePreference option) {
    return switch (option) {
      AppThemePreference.system => 'Sistema',
      AppThemePreference.light => 'Claro',
      AppThemePreference.dark => 'Oscuro',
      AppThemePreference.sky => 'Celeste',
    };
  }
}
