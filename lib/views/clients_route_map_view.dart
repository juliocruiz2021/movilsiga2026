import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/client.dart';
import '../theme/app_theme.dart';
import '../utils/debug_tools.dart';
import '../viewmodels/connectivity_viewmodel.dart';

class ClientsRouteMapView extends StatefulWidget {
  const ClientsRouteMapView({super.key, required this.clients, this.title});

  final List<Client> clients;
  final String? title;

  @override
  State<ClientsRouteMapView> createState() => _ClientsRouteMapViewState();
}

class _ClientsRouteMapViewState extends State<ClientsRouteMapView> {
  static const LatLng _fallbackCenter = LatLng(13.6929, -89.2182);

  final MapController _mapController = MapController();

  List<_ClientWaypoint> _waypoints = const [];
  List<_ClientWaypoint> _orderedWaypoints = const [];
  List<LatLng> _routePoints = const [];

  LatLng? _currentPoint;
  bool _isLoading = false;
  _RouteMode _routeMode = _RouteMode.noGpsClients;
  String _statusNote = '';

  @override
  void initState() {
    super.initState();
    _waypoints = _extractWaypoints(widget.clients);
    _refreshRoute();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final theme = Theme.of(context);
    final offline = context.select<ConnectivityViewModel, bool>(
      (vm) => vm.isOffline,
    );

    final center =
        _currentPoint ??
        (_orderedWaypoints.isNotEmpty
            ? _orderedWaypoints.first.point
            : _fallbackCenter);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Ruta de clientes'),
        actions: [
          IconButton(
            tooltip: 'Recalcular ruta',
            onPressed: _isLoading ? null : _refreshRoute,
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
          ),
        ],
      ),
      body: Column(
        children: [
          if (offline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: palette.dangerContainer,
              child: Text(
                'Modo offline: ruta esquematica disponible (sin giro a giro).',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: palette.danger,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(initialCenter: center, initialZoom: 13),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.movilsiga.app',
                ),
                if (_routePoints.length >= 2)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints,
                        strokeWidth: 4,
                        color: palette.primary,
                      ),
                    ],
                  ),
                MarkerLayer(markers: _buildMarkers(context)),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
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
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(label: '${_orderedWaypoints.length} clientes'),
                    _InfoChip(
                      label:
                          '${_distanceKm(_routePoints).toStringAsFixed(2)} km',
                    ),
                    _InfoChip(label: _routeModeLabel()),
                  ],
                ),
                const SizedBox(height: 8),
                if (_statusNote.isNotEmpty)
                  Text(
                    _statusNote,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: palette.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                if (_statusNote.isNotEmpty) const SizedBox(height: 4),
                Text(
                  _itineraryLabel(),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _orderedWaypoints.isEmpty
                        ? null
                        : _openNavigationOptions,
                    icon: const Icon(Icons.navigation_outlined),
                    label: const Text('Iniciar viaje'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Marker> _buildMarkers(BuildContext context) {
    final palette = context.palette;
    final markers = <Marker>[];

    if (_currentPoint != null) {
      markers.add(
        Marker(
          point: _currentPoint!,
          width: 46,
          height: 46,
          child: Icon(Icons.my_location, color: palette.primary, size: 28),
        ),
      );
    }

    for (var i = 0; i < _orderedWaypoints.length; i++) {
      final wp = _orderedWaypoints[i];
      markers.add(
        Marker(
          point: wp.point,
          width: 44,
          height: 44,
          child: Tooltip(
            message: wp.client.nombre,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: palette.surface,
              child: CircleAvatar(
                radius: 15,
                backgroundColor: palette.primary,
                child: Text(
                  '${i + 1}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: palette.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return markers;
  }

  Future<void> _refreshRoute() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final offline = context.read<ConnectivityViewModel>().isOffline;
      debugTrace(
        'ROUTE_MAP',
        'refresh start. clients=${widget.clients.length} gpsClients=${_waypoints.length} offline=$offline',
      );
      _currentPoint = await _resolveCurrentPoint();
      debugTrace(
        'ROUTE_MAP',
        'current point=${_currentPoint == null ? 'null' : '${_currentPoint!.latitude},${_currentPoint!.longitude}'}',
      );
      _orderedWaypoints = _orderWaypoints(_waypoints, _currentPoint);

      final checkpoints = <LatLng>[];
      if (_currentPoint != null) checkpoints.add(_currentPoint!);
      checkpoints.addAll(_orderedWaypoints.map((w) => w.point));

      if (_orderedWaypoints.isEmpty) {
        _routePoints = const [];
        _routeMode = _RouteMode.noGpsClients;
        _statusNote = 'No hay clientes con GPS para esta ruta.';
      } else if (!offline && checkpoints.length >= 2) {
        final online = await _fetchRouteFromOsrm(checkpoints);
        if (online.length >= 2) {
          _routePoints = online;
          _routeMode = _RouteMode.online;
          _statusNote = 'Ruta calculada con internet.';
        } else {
          _routePoints = checkpoints;
          _routeMode = _RouteMode.onlineFallback;
          _statusNote =
              'No se pudo calcular la ruta giro a giro. Se muestra un trazado aproximado.';
        }
      } else if (offline) {
        _routePoints = checkpoints;
        _routeMode = _RouteMode.noInternet;
        _statusNote = checkpoints.length >= 2
            ? 'Sin internet. Se muestra un trazado aproximado.'
            : 'Sin internet y sin ubicacion actual para trazar recorrido.';
      } else if (_currentPoint == null) {
        _routePoints = checkpoints;
        _routeMode = _RouteMode.noCurrentLocation;
        _statusNote =
            'Activa ubicacion del dispositivo para ver recorrido desde tu posicion.';
      } else {
        _routePoints = checkpoints;
        _routeMode = _RouteMode.onlineFallback;
        _statusNote = 'No se pudo generar el recorrido.';
      }

      _fitRouteCamera(checkpoints);
      debugTrace(
        'ROUTE_MAP',
        'refresh end. mode=$_routeMode checkpoints=${checkpoints.length} routePoints=${_routePoints.length}',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _fitRouteCamera(List<LatLng> checkpoints) {
    if (!mounted) return;

    final points = _routePoints.length >= 2 ? _routePoints : checkpoints;
    if (points.length >= 2) {
      final bounds = LatLngBounds.fromPoints(points);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 52),
          maxZoom: 16,
        ),
      );
      return;
    }

    final center =
        _currentPoint ??
        (_orderedWaypoints.isNotEmpty
            ? _orderedWaypoints.first.point
            : _fallbackCenter);
    _mapController.move(center, 14);
  }

  Future<LatLng?> _resolveCurrentPoint() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        debugTrace('ROUTE_MAP', 'location service disabled');
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugTrace('ROUTE_MAP', 'location permission denied: $permission');
        return null;
      }

      try {
        final position = await Geolocator.getCurrentPosition().timeout(
          const Duration(seconds: 10),
        );
        return LatLng(position.latitude, position.longitude);
      } catch (_) {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          debugTrace(
            'ROUTE_MAP',
            'using lastKnown=${lastKnown.latitude},${lastKnown.longitude}',
          );
          return LatLng(lastKnown.latitude, lastKnown.longitude);
        }
      }

      return null;
    } catch (e) {
      debugTrace('ROUTE_MAP', 'No se pudo obtener ubicacion actual: $e');
      return null;
    }
  }

  Future<List<LatLng>> _fetchRouteFromOsrm(List<LatLng> checkpoints) async {
    try {
      final coords = checkpoints
          .map(
            (p) =>
                '${p.longitude.toStringAsFixed(6)},${p.latitude.toStringAsFixed(6)}',
          )
          .join(';');
      final uri = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/$coords?overview=full&geometries=geojson&steps=false',
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugTrace('ROUTE_MAP', 'OSRM non-2xx status=${response.statusCode}');
        return const [];
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return const [];
      final routes = decoded['routes'];
      if (routes is! List || routes.isEmpty) return const [];
      final route = routes.first;
      if (route is! Map<String, dynamic>) return const [];
      final geometry = route['geometry'];
      if (geometry is! Map<String, dynamic>) return const [];
      final coordinates = geometry['coordinates'];
      if (coordinates is! List) return const [];

      final points = <LatLng>[];
      for (final entry in coordinates) {
        if (entry is List && entry.length >= 2) {
          final lng = (entry[0] as num?)?.toDouble();
          final lat = (entry[1] as num?)?.toDouble();
          if (lat != null && lng != null) {
            points.add(LatLng(lat, lng));
          }
        }
      }
      debugTrace('ROUTE_MAP', 'OSRM points received=${points.length}');
      return points;
    } catch (e) {
      debugTrace('ROUTE_MAP', 'Fallo OSRM, usando offline: $e');
      return const [];
    }
  }

  List<_ClientWaypoint> _extractWaypoints(List<Client> clients) {
    final waypoints = <_ClientWaypoint>[];
    for (final client in clients) {
      final point = _parseGps(client.gpsUbicacion);
      if (point == null) continue;
      waypoints.add(_ClientWaypoint(client: client, point: point));
    }
    return waypoints;
  }

  List<_ClientWaypoint> _orderWaypoints(
    List<_ClientWaypoint> source,
    LatLng? start,
  ) {
    if (source.length <= 1) return List<_ClientWaypoint>.from(source);

    final remaining = List<_ClientWaypoint>.from(source);
    final ordered = <_ClientWaypoint>[];
    var current = start ?? remaining.first.point;

    while (remaining.isNotEmpty) {
      remaining.sort((a, b) {
        final da = _haversineKm(current, a.point);
        final db = _haversineKm(current, b.point);
        return da.compareTo(db);
      });

      final next = remaining.removeAt(0);
      ordered.add(next);
      current = next.point;
    }

    return ordered;
  }

  LatLng? _parseGps(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final parts = raw.split(',');
    if (parts.length != 2) return null;

    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  String _itineraryLabel() {
    if (_orderedWaypoints.isEmpty) {
      return 'No hay clientes con GPS disponible para esta ruta.';
    }

    final names = _orderedWaypoints.map((w) => w.client.nombre).toList();
    return names.join(' -> ');
  }

  String _routeModeLabel() {
    switch (_routeMode) {
      case _RouteMode.online:
        return 'Ruta online';
      case _RouteMode.onlineFallback:
        return 'Ruta aproximada';
      case _RouteMode.noInternet:
        return 'Sin internet';
      case _RouteMode.noCurrentLocation:
        return 'Sin GPS actual';
      case _RouteMode.noGpsClients:
        return 'Sin clientes GPS';
    }
  }

  Future<void> _openNavigationOptions() async {
    if (_orderedWaypoints.isEmpty) return;
    final option = await showModalBottomSheet<_NavApp>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.map_outlined),
                title: const Text('Google Maps'),
                subtitle: const Text('Navegacion guiada con voz'),
                onTap: () => Navigator.of(sheetContext).pop(_NavApp.googleMaps),
              ),
              ListTile(
                leading: const Icon(Icons.alt_route_outlined),
                title: const Text('Waze'),
                subtitle: const Text('Abrir en Waze'),
                onTap: () => Navigator.of(sheetContext).pop(_NavApp.waze),
              ),
            ],
          ),
        );
      },
    );
    if (!mounted || option == null) return;

    final destination = _orderedWaypoints.last.point;
    final origin = _currentPoint;
    final waypointPoints = _orderedWaypoints.length > 1
        ? _orderedWaypoints
              .take(_orderedWaypoints.length - 1)
              .map((w) => w.point)
              .toList()
        : const <LatLng>[];

    bool opened = false;
    if (option == _NavApp.googleMaps) {
      final query = <String, String>{
        'api': '1',
        'destination':
            '${destination.latitude.toStringAsFixed(6)},${destination.longitude.toStringAsFixed(6)}',
        'travelmode': 'driving',
        'dir_action': 'navigate',
      };
      if (origin != null) {
        query['origin'] =
            '${origin.latitude.toStringAsFixed(6)},${origin.longitude.toStringAsFixed(6)}';
      }
      if (waypointPoints.isNotEmpty) {
        query['waypoints'] = waypointPoints
            .map(
              (p) =>
                  '${p.latitude.toStringAsFixed(6)},${p.longitude.toStringAsFixed(6)}',
            )
            .join('|');
      }
      final uri = Uri.https('www.google.com', '/maps/dir/', query);
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      final wazeApp = Uri.parse(
        'waze://?ll=${destination.latitude.toStringAsFixed(6)},${destination.longitude.toStringAsFixed(6)}&navigate=yes',
      );
      opened = await launchUrl(wazeApp, mode: LaunchMode.externalApplication);
      if (!opened) {
        final wazeWeb = Uri.https('waze.com', '/ul', {
          'll':
              '${destination.latitude.toStringAsFixed(6)},${destination.longitude.toStringAsFixed(6)}',
          'navigate': 'yes',
        });
        opened = await launchUrl(wazeWeb, mode: LaunchMode.externalApplication);
      }
    }

    if (!mounted || opened) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No se pudo abrir la app de navegacion seleccionada.'),
      ),
    );
  }

  double _distanceKm(List<LatLng> points) {
    if (points.length < 2) return 0;
    var total = 0.0;
    for (var i = 1; i < points.length; i++) {
      total += _haversineKm(points[i - 1], points[i]);
    }
    return total;
  }

  double _haversineKm(LatLng a, LatLng b) {
    const earthRadiusKm = 6371.0;
    final dLat = _toRadians(b.latitude - a.latitude);
    final dLng = _toRadians(b.longitude - a.longitude);

    final lat1 = _toRadians(a.latitude);
    final lat2 = _toRadians(b.latitude);

    final hav =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final c = 2 * math.atan2(math.sqrt(hav), math.sqrt(1 - hav));
    return earthRadiusKm * c;
  }

  double _toRadians(double degrees) {
    return degrees * math.pi / 180;
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: palette.surfaceSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: palette.textStrong,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ClientWaypoint {
  const _ClientWaypoint({required this.client, required this.point});

  final Client client;
  final LatLng point;
}

enum _RouteMode {
  online,
  onlineFallback,
  noInternet,
  noCurrentLocation,
  noGpsClients,
}

enum _NavApp { googleMaps, waze }
