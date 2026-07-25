import 'package:baller_app/pages/Map/map_selection_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  test('mapSelectionTarget falls back when GPS is unavailable', () {
    expect(mapSelectionTarget(null), kDefaultMapSelectionTarget);
  });

  test('mapSelectionTarget uses the user position when available', () {
    final position = Position(
      longitude: 8.5,
      latitude: 47.5,
      timestamp: DateTime.fromMillisecondsSinceEpoch(0),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );

    expect(mapSelectionTarget(position), const LatLng(47.5, 8.5));
  });
}
