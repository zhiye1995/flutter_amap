import 'dart:typed_data';

import 'package:flutter_amap_navi/flutter_amap_navi.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('late PNG replaces stale image without changing turn type', () {
    final rightTurn = Uint8List.fromList([1, 2, 3]);
    final uTurn = Uint8List.fromList([4, 5, 6]);
    NaviInfo.decodeFromMap({'iconType': 3, 'iconPng': rightTurn});
    final stale = NaviInfo.decodeFromMap({
      'iconType': 8,
      'iconPng': rightTurn,
    });
    expect(stale.icon, orderedEquals(rightTurn));

    final corrected = NaviInfo.decodeFromMap({
      'iconType': 8,
      'iconPng': uTurn,
    });
    expect(corrected.iconType, 8);
    expect(corrected.icon, orderedEquals(uTurn));
    expect(corrected.isIconFromNative, isTrue);
    expect(
      NaviInfo.decodeFromMap({'iconType': 8}).icon,
      orderedEquals(uTurn),
    );
    expect(
      NaviInfo.decodeFromMap({'iconType': 3}).icon,
      orderedEquals(rightTurn),
    );
  });
}
