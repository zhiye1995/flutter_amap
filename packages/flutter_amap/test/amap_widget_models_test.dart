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
      colors: const <Color>[Color(0xFFFF0000), Color(0xFF00FF00)],
      width: 12,
      visible: false,
      gradient: true,
      geodesic: true,
      useTexture: true,
      texture: Bitmap(
        bytes: Uint8List.fromList(<int>[1, 2, 3]),
        size: Size(width: 64, height: 64),
      ),
      textures: <Bitmap>[
        Bitmap(asset: 'assets/polyline_texture.png'),
        Bitmap(
          bytes: Uint8List.fromList(<int>[4, 5, 6]),
          size: Size(width: 64, height: 64),
        ),
      ],
      textureIndexes: const <int>[1],
      dottedLine: true,
      zIndex: 3,
    );

    expect(Polyline.decode(polyline.encode() as List<Object?>), polyline);
  });

  test('Polyline decodes legacy drawing fields with new defaults', () {
    final legacy = <Object?>[
      'line-legacy',
      <Object?>[
        Position(latitude: 39.9, longitude: 116.3).encode(),
        Position(latitude: 39.91, longitude: 116.31).encode(),
      ],
      const Color(0xFFFF0000).toARGB32(),
      12.0,
      true,
      <Object?>[],
      false,
      false,
    ];

    final decoded = Polyline.decode(legacy);

    expect(decoded.useTexture, isFalse);
    expect(decoded.texture, isNull);
    expect(decoded.textures, isEmpty);
    expect(decoded.textureIndexes, isEmpty);
    expect(decoded.dottedLine, isFalse);
    expect(decoded.zIndex, 0);
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

    final decoded = PoiKeywordSearchQuery.decode(
      query.encode() as List<Object?>,
    );

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

    final decoded = PoiAroundSearchQuery.decode(
      query.encode() as List<Object?>,
    );

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

  test('ReGeocodeQuery stores official SDK options', () {
    final query = ReGeocodeQuery(
      position: Position(latitude: 39.908722, longitude: 116.397499),
      radius: 200,
      extensions: ReGeocodeExtensions.all,
      coordinateType: ReGeocodeCoordinateType.gps,
      poiTypes: '050000|060000',
    );

    expect(
      query.position,
      Position(latitude: 39.908722, longitude: 116.397499),
    );
    expect(query.radius, 200);
    expect(query.extensions, ReGeocodeExtensions.all);
    expect(query.coordinateType, ReGeocodeCoordinateType.gps);
    expect(query.poiTypes, '050000|060000');
  });

  test('DriveRouteQuery serializes official route options', () {
    final query = DriveRouteQuery(
      origin: RoutePoint(
        position: Position(latitude: 39.9, longitude: 116.3),
        name: '起点',
        poiId: 'origin-poi',
      ),
      destination: RoutePoint(
        position: Position(latitude: 39.99, longitude: 116.48),
        name: '终点',
      ),
      strategy: PathPlanningStrategy.drivingMultipleRoutesDefault,
      wayPoints: <RoutePoint>[
        RoutePoint(position: Position(latitude: 39.95, longitude: 116.4)),
      ],
      avoidRoad: '东三环',
      extensions: RoutePlanExtensions.all,
      carType: 0,
      carNumber: '京A12345',
    );

    final map = query.toMap();

    expect(map['type'], 'drive');
    expect(map['strategy'], 10);
    expect(query.strategy, PathPlanningStrategy.drivingMultipleRoutesDefault);
    expect(map['avoidRoad'], '东三环');
    expect(map['extensions'], 'all');
    expect(map['carNumber'], '京A12345');
    expect((map['wayPoints'] as List), hasLength(1));

    final legacyQuery = DriveRouteQuery(
      origin: query.origin,
      destination: query.destination,
      strategy: 10,
    );
    expect(
      legacyQuery.strategy,
      PathPlanningStrategy.drivingMultipleRoutesDefault,
    );
  });

  test('RoutePlanResult decodes route paths and steps', () {
    final result = RoutePlanResult.decodeFromMap(<String, dynamic>{
      'type': 'drive',
      'taxiCost': 88.5,
      'paths': <Map<String, dynamic>>[
        <String, dynamic>{
          'distance': 12000,
          'duration': 1800,
          'strategy': '速度优先',
          'tolls': 10,
          'totalTrafficLights': 8,
          'polyline': <Map<String, dynamic>>[
            <String, dynamic>{'latitude': 39.9, 'longitude': 116.3},
            <String, dynamic>{'latitude': 39.99, 'longitude': 116.48},
          ],
          'steps': <Map<String, dynamic>>[
            <String, dynamic>{
              'instruction': '沿东长安街向东行驶',
              'road': '东长安街',
              'distance': 800,
              'duration': 120,
              'tmcs': <Map<String, dynamic>>[
                <String, dynamic>{'status': '畅通', 'distance': 800},
              ],
            },
          ],
        },
      ],
    });

    expect(result.type, RoutePlanType.drive);
    expect(result.taxiCost, 88.5);
    expect(result.paths.single.distance, 12000);
    expect(result.paths.single.polyline, hasLength(2));
    expect(result.paths.single.steps.single.road, '东长安街');
    expect(result.paths.single.steps.single.tmcs.single.status, '畅通');
  });

  test('GeocodeResult decodes map fields', () {
    final result = GeocodeResult.decodeFromMap(<String, dynamic>{
      'formattedAddress': '北京市东城区天安门',
      'latitude': 39.908722,
      'longitude': 116.397499,
      'province': '北京市',
      'city': '北京市',
      'district': '东城区',
      'adCode': '110101',
      'level': '兴趣点',
    });

    expect(result.formattedAddress, '北京市东城区天安门');
    expect(result.position.latitude, 39.908722);
    expect(result.position.longitude, 116.397499);
    expect(result.adCode, '110101');
  });

  test('ReGeocodeResult decodes map fields', () {
    final result = ReGeocodeResult.decodeFromMap(<String, dynamic>{
      'formattedAddress': '北京市东城区东长安街',
      'latitude': 39.908722,
      'longitude': 116.397499,
      'province': '北京市',
      'city': '北京市',
      'district': '东城区',
      'adCode': '110101',
      'roads': <String>['东长安街'],
      'crosses': <String>['东长安街 / 广场东侧路'],
      'aois': <String>['天安门广场'],
      'pois': <Map<String, dynamic>>[
        <String, dynamic>{
          'poiId': 'poi-1',
          'name': '天安门',
          'latitude': 39.908722,
          'longitude': 116.397499,
          'distance': 88,
          'typeCode': '110000',
        },
      ],
      'raw': <String, dynamic>{'platform': 'android'},
    });

    expect(result.formattedAddress, '北京市东城区东长安街');
    expect(
      result.position,
      Position(latitude: 39.908722, longitude: 116.397499),
    );
    expect(result.roads, <String>['东长安街']);
    expect(result.crosses, <String>['东长安街 / 广场东侧路']);
    expect(result.aois, <String>['天安门广场']);
    expect(result.pois.single.name, '天安门');
    expect(result.pois.single.distance, 88);
    expect(result.pois.single.typeCode, '110000');
    expect(result.raw, <String, dynamic>{'platform': 'android'});
  });

  test('Location encodes and decodes coordinates and accuracy', () {
    final location = Location(
      position: Position(latitude: 39.908722, longitude: 116.397499),
      heading: 90,
      accuracy: 5.5,
    );

    final decoded = Location.decode(location.encode() as List<Object?>);
    expect(decoded.position, location.position);
    expect(decoded.heading, 90);
    expect(decoded.accuracy, 5.5);
  });

  test('Live weather decodes channel map and resolves package asset', () {
    final weather = LocalWeatherLive.decodeFromMap(<String, dynamic>{
      'city': '北京市',
      'adCode': '110000',
      'weather': '晴',
      'temperature': '26',
      'humidity': '35',
      'reportTime': '2026-09-02 12:00:00',
    });

    expect(weather.city, '北京市');
    expect(weather.temperature, '26');
    expect(
      weather.iconPath,
      startsWith('packages/flutter_amap/assets/weather/'),
    );
  });
}
