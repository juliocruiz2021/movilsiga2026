import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../theme/app_theme.dart';

class LocationPickerView extends StatefulWidget {
  const LocationPickerView({super.key, this.initialGps});

  final String? initialGps;

  @override
  State<LocationPickerView> createState() => _LocationPickerViewState();
}

class _LocationPickerViewState extends State<LocationPickerView> {
  static const LatLng _fallbackCenter = LatLng(13.6929, -89.2182);

  final MapController _mapController = MapController();
  LatLng? _selected;
  bool _isLoadingCurrentLocation = false;

  @override
  void initState() {
    super.initState();
    _selected = _parseGps(widget.initialGps) ?? _fallbackCenter;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar ubicacion'),
        actions: [
          IconButton(
            onPressed: _isLoadingCurrentLocation
                ? null
                : () => _useCurrentLocation(showSnackOnError: true),
            icon: _isLoadingCurrentLocation
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
            tooltip: 'Usar ubicacion actual',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selected ?? _fallbackCenter,
                initialZoom: 14,
                onTap: (_, point) {
                  setState(() => _selected = point);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.proyecto1.app',
                ),
                MarkerLayer(
                  markers: [
                    if (_selected != null)
                      Marker(
                        point: _selected!,
                        width: 44,
                        height: 44,
                        child: Icon(
                          Icons.location_pin,
                          color: palette.primary,
                          size: 40,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              color: palette.surface.withValues(alpha: 0.95),
              border: Border(
                top: BorderSide(
                  color: palette.textMuted.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Toca el mapa para seleccionar coordenadas.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _selected == null ? '-' : _formatGps(_selected!),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: palette.textStrong,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _selected == null
                        ? null
                        : () =>
                              Navigator.of(context).pop(_formatGps(_selected!)),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Usar esta ubicacion'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _useCurrentLocation({required bool showSnackOnError}) async {
    setState(() => _isLoadingCurrentLocation = true);
    try {
      final position = await _currentPosition();
      if (!mounted) return;
      if (position == null) {
        if (showSnackOnError) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo obtener tu ubicacion.')),
          );
        }
        return;
      }

      final point = LatLng(position.latitude, position.longitude);
      setState(() => _selected = point);
      _mapController.move(point, 16);
    } finally {
      if (mounted) {
        setState(() => _isLoadingCurrentLocation = false);
      }
    }
  }

  Future<Position?> _currentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  LatLng? _parseGps(String? raw) {
    if (raw == null) return null;
    final parts = raw.split(',');
    if (parts.length != 2) return null;
    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  String _formatGps(LatLng value) {
    return '${value.latitude.toStringAsFixed(6)},${value.longitude.toStringAsFixed(6)}';
  }
}
