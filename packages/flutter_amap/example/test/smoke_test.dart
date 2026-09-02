import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('map example depends only on map public models', () {
    final position = Position(latitude: 39.9, longitude: 116.3);
    expect(position.latitude, 39.9);
  });
}
