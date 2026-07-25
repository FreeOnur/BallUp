import 'package:baller_app/services/load_position.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Fallback when GPS is unavailable — same region default as [MapPage].
const LatLng kDefaultMapSelectionTarget = LatLng(47.0, 8.0);

/// Camera target after a location attempt finishes.
@visibleForTesting
LatLng mapSelectionTarget(Position? userPosition) {
  if (userPosition == null) {
    return kDefaultMapSelectionTarget;
  }
  return LatLng(userPosition.latitude, userPosition.longitude);
}

class MapSelectionPage extends StatefulWidget {
  const MapSelectionPage({super.key});

  @override
  State<MapSelectionPage> createState() => _MapSelectionPageState();
}

class _MapSelectionPageState extends State<MapSelectionPage> {
  LatLng? selectedPosition;
  final LocationService locationService = LocationService();
  GoogleMapController? mapController;
  Position? userPosition;
  bool _locationLoadComplete = false;

  @override
  void initState() {
    super.initState();
    loadPosition();
  }

  Future<void> loadPosition() async {
    userPosition = await locationService.loadPosition();
    if (!mounted) return;
    setState(() {
      _locationLoadComplete = true;
    });
  }

  void _moveCameraToUser() {
    if (mapController != null && userPosition != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(
            userPosition!.latitude,
            userPosition!.longitude,
          ),
          16,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_locationLoadComplete) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final initialTarget = mapSelectionTarget(userPosition);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Location"),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialTarget,
              zoom: 16,
            ),
            onMapCreated: (controller) {
              mapController = controller;
              _moveCameraToUser();
            },
            mapType: MapType.normal,
            buildingsEnabled: false,
            tiltGesturesEnabled: false,
            onTap: (position) {
              setState(() {
                selectedPosition = position;
              });
            },
            markers: selectedPosition == null
                ? {}
                : {
                    Marker(
                      markerId: const MarkerId("selected"),
                      position: selectedPosition!,
                    )
                  },
          ),

          if (selectedPosition != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, selectedPosition);
                },
                child: const Text("Diesen Ort verwenden"),
              ),
            ),
        ],
      ),
    );
  }
}
