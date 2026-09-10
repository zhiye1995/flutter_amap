import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_amap_plus/flutter_amap_plus.dart';
import 'package:flutter_test/flutter_test.dart';

class _SearchPlatform extends AMapFlutterPlatformInterface {
  final requests = <Position>[];
  Future<List<PoiItem>> Function() response = () async => [];

  @override
  Future<List<PoiItem>> searchPOIAround({
    required Position center,
    String? keywords,
    String? types,
    int? radius,
    int page = 1,
    int pageSize = 20,
    String? city,
  }) {
    requests.add(center);
    return response();
  }
}

void testPicker(String name, WidgetTesterCallback callback) {
  testWidgets(
    name,
    callback,
    variant: TargetPlatformVariant.only(TargetPlatform.windows),
  );
}

void main() {
  late _SearchPlatform platform;
  late AMapFlutterPlatformInterface previous;
  final position = Position(latitude: 39.9, longitude: 116.4);
  final elsewhere = Position(latitude: 31.2, longitude: 121.5);
  PoiItem poi(String id, String name, [Position? at]) =>
      PoiItem(poiId: id, name: name, position: at ?? position, address: '原地址');

  setUp(() {
    previous = AMapFlutterPlatformInterface.instance;
    platform = _SearchPlatform();
    AMapFlutterPlatformInterface.instance = platform;
  });
  tearDown(() {
    AMapFlutterPlatformInterface.instance = previous;
  });

  Future<void> open(
    WidgetTester tester,
    MapPlacePickerConfig config, {
    ValueChanged<PoiItem?>? onResult,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () async {
                  final result = await AMapMapPlacePicker.show(
                    context,
                    config: config,
                  );
                  onResult?.call(result);
                },
                child: const Text('打开'),
              ),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('打开'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
  }

  testPicker('initial POI wins and remains confirmable during pending search', (
    tester,
  ) async {
    final original = poi('original', '原地点');
    final pending = Completer<List<PoiItem>>();
    platform.response = () => pending.future;
    PoiItem? result;
    await open(
      tester,
      MapPlacePickerConfig(initialPoi: original, initialPosition: elsewhere),
      onResult: (value) => result = value,
    );
    final map = tester.widget<AMapWidget>(find.byType(AMapWidget));
    expect(map.initCameraPosition?.position, same(position));
    expect(
      map.userLocationStyle?.userLocationType,
      UserLocationType.locationTypeShow,
    );
    expect(platform.requests.single, same(position));
    map.onUserLocationChange!(Location(position: elsewhere));
    map.onCameraChangeFinish!(CameraPosition(position: elsewhere));
    await tester.pump(const Duration(seconds: 1));
    expect(platform.requests, hasLength(1));
    expect(find.text('原地点'), findsOneWidget);
    await tester.tap(find.text('发送'));
    await tester.pumpAndSettle();
    expect(result, same(original));
    pending.complete([]);
    await tester.pump();
  });

  testPicker(
    'deduplicates IDs and nameless-ID coordinate matches without replacing original',
    (tester) async {
      final original = poi('original', '原地点');
      platform.response = () async => [
        poi('original', '服务端新名称', elsewhere),
        poi('', '原地点'),
        poi('other', '附近地点', elsewhere),
      ];
      PoiItem? result;
      await open(
        tester,
        MapPlacePickerConfig(initialPoi: original),
        onResult: (value) => result = value,
      );
      expect(find.text('原地点'), findsOneWidget);
      expect(find.text('服务端新名称'), findsNothing);
      expect(find.text('附近地点'), findsOneWidget);
      await tester.tap(find.text('发送'));
      await tester.pumpAndSettle();
      expect(result, same(original));
    },
  );

  testPicker(
    'failed nearby search keeps original and supports retry with empty results',
    (tester) async {
      final original = poi('', '原地点');
      platform.response = () async => throw Exception('offline');
      PoiItem? result;
      await open(
        tester,
        MapPlacePickerConfig(initialPoi: original),
        onResult: (value) => result = value,
      );
      expect(find.text('原地点'), findsOneWidget);
      expect(find.text('重试'), findsOneWidget);
      platform.response = () async => [];
      await tester.tap(find.text('重试'));
      await tester.pumpAndSettle();
      expect(platform.requests, hasLength(2));
      expect(find.text('原地点'), findsOneWidget);
      await tester.tap(find.text('发送'));
      await tester.pumpAndSettle();
      expect(result, same(original));
    },
  );

  testPicker(
    'coordinate-only input disables recentering and keeps nearby default',
    (tester) async {
      platform.response = () async => [poi('near', '附近地点')];
      await open(tester, MapPlacePickerConfig(initialPosition: position));
      final map = tester.widget<AMapWidget>(find.byType(AMapWidget));
      expect(map.initCameraPosition?.position, same(position));
      expect(
        map.userLocationStyle?.userLocationType,
        UserLocationType.locationTypeShow,
      );
      expect(find.text('附近地点'), findsOneWidget);
    },
  );

  testPicker('no initial input searches first location', (tester) async {
    await open(tester, const MapPlacePickerConfig());
    final map = tester.widget<AMapWidget>(find.byType(AMapWidget));
    expect(
      map.userLocationStyle?.userLocationType,
      UserLocationType.locationTypeLocate,
    );
    map.onUserLocationChange!(Location(position: elsewhere));
    await tester.pumpAndSettle();
    expect(platform.requests.single, same(elsewhere));
  });
  testPicker('choosing another POI returns the new selection', (tester) async {
    final nearby = poi('near', '附近地点', elsewhere);
    platform.response = () async => [nearby];
    PoiItem? result;
    await open(
      tester,
      MapPlacePickerConfig(initialPoi: poi('old', '原地点')),
      onResult: (value) => result = value,
    );
    await tester.tap(find.text('附近地点'));
    await tester.pump();
    await tester.tap(find.text('发送'));
    await tester.pumpAndSettle();
    expect(result, same(nearby));
  });

  testPicker('location button releases original and searches user location', (
    tester,
  ) async {
    await open(tester, MapPlacePickerConfig(initialPoi: poi('old', '原地点')));
    final map = tester.widget<AMapWidget>(find.byType(AMapWidget));
    map.onUserLocationChange!(Location(position: elsewhere));
    platform.response = () async => [poi('near', '定位附近', elsewhere)];
    await tester.tap(find.byIcon(Icons.my_location));
    await tester.pumpAndSettle();
    expect(platform.requests.last, same(elsewhere));
    expect(find.text('原地点'), findsNothing);
    expect(find.text('定位附近'), findsOneWidget);
  });

  testPicker('drag releases original and ignores pending initial search', (
    tester,
  ) async {
    final pending = Completer<List<PoiItem>>();
    platform.response = () => pending.future;
    await open(tester, MapPlacePickerConfig(initialPoi: poi('old', '原地点')));
    final map = tester.widget<AMapWidget>(find.byType(AMapWidget));
    final listener = tester
        .widgetList<Listener>(
          find.ancestor(
            of: find.byType(AMapWidget),
            matching: find.byType(Listener),
          ),
        )
        .firstWhere((widget) => widget.onPointerMove != null);
    listener.onPointerMove!(const PointerMoveEvent());
    platform.response = () async => [poi('new', '拖动位置', elsewhere)];
    map.onCameraChangeFinish!(CameraPosition(position: elsewhere));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    pending.complete([poi('stale', '过期结果')]);
    await tester.pumpAndSettle();
    expect(find.text('原地点'), findsNothing);
    expect(find.text('过期结果'), findsNothing);
    expect(find.text('拖动位置'), findsOneWidget);
  });
}
