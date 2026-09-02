import 'package:flutter/services.dart';
import 'package:flutter_amap_navi/flutter_amap_navi.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const initializerChannel = MethodChannel(
    'plugins.flutter.dev/amap_navi_initializer',
  );
  const naviChannel = MethodChannel('plugins.flutter.dev/amap_navi');

  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(initializerChannel, null);
    messenger.setMockMethodCallHandler(naviChannel, null);
  });

  test('navigation requires explicit initialization', () async {
    expect(
      () => AMapNavi.startNavigation(config: NaviConfig()),
      throwsStateError,
    );
    expect(
      () => AMapNavi.startCruiseMode(mode: CruiseBroadcastMode.both),
      throwsStateError,
    );
  });

  test('initialize and start use navigation-only channels', () async {
    final calls = <MethodCall>[];
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(initializerChannel, (call) async {
      calls.add(call);
      return null;
    });
    messenger.setMockMethodCallHandler(naviChannel, (call) async {
      calls.add(call);
      return null;
    });

    await AMapNavi.init(
      config: const NaviSdkConfig(
        apiKey: NaviApiKey(iosKey: 'ios', androidKey: 'android'),
        agreePrivacy: true,
        preloadNaviIcons: false,
      ),
    );
    await AMapNavi.startNavigation(
      config: NaviConfig(
        end: NaviPoint(
          position: NaviPosition(latitude: 39.9, longitude: 116.3),
        ),
      ),
    );

    expect(calls[0].method, 'initialize');
    expect(calls[0].arguments, containsPair('agreePrivacy', true));
    expect(calls[1].method, 'startNavigation');
    expect(calls[1].arguments, containsPair('endLat', 39.9));
    expect(AMapNavi.isNavigating, true);
    expect(
      () => AMapNavi.startCruiseMode(mode: CruiseBroadcastMode.both),
      throwsStateError,
    );
    await AMapNavi.stopNavigation();
  });

  test('navigation cannot start while cruise mode is active', () async {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(naviChannel, (_) async => null);

    await AMapNavi.startCruiseMode(mode: CruiseBroadcastMode.both);
    expect(AMapNavi.isCruising, true);
    expect(
      () => AMapNavi.startNavigation(config: NaviConfig()),
      throwsStateError,
    );
    await AMapNavi.stopCruiseMode();
  });

  test('repeated initialization applies the latest configuration', () async {
    final calls = <MethodCall>[];
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(initializerChannel, (call) async {
      calls.add(call);
      return null;
    });

    await AMapNavi.init(
      config: const NaviSdkConfig(
        apiKey: NaviApiKey(iosKey: 'ios-old', androidKey: 'android-old'),
        agreePrivacy: false,
        preloadNaviIcons: false,
      ),
    );
    await AMapNavi.init(
      config: const NaviSdkConfig(
        apiKey: NaviApiKey(iosKey: 'ios-new', androidKey: 'android-new'),
        agreePrivacy: true,
        preloadNaviIcons: false,
      ),
    );

    expect(calls, hasLength(2));
    expect(calls.last.arguments, containsPair('iosKey', 'ios-new'));
    expect(calls.last.arguments, containsPair('androidKey', 'android-new'));
    expect(calls.last.arguments, containsPair('agreePrivacy', true));
  });

  test('cruise facility streams stay separated', () async {
    final platform = AMapNaviMethodChannel();
    final trafficFuture = platform.onCruiseTrafficFacility.first;
    final cameraFuture = platform.onCruiseElecCameraInfo.first;

    platform.naviEventStreamController.add(
      CruiseTrafficFacilityEvent(<CruiseTrafficFacilityItem>[
        CruiseTrafficFacilityItem(
          source: CruiseTrafficFacilitySource.specialRoad,
        ),
      ]),
    );
    platform.naviEventStreamController.add(
      CruiseElecCameraInfoEvent(<CruiseTrafficFacilityItem>[
        CruiseTrafficFacilityItem(
          source: CruiseTrafficFacilitySource.elecCamera,
        ),
      ]),
    );

    expect(
      (await trafficFuture).facilities.single.source,
      CruiseTrafficFacilitySource.specialRoad,
    );
    expect(
      (await cameraFuture).cameraInfos.single.source,
      CruiseTrafficFacilitySource.elecCamera,
    );
  });
}
