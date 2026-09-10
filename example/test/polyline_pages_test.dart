import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_amap_plus/flutter_amap.dart';
import 'package:flutter_amap_example/features/map_3d/map_overlay/polyline_pages.dart';
import 'package:flutter_test/flutter_test.dart';

class _Map extends AMapFlutterPlatformInterface {
  final writes = <Polyline>[];
  final removals = <String>[];
  List<Position> fitted = [];
  final markers = <String, Marker>{};
  final arrows = <NavigateArrow>[];
  final arcs = <Arc>[];
  @override
  Future<void> addMarker(Marker marker, {required int mapId}) async {
    markers[marker.id] = marker;
  }

  @override
  Future<void> removeMarker(String id, {required int mapId}) async {
    markers.remove(id);
  }

  @override
  Future<void> addNavigateArrow(
    NavigateArrow arrow, {
    required int mapId,
  }) async {
    arrow.validate();
    arrows.add(arrow);
  }

  @override
  Future<void> addArc(Arc arc, {required int mapId}) async {
    arc.validate();
    arcs.add(arc);
  }

  Completer<void>? hold;
  bool fail = false;
  @override
  Future<void> addPolyline(Polyline value, {required int mapId}) async {
    value.validate();
    await hold?.future;
    if (fail) throw PlatformException(code: 'test_failure');
    writes.add(value);
  }

  @override
  Future<void> removePolyline(String id, {required int mapId}) async {
    removals.add(id);
  }

  @override
  Future<void> moveCameraToFitPosition(
    List<Position>? positions,
    EdgePadding padding,
    int duration, {
    required int mapId,
  }) async {
    fitted = positions ?? [];
  }

  @override
  Future<void> destroy({required int mapId}) async {}
}

void main() {
  late AMapFlutterPlatformInterface original;
  late _Map platform;
  AMapController? controller;
  setUp(() {
    original = AMapFlutterPlatformInterface.instance;
    platform = _Map();
    AMapFlutterPlatformInterface.instance = platform;
  });
  tearDown(() async {
    await controller?.destroy();
    controller = null;
    AMapFlutterPlatformInterface.instance = original;
  });
  Future<void> start(WidgetTester tester, Widget page) async {
    await tester.pumpWidget(
      MaterialApp(home: page, builder: EasyLoading.init()),
    );
    final map = tester.widget<AMapWidget>(find.byType(AMapWidget));
    controller = AMapController(map, mapId: 71);
    map.onMapCreated!(controller!);
    platform.mapEventStreamController.add(MapCompleteEvent(71));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    EasyLoading.dismiss(animation: false);
    await tester.pump();
  }

  testWidgets(
    'two-point geodesic fits its interior and removes stale city markers',
    (tester) async {
      await start(tester, const GeodesicPolylinePage());
      await tester.ensureVisible(find.text('切换两点远距离'));
      await tester.tap(find.text('切换两点远距离'));
      await tester.pump();
      expect(platform.writes.last.geodesic, isTrue);
      expect(platform.writes.last.points, hasLength(2));
      expect(platform.fitted.any((p) => p.latitude > 52), isTrue);
      expect(platform.markers.values.map((m) => m.title).toSet(), {'北京', '伦敦'});
    },
    variant: TargetPlatformVariant.only(TargetPlatform.windows),
  );

  testWidgets('arrow page updates width with valid native geometry', (
    tester,
  ) async {
    await start(tester, const NavigateArrowPage());
    expect(platform.arrows, hasLength(1));
    await tester.tap(find.text('粗箭头'));
    await tester.pump();
    expect(platform.arrows.last.width, 24);
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

  testWidgets('arc page switches between valid control points', (tester) async {
    await start(tester, const ArcPolylinePage());
    expect(platform.arcs, hasLength(1));
    final first = platform.arcs.first.passed;
    await tester.tap(find.text('切换途经点'));
    await tester.pump();
    expect(platform.arcs.last.passed, isNot(first));
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

  testWidgets(
    'style changes submit only affected lines and retries keep desired state',
    (tester) async {
      await start(tester, const PolylineStylePage());
      expect(platform.writes, hasLength(5));
      expect(platform.writes[2].textureIndexes, [0, 1, 0, 1]);
      platform.writes.clear();
      await tester.ensureVisible(find.text('蓝线置底'));
      await tester.tap(find.text('蓝线置底'));
      await tester.pump();
      expect(platform.writes.map((p) => p.id).toSet(), {
        'polyline_style_z_back',
        'polyline_style_z_front',
      });
      expect(platform.removals, isEmpty);
      platform.fail = true;
      await tester.ensureVisible(find.text('关闭纹理'));
      await tester.tap(find.text('关闭纹理'));
      await tester.pump();
      expect(find.text('更新未完成，请重试。'), findsOneWidget);
      platform.fail = false;
      platform.writes.clear();
      await tester.ensureVisible(find.text('重试'));
      await tester.tap(find.text('重试'));
      await tester.pump();
      expect(platform.writes, hasLength(2));
      expect(platform.writes.every((p) => !p.useTexture), isTrue);
      expect(find.text('更新未完成，请重试。'), findsNothing);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.windows),
  );

  testWidgets('in-flight draw disables competing mutations', (tester) async {
    await start(tester, const MultiColorPolylinePage());
    platform.hold = Completer<void>();
    await tester.tap(find.text('切换为渐变'));
    await tester.pump();
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '切换为分段'),
    );
    expect(button.onPressed, isNull);
    platform.hold!.complete();
    await tester.pump();
    expect(platform.writes.last.gradient, isTrue);
    expect(platform.writes.last.colors, hasLength(5));
    expect(platform.removals, isEmpty);
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

  testWidgets('clear and undo never submit fewer than two points', (
    tester,
  ) async {
    await start(tester, const PolylinesPage());
    await tester.ensureVisible(find.text('清空节点'));
    await tester.tap(find.text('清空节点'));
    await tester.pump();
    expect(platform.removals, contains('polyline_basic_demo'));
    final map = tester.widget<AMapWidget>(find.byType(AMapWidget));
    map.onMapPress!(Position(latitude: 30, longitude: 120));
    await tester.pump();
    expect(platform.writes, hasLength(1));
    map.onMapPress!(Position(latitude: 31, longitude: 121));
    await tester.pump();
    expect(platform.writes.last.points, hasLength(2));
    map.onMapPress!(Position(latitude: 31, longitude: 121));
    await tester.pump();
    expect(platform.writes, hasLength(2));
    await tester.pumpWidget(const SizedBox());
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));
}
