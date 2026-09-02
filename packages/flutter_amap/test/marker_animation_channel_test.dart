import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_amap/flutter_amap.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const int mapId = 7;
  const String channelName = 'plugins.flutter.dev/amap_$mapId';
  const MethodChannel channel = MethodChannel(channelName);
  final AMapFlutterMethodChannel platform = AMapFlutterMethodChannel();

  setUp(() async {
    await platform.init(mapId, null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('animateMarker sends stable animation code', () async {
    final List<MethodCall> calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          calls.add(call);
          return null;
        });

    await platform.animateMarker(
      'marker-1',
      MarkerAnimationKind.moveRoundTrip,
      1200,
      mapId: mapId,
    );

    expect(calls, hasLength(1));
    expect(calls.single.method, 'animateMarker');
    expect(calls.single.arguments, <String, dynamic>{
      'markerId': 'marker-1',
      'kind': MarkerAnimationKind.moveRoundTrip.code,
      'durationMs': 1200,
    });
  });

  test('cancelMarkerAnimation sends marker id', () async {
    final List<MethodCall> calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          calls.add(call);
          return null;
        });

    await platform.cancelMarkerAnimation('marker-1', mapId: mapId);

    expect(calls, hasLength(1));
    expect(calls.single.method, 'cancelMarkerAnimation');
    expect(calls.single.arguments, <String, dynamic>{'markerId': 'marker-1'});
  });
}
