import 'package:flutter_amap_navi/flutter_amap_navi.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('navigation example depends only on navigation public models', () {
    final position = NaviPosition(latitude: 39.9, longitude: 116.3);
    expect(position.latitude, 39.9);
    expect(NaviDrivingStrategy.values, hasLength(21));
  });
}
