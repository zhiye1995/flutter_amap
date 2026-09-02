import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('map entrypoint does not include navigation parts', () {
    final candidates = <File>[
      File('lib/flutter_amap.dart'),
      File('packages/flutter_amap/lib/flutter_amap.dart'),
    ];
    final entrypoint = candidates
        .firstWhere((file) => file.existsSync())
        .readAsStringSync();

    expect(entrypoint, isNot(contains('api/amap_navi.dart')));
    expect(entrypoint, isNot(contains('models/navi.dart')));
    expect(entrypoint, isNot(contains('NaviEvent')));
    expect(entrypoint, isNot(contains('CruiseEvent')));
  });
}
