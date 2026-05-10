import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_amap/flutter_amap.dart';

void main() {
  test('Marker equality compares nested values', () {
    final marker = Marker(
      id: 'marker-1',
      position: Position(latitude: 39.9, longitude: 116.3),
      bitmap: Bitmap(
        bytes: Uint8List.fromList(<int>[1, 2, 3]),
        size: Size(width: 16, height: 16),
      ),
      title: 'title',
      snippet: 'snippet',
    );

    final sameMarker = Marker(
      id: 'marker-1',
      position: Position(latitude: 39.9, longitude: 116.3),
      bitmap: Bitmap(
        bytes: Uint8List.fromList(<int>[1, 2, 3]),
        size: Size(width: 16, height: 16),
      ),
      title: 'title',
      snippet: 'snippet',
    );

    expect(marker, sameMarker);
    expect(marker.hashCode, sameMarker.hashCode);
  });

  test('Polyline encodes and decodes all drawing fields', () {
    final polyline = Polyline(
      id: 'line-1',
      points: <Position>[
        Position(latitude: 39.9, longitude: 116.3),
        Position(latitude: 39.91, longitude: 116.31),
      ],
      color: const Color(0xFFFF0000),
      colors: const <Color>[
        Color(0xFFFF0000),
        Color(0xFF00FF00),
      ],
      width: 12,
      visible: false,
      gradient: true,
      geodesic: true,
    );

    expect(Polyline.decode(polyline.encode() as List<Object?>), polyline);
  });

  test('Arc encodes and decodes all drawing fields', () {
    final arc = Arc(
      id: 'arc-1',
      start: Position(latitude: 39.9, longitude: 116.3),
      passed: Position(latitude: 39.92, longitude: 116.32),
      end: Position(latitude: 39.91, longitude: 116.34),
      color: const Color(0xFFFF0000),
      width: 12,
      visible: false,
    );

    expect(Arc.decode(arc.encode() as List<Object?>), arc);
  });

  test('Polygon encodes and decodes all drawing fields', () {
    final polygon = Polygon(
      id: 'polygon-1',
      points: <Position>[
        Position(latitude: 39.9, longitude: 116.3),
        Position(latitude: 39.91, longitude: 116.31),
        Position(latitude: 39.92, longitude: 116.32),
      ],
      strokeWidth: 8,
      strokeColor: const Color(0xFF0000FF),
      fillColor: const Color(0xFF00FF00),
      visible: false,
    );

    expect(Polygon.decode(polygon.encode() as List<Object?>), polygon);
  });
}
