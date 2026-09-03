part of '../../flutter_amap.dart';

/// Generic event used as a base class for all events that might be triggered from map.
abstract class MapEvent<T> {
  MapEvent(this.mapId, this.value);

  /// The ID of the Map this event is associated to.
  final int mapId;

  /// The value wrapped by this event
  final T value;
}

/// A `MapEvent` associated to a `latLng`.
class _PositionedMapEvent<T> extends MapEvent<T> {
  _PositionedMapEvent(int mapId, this.position, T value) : super(mapId, value);

  /// The latLng where this event happened.
  final Position position;
}

/// 地图初始化完成事件
class MapInitCompleteEvent extends MapEvent<void> {
  MapInitCompleteEvent(int mapId) : super(mapId, null);
}

/// 地图加载完成事件
class MapCompleteEvent extends MapEvent<void> {
  MapCompleteEvent(int mapId) : super(mapId, null);
}

/// 地图点击事件
class MapPressEvent extends _PositionedMapEvent<void> {
  MapPressEvent(int mapId, Position position) : super(mapId, position, null);
}

/// 地图长按事件
class MapLongPressEvent extends _PositionedMapEvent<void> {
  MapLongPressEvent(int mapId, Position position)
    : super(mapId, position, null);
}

/// 地图视野变化事件
class CameraChangeEvent extends MapEvent<CameraPosition> {
  CameraChangeEvent(super.mapId, super.cameraPosition);
}

/// 地图视野开始变化事件
class CameraChangeStartEvent extends MapEvent<CameraPosition> {
  CameraChangeStartEvent(super.mapId, super.cameraPosition);
}

/// 地图视野变化结束事件
class CameraChangeFinishEvent extends MapEvent<CameraPosition> {
  CameraChangeFinishEvent(super.mapId, super.cameraPosition);
}

/// 地图平移开始事件
class MapMoveStartEvent extends _PositionedMapEvent<void> {
  MapMoveStartEvent(int mapId, Position position)
    : super(mapId, position, null);
}

/// 地图平移事件
class MapMoveEvent extends _PositionedMapEvent<void> {
  MapMoveEvent(int mapId, Position position) : super(mapId, position, null);
}

/// 地图平移结束事件
class MapMoveEndEvent extends _PositionedMapEvent<void> {
  MapMoveEndEvent(int mapId, Position position) : super(mapId, position, null);
}

/// 地图容器尺寸改变事件
class MapResizedEvent extends MapEvent<Size> {
  MapResizedEvent(super.mapId, super.size);
}

/// 地图缩放级别改变事件
class ZoomChangeEvent extends MapEvent<double> {
  ZoomChangeEvent(super.mapId, super.zoom);
}

/// 地图缩放级别开始改变事件
class ZoomChangeStartEvent extends MapEvent<double> {
  ZoomChangeStartEvent(super.mapId, super.zoom);
}

/// 地图缩放级别结束改变事件
class ZoomChangeEndEvent extends MapEvent<double> {
  ZoomChangeEndEvent(super.mapId, super.zoom);
}

/// 地图旋转事件
class RotateChangeEvent extends MapEvent<double> {
  RotateChangeEvent(super.mapId, super.rotate);
}

/// 地图旋转开始事件
class RotateChangeStartEvent extends MapEvent<double> {
  RotateChangeStartEvent(super.mapId, super.rotate);
}

/// 地图旋转结束事件
class RotateChangeEndEvent extends MapEvent<double> {
  RotateChangeEndEvent(super.mapId, super.rotate);
}

/// 点击POI事件
class PoiClickEvent extends MapEvent<Poi> {
  PoiClickEvent(super.mapId, super.poi);
}

/// 点击标记点事件
class MarkerClickEvent extends MapEvent<String> {
  MarkerClickEvent(super.mapId, super.markerId);
}

/// 开始拖动标记点事件
class MarkerDragStartEvent extends _PositionedMapEvent<String> {
  MarkerDragStartEvent(super.mapId, super.latLng, super.markerId);
}

/// 拖动标记点事件
class MarkerDragEvent extends _PositionedMapEvent<String> {
  MarkerDragEvent(super.mapId, super.latLng, super.markerId);
}

/// 结束拖动标记点事件
class MarkerDragEndEvent extends _PositionedMapEvent<String> {
  MarkerDragEndEvent(super.mapId, super.latLng, super.markerId);
}

/// 平滑移动 Marker 完成事件
class SmoothMoveMarkerCompleteEvent extends _PositionedMapEvent<String> {
  SmoothMoveMarkerCompleteEvent(super.mapId, super.position, super.markerId);
}

/// 平滑移动 Marker 的播放进度事件。
class SmoothMoveMarkerProgressEvent extends _PositionedMapEvent<String> {
  SmoothMoveMarkerProgressEvent(
    super.mapId,
    super.position,
    super.markerId, {
    required this.progress,
    required this.remainingDistance,
  });

  /// 已完成比例，范围为 0 到 1。
  final double progress;

  /// 到轨迹终点的剩余距离，单位为米。
  final double remainingDistance;
}

/// 平滑移动 Marker 当前的播放状态。
enum SmoothMoveMarkerStatus { idle, moving, paused, completed }

/// 用户位置改变事件
class UserLocationChangeEvent extends MapEvent<Location> {
  UserLocationChangeEvent(super.mapId, super.location);
}

/// 点击用户定位点事件
class UserLocationClickEvent extends _PositionedMapEvent<void> {
  UserLocationClickEvent(int mapId, Position position)
    : super(mapId, position, null);
}
