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

/// 用户位置改变事件
class UserLocationChangeEvent extends MapEvent<Location> {
  UserLocationChangeEvent(super.mapId, super.location);
}

/// 点击用户定位点事件
class UserLocationClickEvent extends _PositionedMapEvent<void> {
  UserLocationClickEvent(int mapId, Position position)
      : super(mapId, position, null);
}

// ==================== 导航相关事件 ====================

/// 导航事件基类
abstract class NaviEvent<T> {
  NaviEvent(this.value);

  /// 事件携带的值
  final T value;
}

/// 导航初始化成功事件
class NaviInitSuccessEvent extends NaviEvent<void> {
  NaviInitSuccessEvent() : super(null);
}

/// 导航初始化失败事件
class NaviInitFailureEvent extends NaviEvent<String> {
  NaviInitFailureEvent(String message) : super(message);

  /// 失败信息
  String get message => value;
}

/// 导航引导信息更新事件
class NaviInfoUpdateEvent extends NaviEvent<NaviInfo> {
  NaviInfoUpdateEvent(NaviInfo naviInfo) : super(naviInfo);

  /// 导航引导信息
  NaviInfo get naviInfo => value;
}

/// 导航定位变化事件
class NaviLocationChangeEvent extends NaviEvent<NaviLocation> {
  NaviLocationChangeEvent(NaviLocation location) : super(location);

  /// 导航定位信息
  NaviLocation get location => value;
}

/// 导航语音播报事件
class NaviTextEvent extends NaviEvent<String> {
  NaviTextEvent(String text) : super(text);

  /// 语音播报文本
  String get text => value;
}

/// 到达目的地事件
class NaviArriveDestinationEvent extends NaviEvent<void> {
  NaviArriveDestinationEvent() : super(null);
}

/// 导航开始事件
class NaviStartEvent extends NaviEvent<int> {
  NaviStartEvent(int type) : super(type);

  /// 导航类型
  int get type => value;
}

/// 路线计算成功事件
class NaviRouteCalculateSuccessEvent extends NaviEvent<List<int>> {
  NaviRouteCalculateSuccessEvent(List<int> routeIds) : super(routeIds);

  /// 路线ID列表
  List<int> get routeIds => value;
}

/// 路线计算失败事件
class NaviRouteCalculateFailureEvent extends NaviEvent<int> {
  NaviRouteCalculateFailureEvent(int errorCode) : super(errorCode);

  /// 错误码
  int get errorCode => value;
}

/// 偏航重新计算路线事件
class NaviReCalculateRouteForYawEvent extends NaviEvent<void> {
  NaviReCalculateRouteForYawEvent() : super(null);
}

/// 拥堵重新计算路线事件
class NaviReCalculateRouteForTrafficJamEvent extends NaviEvent<void> {
  NaviReCalculateRouteForTrafficJamEvent() : super(null);
}

/// 到达途经点事件
class NaviArrivedWayPointEvent extends NaviEvent<int> {
  NaviArrivedWayPointEvent(int wayPointIndex) : super(wayPointIndex);

  /// 途经点索引
  int get wayPointIndex => value;
}

/// GPS信号状态变化事件
class NaviGpsSignalEvent extends NaviEvent<bool> {
  NaviGpsSignalEvent(bool isWeak) : super(isWeak);

  /// 是否信号弱
  bool get isWeak => value;
}

/// 交通状态更新事件
class NaviTrafficStatusUpdateEvent extends NaviEvent<void> {
  NaviTrafficStatusUpdateEvent() : super(null);
}

/// 模拟导航结束事件
class NaviEndEmulatorEvent extends NaviEvent<void> {
  NaviEndEmulatorEvent() : super(null);
}

/// 退出导航页面事件
class NaviExitEvent extends NaviEvent<int> {
  NaviExitEvent(int exitCode) : super(exitCode);

  /// 退出码
  int get exitCode => value;
}

// ==================== 智能巡航事件 ====================

/// 巡航道路设施更新，对应 Android `onUpdateTrafficFacility`。
class CruiseTrafficFacilityEvent
    extends NaviEvent<List<CruiseTrafficFacilityItem>> {
  CruiseTrafficFacilityEvent(super.facilities);

  List<CruiseTrafficFacilityItem> get facilities => value;
}

/// 巡航电子眼更新，对应 Android `onUpdateAimlessModeElecCameraInfo`。
class CruiseElecCameraInfoEvent
    extends NaviEvent<List<CruiseTrafficFacilityItem>> {
  CruiseElecCameraInfoEvent(super.cameraInfos);

  List<CruiseTrafficFacilityItem> get cameraInfos => value;
}

/// 巡航道路设施 / 电子眼更新（兼容旧版合并事件）
class CruiseTrafficFacilitiesEvent
    extends NaviEvent<List<CruiseTrafficFacilityItem>> {
  CruiseTrafficFacilitiesEvent(super.facilities);

  List<CruiseTrafficFacilityItem> get facilities => value;
}

/// 巡航统计更新（连续距离、连续时间等）
class CruiseStatisticsEvent extends NaviEvent<CruiseStatisticsInfo> {
  CruiseStatisticsEvent(super.statistics);

  CruiseStatisticsInfo get statistics => value;
}

/// 巡航拥堵信息更新（主要为 Android）
class CruiseCongestionEvent extends NaviEvent<CruiseCongestionInfo> {
  CruiseCongestionEvent(super.congestion);

  CruiseCongestionInfo get congestion => value;
}
