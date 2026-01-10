part of '../amap_flutter.dart';

/// Controller for a single AMap instance running on the host platform,
/// which passed in [AMapFlutter.onMapCreated] callback.
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
  final AMapFlutter _aMapFlutter;

  final Completer<void> _mapCompletedCompleter = Completer<void>();
  bool _isDestroyed = false;

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
    if (_aMapFlutter.onMapInitComplete != null) {
      AMapFlutterPlatformInterface.instance
          .onMapInitComplete(mapId: mapId)
          .listen(
            (MapInitCompleteEvent e) => _aMapFlutter.onMapInitComplete!(),
          );
    }
    // 无论业务侧是否传入 onMapCompleted 回调，都需要监听该事件：
    // moveCamera 等方法会依赖它来确保地图完全加载后再执行。
    AMapFlutterPlatformInterface.instance.onMapCompleted(mapId: mapId).listen(
      (MapCompleteEvent e) {
        if (!_mapCompletedCompleter.isCompleted) {
          _mapCompletedCompleter.complete();
        }
        _aMapFlutter.onMapCompleted?.call();
      },
    );
    if (_aMapFlutter.onMapPress != null) {
      AMapFlutterPlatformInterface.instance
          .onMapPress(mapId: mapId)
          .listen((MapPressEvent e) => _aMapFlutter.onMapPress!(e.position));
    }
    if (_aMapFlutter.onMapDoublePress != null) {
      AMapFlutterPlatformInterface.instance
          .onMapDoublePress(mapId: mapId)
          .listen((MapDoublePressEvent e) =>
              _aMapFlutter.onMapDoublePress!(e.position));
    }
    if (_aMapFlutter.onMapRightPress != null) {
      AMapFlutterPlatformInterface.instance
          .onMapRightPress(mapId: mapId)
          .listen((MapRightPressEvent e) =>
              _aMapFlutter.onMapRightPress!(e.position));
    }
    if (_aMapFlutter.onMapLongPress != null) {
      AMapFlutterPlatformInterface.instance.onMapLongPress(mapId: mapId).listen(
          (MapLongPressEvent e) => _aMapFlutter.onMapLongPress!(e.position));
    }
    if (_aMapFlutter.onCameraChange != null) {
      AMapFlutterPlatformInterface.instance.onCameraChange(mapId: mapId).listen(
          (CameraChangeEvent e) => _aMapFlutter.onCameraChange!(e.value));
    }
    if (_aMapFlutter.onCameraChangeStart != null) {
      AMapFlutterPlatformInterface.instance
          .onCameraChangeStart(mapId: mapId)
          .listen((CameraChangeStartEvent e) =>
              _aMapFlutter.onCameraChangeStart!(e.value));
    }
    if (_aMapFlutter.onCameraChangeFinish != null) {
      AMapFlutterPlatformInterface.instance
          .onCameraChangeFinish(mapId: mapId)
          .listen((CameraChangeFinishEvent e) =>
              _aMapFlutter.onCameraChangeFinish!(e.value));
    }
    if (_aMapFlutter.onMapMoveStart != null) {
      AMapFlutterPlatformInterface.instance.onMapMoveStart(mapId: mapId).listen(
          (MapMoveStartEvent e) => _aMapFlutter.onMapMoveStart!(e.position));
    }
    if (_aMapFlutter.onMapMove != null) {
      AMapFlutterPlatformInterface.instance
          .onMapMove(mapId: mapId)
          .listen((MapMoveEvent e) => _aMapFlutter.onMapMove!(e.position));
    }
    if (_aMapFlutter.onMapMoveEnd != null) {
      AMapFlutterPlatformInterface.instance.onMapMoveEnd(mapId: mapId).listen(
          (MapMoveEndEvent e) => _aMapFlutter.onMapMoveEnd!(e.position));
    }
    if (_aMapFlutter.onMapResized != null) {
      AMapFlutterPlatformInterface.instance.onMapResized(mapId: mapId).listen(
          (MapResizedEvent event) => _aMapFlutter.onMapResized!(event.value));
    }
    if (_aMapFlutter.onZoomChange != null) {
      AMapFlutterPlatformInterface.instance
          .onZoomChange(mapId: mapId)
          .listen((ZoomChangeEvent e) => _aMapFlutter.onZoomChange!(e.value));
    }
    if (_aMapFlutter.onZoomChangeStart != null) {
      AMapFlutterPlatformInterface.instance
          .onZoomChangeStart(mapId: mapId)
          .listen((ZoomChangeStartEvent e) =>
              _aMapFlutter.onZoomChangeStart!(e.value));
    }
    if (_aMapFlutter.onZoomChangeEnd != null) {
      AMapFlutterPlatformInterface.instance
          .onZoomChangeEnd(mapId: mapId)
          .listen(
            (ZoomChangeEndEvent e) => _aMapFlutter.onZoomChangeEnd!(e.value),
          );
    }
    if (_aMapFlutter.onRotateChange != null) {
      AMapFlutterPlatformInterface.instance.onRotateChange(mapId: mapId).listen(
          (RotateChangeEvent e) => _aMapFlutter.onRotateChange!(e.value));
    }
    if (_aMapFlutter.onRotateChangeStart != null) {
      AMapFlutterPlatformInterface.instance
          .onRotateChangeStart(mapId: mapId)
          .listen((RotateChangeStartEvent e) =>
              _aMapFlutter.onRotateChangeStart!(e.value));
    }
    if (_aMapFlutter.onRotateChangeEnd != null) {
      AMapFlutterPlatformInterface.instance
          .onRotateChangeEnd(mapId: mapId)
          .listen((RotateChangeEndEvent e) =>
              _aMapFlutter.onRotateChangeEnd!(e.value));
    }
    if (_aMapFlutter.onMouseMove != null) {
      AMapFlutterPlatformInterface.instance
          .onMouseMove(mapId: mapId)
          .listen((MouseMoveEvent e) => _aMapFlutter.onMouseMove!(e.position));
    }
    if (_aMapFlutter.onMouseWheel != null) {
      AMapFlutterPlatformInterface.instance
          .onMouseWheel(mapId: mapId)
          .listen((MouseWheelEvent e) => _aMapFlutter.onMouseWheel!(e.value));
    }
    if (_aMapFlutter.onMouseOver != null) {
      AMapFlutterPlatformInterface.instance
          .onMouseOver(mapId: mapId)
          .listen((MouseOverEvent e) => _aMapFlutter.onMouseOver!(e.position));
    }
    if (_aMapFlutter.onMouseOut != null) {
      AMapFlutterPlatformInterface.instance
          .onMouseOut(mapId: mapId)
          .listen((MouseOutEvent e) => _aMapFlutter.onMouseOut!(e.position));
    }
    if (_aMapFlutter.onMouseUp != null) {
      AMapFlutterPlatformInterface.instance
          .onMouseUp(mapId: mapId)
          .listen((MouseUpEvent e) => _aMapFlutter.onMouseUp!(e.position));
    }
    if (_aMapFlutter.onMouseDown != null) {
      AMapFlutterPlatformInterface.instance
          .onMouseDown(mapId: mapId)
          .listen((MouseDownEvent e) => _aMapFlutter.onMouseDown!(e.position));
    }
    if (_aMapFlutter.onDragStart != null) {
      AMapFlutterPlatformInterface.instance
          .onDragStart(mapId: mapId)
          .listen((DragStartEvent e) => _aMapFlutter.onDragStart!(e.position));
    }
    if (_aMapFlutter.onDragging != null) {
      AMapFlutterPlatformInterface.instance
          .onDragging(mapId: mapId)
          .listen((DraggingEvent e) => _aMapFlutter.onDragging!(e.position));
    }
    if (_aMapFlutter.onDragEnd != null) {
      AMapFlutterPlatformInterface.instance
          .onDragEnd(mapId: mapId)
          .listen((DragEndEvent e) => _aMapFlutter.onDragEnd!(e.position));
    }
    if (_aMapFlutter.onTouchStart != null) {
      AMapFlutterPlatformInterface.instance.onTouchStart(mapId: mapId).listen(
          (TouchStartEvent e) => _aMapFlutter.onTouchStart!(e.position));
    }
    if (_aMapFlutter.onTouching != null) {
      AMapFlutterPlatformInterface.instance
          .onTouching(mapId: mapId)
          .listen((TouchingEvent e) => _aMapFlutter.onTouching!(e.position));
    }
    if (_aMapFlutter.onTouchEnd != null) {
      AMapFlutterPlatformInterface.instance
          .onTouchEnd(mapId: mapId)
          .listen((TouchEndEvent e) => _aMapFlutter.onTouchEnd!(e.position));
    }
    if (_aMapFlutter.onPoiClick != null) {
      AMapFlutterPlatformInterface.instance
          .onPoiClick(mapId: mapId)
          .listen((PoiClickEvent e) => _aMapFlutter.onPoiClick!(e.value));
    }
    if (_aMapFlutter.onMarkerClick != null) {
      AMapFlutterPlatformInterface.instance
          .onMarkerClick(mapId: mapId)
          .listen((MarkerClickEvent e) => _aMapFlutter.onMarkerClick!(e.value));
    }
    if (_aMapFlutter.onMarkerDragStart != null) {
      AMapFlutterPlatformInterface.instance
          .onMarkerDragStart(mapId: mapId)
          .listen((MarkerDragStartEvent e) =>
              _aMapFlutter.onMarkerDragStart!(e.value, e.position));
    }
    if (_aMapFlutter.onMarkerDrag != null) {
      AMapFlutterPlatformInterface.instance.onMarkerDrag(mapId: mapId).listen(
          (MarkerDragEvent e) =>
              _aMapFlutter.onMarkerDrag!(e.value, e.position));
    }
    if (_aMapFlutter.onMarkerDragEnd != null) {
      AMapFlutterPlatformInterface.instance
          .onMarkerDragEnd(mapId: mapId)
          .listen((MarkerDragEndEvent e) =>
              _aMapFlutter.onMarkerDragEnd!(e.value, e.position));
    }
    if (_aMapFlutter.onUserLocationChange != null) {
      AMapFlutterPlatformInterface.instance
          .onUserLocationChange(mapId: mapId)
          .listen((UserLocationChangeEvent e) =>
              _aMapFlutter.onUserLocationChange!(e.value));
    }
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
    await AMapFlutterPlatformInterface.instance.destroy(mapId: mapId);
  }
}
