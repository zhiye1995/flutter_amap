import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter_amap_navi/flutter_amap_navi.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('combined example can use independent map and navigation models', () {
    final mapPosition = Position(latitude: 39.9, longitude: 116.3);
    final naviPosition = NaviPosition(
      latitude: mapPosition.latitude,
      longitude: mapPosition.longitude,
    );

    expect(naviPosition.latitude, mapPosition.latitude);
    expect(NaviDrivingStrategy.fromId(20).id, 20);
  });
}
