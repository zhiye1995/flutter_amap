part of '../../flutter_amap.dart';

/// Controller for a single AMap instance running on the host platform,
/// which passed in [AMapWidget.onMapCreated] callback.
class AMapController {
  AMapController(
    this._aMapFlutter, {
    required this.mapId,
  }) {
    _connectStreams(mapId);
  }

  /// The mapId for this controller
  final int mapId;

  /// The map state for a single AMap instance
  final AMapWidget _aMapFlutter;

  final Completer<void> _mapCompletedCompleter = Completer<void>();
  bool _isDestroyed = false;

  /// 当前地图视野（内部追踪，用于 zoomIn/zoomOut 等操作）
  CameraPosition? _currentCamera;

  final List<StreamSubscription<dynamic>> _subscriptions =
      <StreamSubscription<dynamic>>[];

  Stream<SmoothMoveMarkerCompleteEvent> get onSmoothMoveMarkerCompleted =>
      AMapFlutterPlatformInterface.instance.onSmoothMoveMarkerCompleted(
        mapId: mapId,
      );

  void _listen<T extends Object?>(Stream<T> stream, void Function(T) onData) {
    _subscriptions.add(stream.listen(onData));
  }

  /// 等待地图加载完成（onMapCompleted / onMapLoaded）。
  ///
  /// 说明：
  /// - 很多相机相关操作（如 moveCamera）在地图尚未完全加载时调用，原生侧可能会被丢弃或被初始化流程覆盖，
  ///   表现为视野仍停留在默认位置（常见为“北京”）。
  /// - 本方法用于在 Dart 侧统一等待地图完成事件后再执行。
  Future<void> waitForMapCompleted({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (_isDestroyed) return;
    // 若已经完成，直接返回；否则等待一次完成事件。
    try {
      await _mapCompletedCompleter.future.timeout(timeout);
    } catch (_) {
      // 超时不抛错：保持兼容性（调用方可能未 await），同时允许继续走原生调用（但可能仍不生效）。
      // 真正稳定的做法是确保 onMapCompleted 能按预期触发。
    }
  }

  void _connectStreams(int mapId) {
    _listen<MapEvent<Object?>>(
      AMapFlutterPlatformInterface.instance.mapEventStreamController.stream
          .where((MapEvent<Object?> event) => event.mapId == mapId),
      (MapEvent<Object?> event) {
        if (_isDestroyed) {
          return;
        }
        switch (event) {
          case MapInitCompleteEvent():
            _aMapFlutter.onMapInitComplete?.call();
          case MapCompleteEvent():
            if (!_mapCompletedCompleter.isCompleted) {
              _mapCompletedCompleter.complete();
            }
            _aMapFlutter.onMapCompleted?.call();
          case MapPressEvent():
            _aMapFlutter.onMapPress?.call(event.position);
          case MapLongPressEvent():
            _aMapFlutter.onMapLongPress?.call(event.position);
          case CameraChangeEvent():
            _currentCamera = event.value;
            _aMapFlutter.onCameraChange?.call(event.value);
          case CameraChangeStartEvent():
            _aMapFlutter.onCameraChangeStart?.call(event.value);
          case CameraChangeFinishEvent():
            _currentCamera = event.value;
            _aMapFlutter.onCameraChangeFinish?.call(event.value);
          case MapMoveStartEvent():
            _aMapFlutter.onMapMoveStart?.call(event.position);
          case MapMoveEvent():
            _aMapFlutter.onMapMove?.call(event.position);
          case MapMoveEndEvent():
            _aMapFlutter.onMapMoveEnd?.call(event.position);
          case MapResizedEvent():
            _aMapFlutter.onMapResized?.call(event.value);
          case ZoomChangeEvent():
            _aMapFlutter.onZoomChange?.call(event.value);
          case ZoomChangeStartEvent():
            _aMapFlutter.onZoomChangeStart?.call(event.value);
          case ZoomChangeEndEvent():
            _aMapFlutter.onZoomChangeEnd?.call(event.value);
          case RotateChangeEvent():
            _aMapFlutter.onRotateChange?.call(event.value);
          case RotateChangeStartEvent():
            _aMapFlutter.onRotateChangeStart?.call(event.value);
          case RotateChangeEndEvent():
            _aMapFlutter.onRotateChangeEnd?.call(event.value);
          case PoiClickEvent():
            _aMapFlutter.onPoiClick?.call(event.value);
          case MarkerClickEvent():
            _aMapFlutter.onMarkerClick?.call(event.value);
          case MarkerDragStartEvent():
            _aMapFlutter.onMarkerDragStart?.call(event.value, event.position);
          case MarkerDragEvent():
            _aMapFlutter.onMarkerDrag?.call(event.value, event.position);
          case MarkerDragEndEvent():
            _aMapFlutter.onMarkerDragEnd?.call(event.value, event.position);
          case UserLocationChangeEvent():
            _aMapFlutter.onUserLocationChange?.call(event.value);
          default:
            break;
        }
      },
    );
  }

  /// 移动地图视野
  Future<void> moveCamera(
    CameraPosition position, [
    Duration? duration,
    bool waitForMapCompletedBeforeMove = true,
  ]) async {
    if (_isDestroyed) return;
    if (waitForMapCompletedBeforeMove) {
      await waitForMapCompleted();
      if (_isDestroyed) return;
    }
    await AMapFlutterPlatformInterface.instance.moveCamera(
      position,
      duration?.inMilliseconds ?? 0,
      mapId: mapId,
    );
  }

  /// 移动地图视野到某个地图区域
  void moveCameraToRegion(Region region, [Duration? duration]) {
    AMapFlutterPlatformInterface.instance.moveCameraToRegion(
      region,
      duration?.inMilliseconds ?? 0,
      mapId: mapId,
    );
  }

  /// 移动地图视野到包含一组坐标点的某个地图区域
  void moveCameraToFitPosition(List<Position>? positions, EdgePadding padding,
      [Duration? duration]) {
    AMapFlutterPlatformInterface.instance.moveCameraToFitPosition(
      positions,
      padding,
      duration?.inMilliseconds ?? 0,
      mapId: mapId,
    );
  }

  /// 限制地图显示区域
  void setRestrictRegion(Region region) {
    AMapFlutterPlatformInterface.instance.setRestrictRegion(
      region,
      mapId: mapId,
    );
  }

  /// 取消地图显示区域限制
  void removeRestrictRegion() {
    AMapFlutterPlatformInterface.instance.removeRestrictRegion(mapId: mapId);
  }

  /// 添加标记
  void addMarker(Marker marker) {
    AMapFlutterPlatformInterface.instance.addMarker(
      marker,
      mapId: mapId,
    );
  }

  /// 移除标记点
  void removeMarker(String markerId) {
    AMapFlutterPlatformInterface.instance.removeMarker(
      markerId,
      mapId: mapId,
    );
  }

  /// 沿一组轨迹点平滑移动点标记。
  ///
  /// Android 使用高德官方 `SmoothMoveMarker`；iOS 使用原生计时插值驱动路径移动。
  Future<void> startSmoothMoveMarker({
    required Marker marker,
    required List<Position> points,
    required Duration duration,
  }) async {
    if (_isDestroyed) return;
    if (points.length < 2) {
      throw ArgumentError.value(points, 'points', '至少需要 2 个轨迹点');
    }
    await AMapFlutterPlatformInterface.instance.startSmoothMoveMarker(
      marker,
      points,
      duration.inMilliseconds,
      mapId: mapId,
    );
  }

  /// 停止并移除指定的平滑移动点标记。
  Future<void> stopSmoothMoveMarker(String markerId) async {
    if (_isDestroyed) return;
    await AMapFlutterPlatformInterface.instance.stopSmoothMoveMarker(
      markerId,
      mapId: mapId,
    );
  }

  /// 暂停指定的平滑移动点标记。
  Future<void> pauseSmoothMoveMarker(String markerId) async {
    if (_isDestroyed) return;
    await AMapFlutterPlatformInterface.instance.pauseSmoothMoveMarker(
      markerId,
      mapId: mapId,
    );
  }

  /// 继续指定的平滑移动点标记。
  Future<void> resumeSmoothMoveMarker(String markerId) async {
    if (_isDestroyed) return;
    await AMapFlutterPlatformInterface.instance.resumeSmoothMoveMarker(
      markerId,
      mapId: mapId,
    );
  }

  /// 添加折线
  Future<void> addPolyline(Polyline polyline) async {
    if (_isDestroyed) return;
    await AMapFlutterPlatformInterface.instance.addPolyline(
      polyline,
      mapId: mapId,
    );
  }

  /// 移除折线
  Future<void> removePolyline(String polylineId) async {
    if (_isDestroyed) return;
    await AMapFlutterPlatformInterface.instance.removePolyline(
      polylineId,
      mapId: mapId,
    );
  }

  /// 添加导航箭头
  Future<void> addNavigateArrow(NavigateArrow arrow) async {
    if (_isDestroyed) return;
    await AMapFlutterPlatformInterface.instance.addNavigateArrow(
      arrow,
      mapId: mapId,
    );
  }

  /// 移除导航箭头
  Future<void> removeNavigateArrow(String arrowId) async {
    if (_isDestroyed) return;
    await AMapFlutterPlatformInterface.instance.removeNavigateArrow(
      arrowId,
      mapId: mapId,
    );
  }

  /// 添加弧线
  Future<void> addArc(Arc arc) async {
    if (_isDestroyed) return;
    await AMapFlutterPlatformInterface.instance.addArc(
      arc,
      mapId: mapId,
    );
  }

  /// 移除弧线
  Future<void> removeArc(String arcId) async {
    if (_isDestroyed) return;
    await AMapFlutterPlatformInterface.instance.removeArc(
      arcId,
      mapId: mapId,
    );
  }

  /// 添加多边形
  Future<void> addPolygon(Polygon polygon) async {
    if (_isDestroyed) return;
    await AMapFlutterPlatformInterface.instance.addPolygon(
      polygon,
      mapId: mapId,
    );
  }

  /// 移除多边形
  Future<void> removePolygon(String polygonId) async {
    if (_isDestroyed) return;
    await AMapFlutterPlatformInterface.instance.removePolygon(
      polygonId,
      mapId: mapId,
    );
  }

  /// 播放点标记动画（Android：高德 SDK Marker 动画；iOS：标注视图 UIView 动画）。
  ///
  /// [durationMs] 为 Android 侧单次 `Animation.setDuration` 的基准；呼吸/透明度在 Android 上会因 `repeatCount`
  /// 变长，iOS 已按相同总墙钟时间对齐。
  Future<void> animateMarker(
    String markerId, {
    required MarkerAnimationKind kind,
    int durationMs = 800,
  }) async {
    if (_isDestroyed) return;
    await AMapFlutterPlatformInterface.instance.animateMarker(
      markerId,
      kind,
      durationMs,
      mapId: mapId,
    );
  }

  /// 取消指定点标记当前动画。
  Future<void> cancelMarkerAnimation(String markerId) async {
    if (_isDestroyed) return;
    await AMapFlutterPlatformInterface.instance.cancelMarkerAnimation(
      markerId,
      mapId: mapId,
    );
  }

  /// 显示指定点标记的 InfoWindow / callout（需 [Marker.title] 或 [Marker.snippet] 有内容）。
  Future<void> showInfoWindow(String markerId) async {
    if (_isDestroyed) return;
    await AMapFlutterPlatformInterface.instance.showInfoWindow(
      markerId,
      mapId: mapId,
    );
  }

  /// 隐藏当前 InfoWindow / callout。
  Future<void> hideInfoWindow() async {
    if (_isDestroyed) return;
    await AMapFlutterPlatformInterface.instance.hideInfoWindow(mapId: mapId);
  }

  /// 获取当前定位
  Future<Location> getUserLocation() {
    return AMapFlutterPlatformInterface.instance.getUserLocation(mapId: mapId);
  }

  /// 等待首次定位结果（推荐：避免在尚未产生定位回调前调用 [getUserLocation] 返回空）
  Future<Location> waitForUserLocation({
    Duration timeout = const Duration(seconds: 10),
  }) {
    return AMapFlutterPlatformInterface.instance
        .onUserLocationChange(mapId: mapId)
        .map((e) => e.value)
        .first
        .timeout(timeout);
  }

  /// 获取当前比例尺（每像素代表多少米）
  ///
  /// 返回当前缩放级别下，地图上每个像素代表的实际距离（单位：米）
  Future<double> getScalePerPixel() {
    return AMapFlutterPlatformInterface.instance.getScalePerPixel(mapId: mapId);
  }

  /// 将指定坐标系的坐标转换为高德地图坐标。
  Future<Position> convertCoordinate(
    Position position, {
    CoordinateConvertType from = CoordinateConvertType.gps,
  }) {
    return AMapFlutterPlatformInterface.instance.convertCoordinate(
      position,
      from,
      mapId: mapId,
    );
  }

  /// 将经纬度转换为当前地图视图内的屏幕像素点。
  Future<Size> toScreenLocation(Position position) {
    return AMapFlutterPlatformInterface.instance.toScreenLocation(
      position,
      mapId: mapId,
    );
  }

  /// 将当前地图视图内的屏幕像素点转换为经纬度。
  Future<Position> fromScreenLocation(Size point) {
    return AMapFlutterPlatformInterface.instance.fromScreenLocation(
      point,
      mapId: mapId,
    );
  }

  /// 计算两点之间的球面距离，单位：米。
  Future<double> calculateLineDistance(Position start, Position end) {
    return AMapFlutterPlatformInterface.instance.calculateLineDistance(
      start,
      end,
      mapId: mapId,
    );
  }

  /// 判断点是否在多边形内。
  Future<bool> containsCoordinate(Position point, List<Position> polygon) {
    return AMapFlutterPlatformInterface.instance.containsCoordinate(
      point,
      polygon,
      mapId: mapId,
    );
  }

  /// 截取当前地图可视区域为 PNG 图片字节（对齐高德 Android [AMap.getMapScreenShot] /
  /// iOS [MAMapView takeSnapshotInRect:]）。
  ///
  /// 建议在地图加载完成后再调用，以免底图未就绪时得到空白图。
  Future<Uint8List> takeMapSnapshot({
    bool waitForMapCompletedBeforeSnapshot = true,
  }) async {
    if (_isDestroyed) {
      throw StateError("AMapController destroyed");
    }
    if (waitForMapCompletedBeforeSnapshot) {
      await waitForMapCompleted();
      if (_isDestroyed) {
        throw StateError("AMapController destroyed");
      }
    }
    return AMapFlutterPlatformInterface.instance.takeMapSnapshot(mapId: mapId);
  }

  /// 停止当前相机动画（Android 对应 [AMap.stopAnimation]；iOS 无 SDK 等价能力，为兼容调用空实现）
  Future<void> stopCameraAnimation() {
    return AMapFlutterPlatformInterface.instance
        .stopCameraAnimation(mapId: mapId);
  }

  /// 获取当前缩放级别
  ///
  /// 返回当前地图的缩放级别，如果尚未获取到则返回 null
  double? get currentZoom => _currentCamera?.zoom;

  /// 获取当前地图视野
  ///
  /// 返回当前地图的视野信息，如果尚未获取到则返回 null
  CameraPosition? get currentCamera => _currentCamera;

  /// 地图放大一级
  ///
  /// [duration] 动画持续时间，默认无动画
  /// [zoomDelta] 缩放增量，默认为 1
  Future<void> zoomIn({
    Duration? duration,
    double zoomDelta = 1,
  }) async {
    if (_isDestroyed) return;
    final currentZoom = _currentCamera?.zoom;
    if (currentZoom == null) {
      // 如果还没有获取到当前缩放级别，等待地图完成
      await waitForMapCompleted();
      if (_currentCamera?.zoom == null) return;
    }
    final newZoom = (_currentCamera?.zoom ?? 16) + zoomDelta;
    // 缩放级别上限通常为 20
    final clampedZoom = newZoom.clamp(2.0, 20.0);
    await moveCamera(
      CameraPosition.zoom(clampedZoom),
      duration,
      false, // 不再等待 mapCompleted，因为我们已经等过了
    );
  }

  /// 地图缩小一级
  ///
  /// [duration] 动画持续时间，默认无动画
  /// [zoomDelta] 缩放减量，默认为 1
  Future<void> zoomOut({
    Duration? duration,
    double zoomDelta = 1,
  }) async {
    if (_isDestroyed) return;
    final currentZoom = _currentCamera?.zoom;
    if (currentZoom == null) {
      // 如果还没有获取到当前缩放级别，等待地图完成
      await waitForMapCompleted();
      if (_currentCamera?.zoom == null) return;
    }
    final newZoom = (_currentCamera?.zoom ?? 16) - zoomDelta;
    // 缩放级别下限通常为 2
    final clampedZoom = newZoom.clamp(2.0, 20.0);
    await moveCamera(
      CameraPosition.zoom(clampedZoom),
      duration,
      false, // 不再等待 mapCompleted，因为我们已经等过了
    );
  }

  /// 设置缩放级别
  ///
  /// [zoom] 目标缩放级别（范围通常为 2-20）
  /// [duration] 动画持续时间，默认无动画
  Future<void> setZoom(
    double zoom, {
    Duration? duration,
  }) async {
    if (_isDestroyed) return;
    final clampedZoom = zoom.clamp(2.0, 20.0);
    await moveCamera(
      CameraPosition.zoom(clampedZoom),
      duration,
    );
  }

  /// 开始地图渲染
  Future<void> start() {
    return AMapFlutterPlatformInterface.instance.start(mapId: mapId);
  }

  /// 暂停地图渲染
  Future<void> pause() {
    return AMapFlutterPlatformInterface.instance.pause(mapId: mapId);
  }

  /// 恢复地图渲染
  Future<void> resume() {
    return AMapFlutterPlatformInterface.instance.resume(mapId: mapId);
  }

  /// 销毁地图
  Future<void> destroy() async {
    if (_isDestroyed) return;
    _isDestroyed = true;
    // 避免仍在等待 mapCompleted 的 Future 永久挂起
    if (!_mapCompletedCompleter.isCompleted) {
      _mapCompletedCompleter.complete();
    }
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    await AMapFlutterPlatformInterface.instance.destroy(mapId: mapId);
  }
}
