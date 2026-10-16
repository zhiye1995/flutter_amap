import 'package:flutter_amap_navi/flutter_amap_navi.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('NaviPosition normalizes coordinates and supports value equality', () {
    final position = NaviPosition(latitude: 100, longitude: 190);
    expect(position, NaviPosition(latitude: 90, longitude: -170));
    expect(NaviPosition.decode(position.encode() as List<Object?>), position);
  });

  test('NaviConfig encodes extended route options', () {
    final config = NaviConfig(
      carNumber: '京A12345',
      naviType: NaviType.driver,
      start: NaviPoint(
        position: NaviPosition(latitude: 39.9, longitude: 116.3),
        poiId: 'start-poi',
        startAngle: 90,
      ),
      end: NaviPoint(
        position: NaviPosition(latitude: 39.99, longitude: 116.48),
      ),
      drivingStrategy: NaviDrivingStrategy.drivingMultipleRoutesDefault,
      travelStrategy: 1,
      multipleRoute: false,
      startNaviDirectly: true,
      vehicleInfo: NaviVehicleInfo(type: 1, height: 3.9, axisNums: 6),
      androidActivityClassName: 'com.example.CustomNaviActivity',
    );

    final decoded = NaviConfig.decode(config.encode() as List<Object?>);
    expect(decoded.carNumber, '京A12345');
    expect(decoded.start?.poiId, 'start-poi');
    expect(decoded.start?.startAngle, 90);
    expect(
      decoded.drivingStrategy,
      NaviDrivingStrategy.drivingMultipleRoutesDefault,
    );
    expect(decoded.travelStrategy, 1);
    expect(decoded.multipleRoute, false);
    expect(decoded.startNaviDirectly, true);
    expect(decoded.vehicleInfo?.axisNums, 6);
    expect(decoded.androidActivityClassName, 'com.example.CustomNaviActivity');
  });

  test('NaviDrivingStrategy preserves all native strategy IDs', () {
    expect(
      NaviDrivingStrategy.values.map((e) => e.id),
      orderedEquals(List<int>.generate(21, (index) => index)),
    );
    expect(
      NaviDrivingStrategy.fromId(20),
      NaviDrivingStrategy.drivingMultipleRoutesPriorityHighspeedAvoidCongestion,
    );
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
    expect(decoded.allowsBackgroundLocationUpdates, false);
    expect(decoded.pausesLocationUpdatesAutomatically, true);
  });

  test('CruiseConfig keeps background location opt-in', () {
    final config = CruiseConfig(mode: CruiseBroadcastMode.both);
    expect(config.allowsBackgroundLocationUpdates, false);
    expect(
      CruiseConfig.decode(<Object?>[CruiseBroadcastMode.both.code, true]),
      isA<CruiseConfig>().having(
        (value) => value.allowsBackgroundLocationUpdates,
        'allowsBackgroundLocationUpdates',
        false,
      ),
    );
  });

  test('cruise facility and congestion preserve native details', () {
    final facility = CruiseTrafficFacilityItem.decodeFromMap(
      <String, dynamic>{
        'source': 'unified',
        'type': 7,
        'latitude': 39.9,
        'longitude': 116.3,
        'remainDistanceMeters': 320,
        'speedLimitKmh': 60,
      },
    );
    final congestion = CruiseCongestionInfo.decodeFromMap(<String, dynamic>{
      'roadName': '测试道路',
      'lengthMeters': 800,
      'status': 3,
      'estimatedTimeSeconds': 420,
      'links': <Map<String, dynamic>>[
        <String, dynamic>{
          'status': 3,
          'coords': <Map<String, double>>[
            <String, double>{'latitude': 39.9, 'longitude': 116.3},
          ],
        },
      ],
    });

    expect(facility.type, 7);
    expect(facility.remainDistanceMeters, 320);
    expect(congestion.estimatedTimeSeconds, 420);
    expect(congestion.links.single.status, 3);
    expect(congestion.links.single.coords.single.latitude, 39.9);
  });
}
