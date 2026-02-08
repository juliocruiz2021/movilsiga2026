import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/settings_viewmodel.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuracion'),
      ),
      body: Consumer<SettingsViewModel>(
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
                  'Conexion API',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF083A5A),
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
                      color: const Color(0xFFE7F5FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      vm.message!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF0A5B8B),
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
                      backgroundColor: const Color(0xFF1597FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: vm.isSaving
                          ? const SizedBox(
                              key: ValueKey('saving'),
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
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
    );
  }
}
