import 'package:flutter/services.dart';
import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter_amap/src/platform/message_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const mapId = 19;
  const channelName = 'plugins.flutter.dev/amap_$mapId';
  const channel = MethodChannel(
    channelName,
    StandardMethodCodec(AMapApiCodec()),
  );
  final platform = AMapFlutterMethodChannel();
  final marker = Marker(
    id: 'car',
    position: Position(latitude: 30, longitude: 120),
  );
  final points = <Position>[
    Position(latitude: 30, longitude: 120),
    Position(latitude: 30.1, longitude: 120.1),
  ];

  setUp(() async {
    await platform.init(mapId, null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('sends the complete smooth move command set', () async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return null;
        });

    await platform.startSmoothMoveMarker(marker, points, 8000, mapId: mapId);
    await platform.pauseSmoothMoveMarker(marker.id, mapId: mapId);
    await platform.resumeSmoothMoveMarker(marker.id, mapId: mapId);
    await platform.stopSmoothMoveMarker(marker.id, mapId: mapId);

    expect(calls.map((call) => call.method), <String>[
      'startSmoothMoveMarker',
      'pauseSmoothMoveMarker',
      'resumeSmoothMoveMarker',
      'stopSmoothMoveMarker',
    ]);
    expect(calls.first.arguments, <String, dynamic>{
      'marker': marker,
      'points': points,
      'durationMs': 8000,
    });
    expect(calls.last.arguments, <String, dynamic>{'markerId': marker.id});
  });

  test(
    'controller rejects invalid points and cross-platform durations',
    () async {
      final controller = AMapController(const AMapWidget(), mapId: mapId);

      expect(
        () => controller.startSmoothMoveMarker(
          marker: marker,
          points: points.take(1).toList(),
          duration: const Duration(seconds: 1),
        ),
        throwsArgumentError,
      );
      expect(
        () => controller.startSmoothMoveMarker(
          marker: marker,
          points: <Position>[points.first, points.first],
          duration: const Duration(seconds: 1),
        ),
        throwsArgumentError,
      );
      expect(
        () => controller.startSmoothMoveMarker(
          marker: marker,
          points: points,
          duration: const Duration(milliseconds: 1500),
        ),
        throwsArgumentError,
      );

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (_) async => null);
      await controller.destroy();
    },
  );

  test('decodes smooth move progress events', () async {
    final eventFuture = platform.onSmoothMoveMarkerProgress(mapId: mapId).first;
    const codec = StandardMethodCodec(AMapApiCodec());
    final data = codec.encodeMethodCall(
      MethodCall('onSmoothMoveMarkerProgress', <String, dynamic>{
        'markerId': marker.id,
        'position': points.first,
        'progress': 0.25,
        'remainingDistance': 75.5,
      }),
    );

    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(channelName, data, (_) {});
    final event = await eventFuture;

    expect(event.value, marker.id);
    expect(event.position, points.first);
    expect(event.progress, 0.25);
    expect(event.remainingDistance, 75.5);
  });

  test('controller tracks smooth move status', () async {
    final defaultPlatform = AMapFlutterPlatformInterface.instance;
    await defaultPlatform.init(mapId, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => null);
    final controller = AMapController(const AMapWidget(), mapId: mapId);

    expect(
      controller.smoothMoveMarkerStatus(marker.id),
      SmoothMoveMarkerStatus.idle,
    );
    await controller.startSmoothMoveMarker(
      marker: marker,
      points: points,
      duration: const Duration(seconds: 2),
    );
    expect(
      controller.smoothMoveMarkerStatus(marker.id),
      SmoothMoveMarkerStatus.moving,
    );
    await controller.pauseSmoothMoveMarker(marker.id);
    expect(
      controller.smoothMoveMarkerStatus(marker.id),
      SmoothMoveMarkerStatus.paused,
    );
    await controller.resumeSmoothMoveMarker(marker.id);
    expect(
      controller.smoothMoveMarkerStatus(marker.id),
      SmoothMoveMarkerStatus.moving,
    );
    await controller.stopSmoothMoveMarker(marker.id);
    expect(
      controller.smoothMoveMarkerStatus(marker.id),
      SmoothMoveMarkerStatus.idle,
    );

    await controller.destroy();
  });
}
