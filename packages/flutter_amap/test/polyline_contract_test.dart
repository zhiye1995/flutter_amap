import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_amap_plus/flutter_amap_plus.dart';
import 'package:flutter_amap_plus/src/platform/message_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final points = List.generate(
    5,
    (i) => Position(latitude: 30 + i * .01, longitude: 120 + i * .02),
  );
  Polyline line() => Polyline(id: 'line', points: points);

  test('alternating textures require a valid index for every segment', () {
    final value = line().copyWith(
      useTexture: true,
      textures: [
        Bitmap(asset: 'a.png'),
        Bitmap(asset: 'b.png'),
      ],
      textureIndexes: [0, 1, 0, 1],
    );
    expect(value.validate, returnsNormally);
    for (final bad in [
      [1, 2, 3],
      [0, 1, 0, 2],
      [-1, 0, 0, 1],
      [0],
    ]) {
      expect(value.copyWith(textureIndexes: bad).validate, throwsArgumentError);
    }
    expect(value.copyWith(textureIndexes: []).validate, returnsNormally);
    expect(value.copyWith(useTexture: false).validate, throwsArgumentError);
  });

  test('segment colors and gradient anchors have separate contracts', () {
    expect(
      line()
          .copyWith(
            colors: [const Color(0xFFFF0000), const Color(0xFF0000FF)],
            colorIndexes: [0, 0, 1, 1],
          )
          .validate,
      returnsNormally,
    );
    expect(
      line()
          .copyWith(colors: [const Color(0xFFFF0000), const Color(0xFF0000FF)])
          .validate,
      throwsArgumentError,
    );
    expect(
      line()
          .copyWith(
            colors: List.filled(5, const Color(0xFFFF0000)),
            gradient: true,
          )
          .validate,
      returnsNormally,
    );
    expect(
      line()
          .copyWith(
            colors: List.filled(4, const Color(0xFFFF0000)),
            gradient: true,
          )
          .validate,
      throwsArgumentError,
    );
    expect(
      line()
          .copyWith(
            colors: List.filled(5, const Color(0xFFFF0000)),
            gradient: true,
            colorIndexes: [0, 1, 2, 3],
          )
          .validate,
      throwsArgumentError,
    );
  });

  test('rejects bad geometry, dimensions and unsupported combinations', () {
    for (final bad in [
      line().copyWith(width: 0),
      line().copyWith(width: double.nan),
      line().copyWith(zIndex: double.infinity),
      line().copyWith(id: ''),
      line().copyWith(points: [points.first]),
      line().copyWith(points: [points.first, points.first]),
      line().copyWith(
        points: [
          points.first,
          (Position(latitude: 30, longitude: 120)..latitude = 91),
        ],
      ),
      line().copyWith(
        geodesic: true,
        colors: List.filled(4, const Color(0xFFFF0000)),
      ),
      line().copyWith(useTexture: true),
      line().copyWith(
        useTexture: true,
        texture: Bitmap(asset: 'a'),
        textures: [Bitmap(asset: 'b')],
      ),
      line().copyWith(
        useTexture: true,
        texture: Bitmap(asset: 'a'),
        dottedLine: true,
      ),
    ]) {
      expect(bad.validate, throwsArgumentError);
    }
    expect(line().copyWith(geodesic: true).validate, returnsNormally);
  });

  test('arc rejects repeated and collinear points', () {
    Arc arc(Position a, Position b, Position c) =>
        Arc(id: 'arc', start: a, passed: b, end: c);
    expect(arc(points[0], points[0], points[2]).validate, throwsArgumentError);
    expect(
      arc(
        Position(latitude: 0, longitude: 0),
        Position(latitude: 0, longitude: 1),
        Position(latitude: 0, longitude: 2),
      ).validate,
      throwsArgumentError,
    );
    expect(
      arc(
        points[0],
        Position(latitude: 30.2, longitude: 120.01),
        points[2],
      ).validate,
      returnsNormally,
    );
  });

  test('new fields round-trip and legacy lists retain defaults', () {
    final value = line().copyWith(
      colors: [const Color(0xFFFF0000), const Color(0xFF0000FF)],
      colorIndexes: [0, 1, 0, 1],
      lineCap: PolylineCap.round,
      lineJoin: PolylineJoin.miter,
      dashType: PolylineDash.circle,
      clickable: true,
    );
    final encoded = value.encode() as List<Object?>;
    expect(Polyline.decode(encoded), value);
    final legacy = Polyline.decode(encoded.take(14).toList());
    expect(legacy.colorIndexes, isEmpty);
    expect(legacy.lineCap, PolylineCap.butt);
    expect(legacy.clickable, isFalse);
    expect(value.copyWith(clickable: false), isNot(value));
    expect(
      line()
          .copyWith(texture: Bitmap(asset: 'a'))
          .copyWith(clearTexture: true)
          .texture,
      isNull,
    );
  });

  const mapId = 43;
  const channel = MethodChannel(
    'plugins.flutter.dev/amap_43',
    StandardMethodCodec(AMapApiCodec()),
  );
  final platform = AMapFlutterMethodChannel();
  late AMapFlutterPlatformInterface original;
  late AMapController controller;
  final calls = <MethodCall>[];
  final clicks = <String>[];
  setUp(() async {
    original = AMapFlutterPlatformInterface.instance;
    AMapFlutterPlatformInterface.instance = platform;
    await platform.init(mapId, null);
    controller = AMapController(
      AMapWidget(onPolylineClick: clicks.add),
      mapId: mapId,
    );
    calls.clear();
    clicks.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return null;
        });
  });
  tearDown(() async {
    await controller.destroy();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    AMapFlutterPlatformInterface.instance = original;
  });

  test('update sends no remove and invalid update sends nothing', () async {
    await controller.addPolyline(line());
    await controller.updatePolyline(line().copyWith(width: 18));
    await expectLater(
      controller.updatePolyline(line().copyWith(width: -1)),
      throwsArgumentError,
    );
    expect(calls.map((c) => c.method), ['addPolyline', 'addPolyline']);
    expect(
      (calls.last.arguments as Map)['polyline'],
      line().copyWith(width: 18),
    );
  });

  test('strict wait reports timeout then recovers on completion', () async {
    await expectLater(
      controller.waitForMapCompleted(
        timeout: const Duration(milliseconds: 1),
        throwOnTimeout: true,
      ),
      throwsA(isA<TimeoutException>()),
    );
    platform.mapEventStreamController.add(MapCompleteEvent(mapId));
    await controller.waitForMapCompleted(
      timeout: const Duration(seconds: 1),
      throwOnTimeout: true,
    );
  });

  test('click events are scoped by map ID', () async {
    platform.mapEventStreamController.add(
      PolylineClickEvent(mapId + 1, 'wrong'),
    );
    platform.mapEventStreamController.add(PolylineClickEvent(mapId, 'line'));
    await Future<void>.delayed(Duration.zero);
    expect(clicks, ['line']);
  });
}
