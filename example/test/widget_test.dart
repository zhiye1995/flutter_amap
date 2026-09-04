import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter_amap_navi/flutter_amap_navi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_amap_example/features/navigation/component_route_pages.dart';
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

  testWidgets('waypoint and direct navigation pages build official samples', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: WayPointRoutePage()));
    expect(find.textContaining('立水桥(北5环)'), findsOneWidget);
    expect(find.textContaining('途经点 3'), findsOneWidget);
    expect(find.textContaining('新三余公园(南5环)'), findsOneWidget);

    await tester.pumpWidget(const MaterialApp(home: DirectNavigationPage()));
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('开始导航'), findsOneWidget);
    expect(find.text('导航事件与图标调试'), findsOneWidget);
  });
}
