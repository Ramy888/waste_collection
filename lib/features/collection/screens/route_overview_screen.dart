import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/widgets/loading_indicators.dart';
import '../models/collection_point_model.dart';
import '../models/route_model.dart';
import '../providers/collection_provider.dart';


class RouteOverviewScreen extends StatefulWidget {
  const RouteOverviewScreen({super.key});

  @override
  State<RouteOverviewScreen> createState() => _RouteOverviewScreenState();
}

class _RouteOverviewScreenState extends State<RouteOverviewScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CollectionProvider>().initializeDummyData();
    });
  }

  void _updateMapMarkers() {
    final currentRoute = context.read<CollectionProvider>().currentRoute;
    if (currentRoute == null) return;

    final markers = currentRoute.collectionPoints.map((point) {
      return Marker(
        markerId: MarkerId(point.id),
        position: LatLng(point.latitude, point.longitude),
        infoWindow: InfoWindow(
          title: point.address,
          snippet: 'Status: ${point.status}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          point.status == 'completed'
              ? BitmapDescriptor.hueGreen
              : point.status == 'skipped'
              ? BitmapDescriptor.hueRed
              : BitmapDescriptor.hueBlue,
        ),
      );
    }).toSet();

    setState(() {
      _markers = markers;
    });
  }

  void _centerMap() {
    if (_mapController == null) return;

    final points = context.read<CollectionProvider>().currentRoute?.collectionPoints;
    if (points == null || points.isEmpty) return;

    double maxLat = points.first.latitude;
    double minLat = points.first.latitude;
    double maxLng = points.first.longitude;
    double minLng = points.first.longitude;

    for (var point in points) {
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
      if (point.longitude < minLng) minLng = point.longitude;
    }

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        50,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Overview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<CollectionProvider>().initializeDummyData(),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            // onPressed: () => Navigator.pushNamed(context, '/profile'),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: Consumer<CollectionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingIndicator(message: 'Loading route data...');
          }

          final currentRoute = provider.currentRoute;
          if (currentRoute == null) {
            return const Center(child: Text('No route available'));
          }

          return Column(
            children: [
              _buildRouteHeader(currentRoute),
              Expanded(
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(40.7128, -74.0060), // New York
                        zoom: 12,
                      ),
                      onMapCreated: (controller) {
                        _mapController = controller;
                        _updateMapMarkers();
                        _centerMap();
                      },
                      markers: _markers,
                      polylines: _polylines,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: FloatingActionButton(
                        onPressed: _centerMap,
                        child: const Icon(Icons.center_focus_strong),
                      ),
                    ),
                  ],
                ),
              ),
              _buildCollectionPointsList(currentRoute.collectionPoints),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRouteHeader(RouteModel route) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            route.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Date: ${route.date}',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'Progress: ${route.completionPercentage.toStringAsFixed(1)}%',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: route.completionPercentage / 100,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionPointsList(List<CollectionPointModel> points) {
    return Container(
      height: 120,
      color: Theme.of(context).colorScheme.surface,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(8),
        itemCount: points.length,
        itemBuilder: (context, index) {
          final point = points[index];
          return Card(
            margin: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                context.push(
                  '/collection-validation',
                  extra: point,
                );
              },
              child: Container(
                width: 200,
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      point.address,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          point.status == 'completed'
                              ? Icons.check_circle
                              : point.status == 'skipped'
                              ? Icons.cancel
                              : Icons.schedule,
                          color: point.status == 'completed'
                              ? Colors.green
                              : point.status == 'skipped'
                              ? Colors.red
                              : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          point.status.toUpperCase(),
                          style: TextStyle(
                            color: point.status == 'completed'
                                ? Colors.green
                                : point.status == 'skipped'
                                ? Colors.red
                                : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}