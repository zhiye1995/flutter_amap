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

  test('NavigateArrow encodes and decodes all drawing fields', () {
    final arrow = NavigateArrow(
      id: 'arrow-1',
      points: <Position>[
        Position(latitude: 39.9, longitude: 116.3),
        Position(latitude: 39.91, longitude: 116.31),
      ],
      color: const Color(0xFFFF0000),
      sideColor: const Color(0xFF880000),
      width: 20,
      visible: false,
    );

    expect(NavigateArrow.decode(arrow.encode() as List<Object?>), arrow);
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

  test('PoiKeywordSearchQuery encodes and decodes all fields', () {
    final query = PoiKeywordSearchQuery(
      keywords: '天安门',
      types: '110000',
      city: '北京',
      cityLimit: true,
      page: 2,
      pageSize: 15,
      location: Position(latitude: 39.9, longitude: 116.3),
      extensions: PoiSearchExtensions.all,
      children: true,
      sortByDistance: true,
    );

    final decoded =
        PoiKeywordSearchQuery.decode(query.encode() as List<Object?>);

    expect(decoded.keywords, query.keywords);
    expect(decoded.types, query.types);
    expect(decoded.city, query.city);
    expect(decoded.cityLimit, query.cityLimit);
    expect(decoded.page, query.page);
    expect(decoded.pageSize, query.pageSize);
    expect(decoded.location, query.location);
    expect(decoded.extensions, query.extensions);
    expect(decoded.children, query.children);
    expect(decoded.sortByDistance, query.sortByDistance);
  });

  test('PoiAroundSearchQuery encodes and decodes all fields', () {
    final query = PoiAroundSearchQuery(
      center: Position(latitude: 39.9, longitude: 116.3),
      keywords: '餐饮',
      types: '050000',
      radius: 1500,
      city: '北京',
      page: 3,
      pageSize: 10,
      extensions: PoiSearchExtensions.all,
      children: true,
      sortByDistance: false,
    );

    final decoded =
        PoiAroundSearchQuery.decode(query.encode() as List<Object?>);

    expect(decoded.center, query.center);
    expect(decoded.keywords, query.keywords);
    expect(decoded.types, query.types);
    expect(decoded.radius, query.radius);
    expect(decoded.city, query.city);
    expect(decoded.page, query.page);
    expect(decoded.pageSize, query.pageSize);
    expect(decoded.extensions, query.extensions);
    expect(decoded.children, query.children);
    expect(decoded.sortByDistance, query.sortByDistance);
  });

  test('CruiseConfig encodes and decodes all fields', () {
    final config = CruiseConfig(
      mode: CruiseBroadcastMode.specialRoadOnly,
      useInnerVoice: false,
      allowsBackgroundLocationUpdates: false,
      pausesLocationUpdatesAutomatically: true,
    );

    final decoded = CruiseConfig.decode(config.encode() as List<Object?>);

    expect(decoded.mode, config.mode);
    expect(decoded.useInnerVoice, config.useInnerVoice);
    expect(
      decoded.allowsBackgroundLocationUpdates,
      config.allowsBackgroundLocationUpdates,
    );
    expect(
      decoded.pausesLocationUpdatesAutomatically,
      config.pausesLocationUpdatesAutomatically,
    );
  });
}
