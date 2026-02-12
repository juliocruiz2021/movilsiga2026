import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../viewmodels/connectivity_viewmodel.dart';

class OfflineCloudIcon extends StatelessWidget {
  const OfflineCloudIcon({
    super.key,
    this.size = 22,
    this.padding = const EdgeInsets.only(right: 12),
  });

  final double size;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Consumer<ConnectivityViewModel>(
      builder: (context, vm, _) {
        if (!vm.isOffline) return const SizedBox.shrink();
        return Padding(
          padding: padding,
          child: Icon(Icons.cloud_off, color: palette.danger, size: size),
        );
      },
    );
  }
}
