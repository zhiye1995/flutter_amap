part of '../../flutter_amap.dart';

abstract class AMapFlutterPlatformInterface extends PlatformInterface {
  /// Constructs a AMapFlutterPlatform.
  AMapFlutterPlatformInterface() : super(token: _token);

  static final Object _token = Object();

  static AMapFlutterPlatformInterface _instance = AMapFlutterMethodChannel();

  /// The default instance of [AMapFlutterPlatformInterface] to use.
  ///
  /// Defaults to [AMapFlutterMethodChannel].
  static AMapFlutterPlatformInterface get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AMapFlutterPlatformInterface] when
  /// they register themselves.
  static set instance(AMapFlutterPlatformInterface instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> init(int mapId, AMapWidget? aMapFlutter) {
    throw UnimplementedError('init() has not been implemented.');
  }

  // The controller we need to broadcast the different events coming from handleMethodCall.
  final StreamController<MapEvent<Object?>> mapEventStreamController =
      StreamController<MapEvent<Object?>>.broadcast();

  // Returns a filtered view of the events in the _controller, by mapId.
  Stream<MapEvent<Object?>> _events(int mapId) => mapEventStreamController
      .stream
      .where((MapEvent<Object?> event) => event.mapId == mapId);

  Stream<MapInitCompleteEvent> onMapInitComplete({required int mapId}) {
    return _events(mapId).whereType<MapInitCompleteEvent>();
  }

  Stream<MapCompleteEvent> onMapCompleted({required int mapId}) {
    return _events(mapId).whereType<MapCompleteEvent>();
  }

  Stream<MapPressEvent> onMapPress({required int mapId}) {
    return _events(mapId).whereType<MapPressEvent>();
  }

  Stream<MapLongPressEvent> onMapLongPress({required int mapId}) {
    return _events(mapId).whereType<MapLongPressEvent>();
  }

  Stream<CameraChangeEvent> onCameraChange({required int mapId}) {
    return _events(mapId).whereType<CameraChangeEvent>();
  }

  Stream<CameraChangeStartEvent> onCameraChangeStart({required int mapId}) {
    return _events(mapId).whereType<CameraChangeStartEvent>();
  }

  Stream<CameraChangeFinishEvent> onCameraChangeFinish({required int mapId}) {
    return _events(mapId).whereType<CameraChangeFinishEvent>();
  }

  Stream<MapMoveStartEvent> onMapMoveStart({required int mapId}) {
    return _events(mapId).whereType<MapMoveStartEvent>();
  }

  Stream<MapMoveEvent> onMapMove({required int mapId}) {
    return _events(mapId).whereType<MapMoveEvent>();
  }

  Stream<MapMoveEndEvent> onMapMoveEnd({required int mapId}) {
    return _events(mapId).whereType<MapMoveEndEvent>();
  }

  Stream<MapResizedEvent> onMapResized({required int mapId}) {
    return _events(mapId).whereType<MapResizedEvent>();
  }

  Stream<ZoomChangeEvent> onZoomChange({required int mapId}) {
    return _events(mapId).whereType<ZoomChangeEvent>();
  }

  Stream<ZoomChangeStartEvent> onZoomChangeStart({required int mapId}) {
    return _events(mapId).whereType<ZoomChangeStartEvent>();
  }

  Stream<ZoomChangeEndEvent> onZoomChangeEnd({required int mapId}) {
    return _events(mapId).whereType<ZoomChangeEndEvent>();
  }

  Stream<RotateChangeEvent> onRotateChange({required int mapId}) {
    return _events(mapId).whereType<RotateChangeEvent>();
  }

  Stream<RotateChangeStartEvent> onRotateChangeStart({required int mapId}) {
    return _events(mapId).whereType<RotateChangeStartEvent>();
  }

  Stream<RotateChangeEndEvent> onRotateChangeEnd({required int mapId}) {
    return _events(mapId).whereType<RotateChangeEndEvent>();
  }

  Stream<PoiClickEvent> onPoiClick({required int mapId}) {
    return _events(mapId).whereType<PoiClickEvent>();
  }

  Stream<MarkerClickEvent> onMarkerClick({required int mapId}) {
    return _events(mapId).whereType<MarkerClickEvent>();
  }

  Stream<MarkerDragStartEvent> onMarkerDragStart({required int mapId}) {
    return _events(mapId).whereType<MarkerDragStartEvent>();
  }

  Stream<MarkerDragEvent> onMarkerDrag({required int mapId}) {
    return _events(mapId).whereType<MarkerDragEvent>();
  }

  Stream<MarkerDragEndEvent> onMarkerDragEnd({required int mapId}) {
    return _events(mapId).whereType<MarkerDragEndEvent>();
  }

  Stream<SmoothMoveMarkerCompleteEvent> onSmoothMoveMarkerCompleted({
    required int mapId,
  }) {
    return _events(mapId).whereType<SmoothMoveMarkerCompleteEvent>();
  }

  Stream<SmoothMoveMarkerProgressEvent> onSmoothMoveMarkerProgress({
    required int mapId,
  }) {
    return _events(mapId).whereType<SmoothMoveMarkerProgressEvent>();
  }

  Stream<UserLocationChangeEvent> onUserLocationChange({required int mapId}) {
    return _events(mapId).whereType<UserLocationChangeEvent>();
  }

  /// 设置SDK Api key，显示地图前必须调用
  Future<void> setApiKey(ApiKey apiKey) {
    throw UnimplementedError('setApiKey() has not been implemented.');
  }

  /// 同意隐私协议，显示地图前必须调用
  Future<void> agreePrivacy(bool agree) {
    throw UnimplementedError('agreePrivacy() has not been implemented.');
  }

  /// 设置地图属性
  Future<void> updateMapConfig(MapUpdateConfig config, {required int mapId}) {
    throw UnimplementedError('updateMapConfig() has not been implemented.');
  }

  /// 移动地图视野
  Future<void> moveCamera(
    CameraPosition position,
    int duration, {
    required int mapId,
  }) {
    throw UnimplementedError('moveCamera() has not been implemented.');
  }

  /// 移动地图视野到某个地图区域
  Future<void> moveCameraToRegion(
    Region region,
    int duration, {
    required int mapId,
  }) {
    throw UnimplementedError('moveCamera() has not been implemented.');
  }

  /// 移动地图视野到包含一组坐标点的某个地图区域
  Future<void> moveCameraToFitPosition(
    List<Position>? positions,
    EdgePadding padding,
    int duration, {
    required int mapId,
  }) {
    throw UnimplementedError(
      'moveCameraToRegionWithPosition() has not been implemented.',
    );
  }

  /// 限制地图显示区域
  Future<void> setRestrictRegion(Region region, {required int mapId}) {
    throw UnimplementedError('setRestrictRegion() has not been implemented.');
  }

  /// 取消地图显示区域限制
  Future<void> removeRestrictRegion({required int mapId}) {
    throw UnimplementedError(
      'removeRestrictRegion() has not been implemented.',
    );
  }

  /// 添加标记点
  Future<void> addMarker(Marker marker, {required int mapId}) {
    throw UnimplementedError('addMarker() has not been implemented.');
  }

  /// 移除标记点
  Future<void> removeMarker(String id, {required int mapId}) {
    throw UnimplementedError('removeMarker() has not been implemented.');
  }

  /// 启动点标记平滑移动（Android `MovingPointOverlay`；iOS 原生计时插值）。
  Future<void> startSmoothMoveMarker(
    Marker marker,
    List<Position> points,
    int durationMs, {
    required int mapId,
  }) {
    throw UnimplementedError(
      'startSmoothMoveMarker() has not been implemented.',
    );
  }

  /// 停止并移除平滑移动点标记。
  Future<void> stopSmoothMoveMarker(String markerId, {required int mapId}) {
    throw UnimplementedError(
      'stopSmoothMoveMarker() has not been implemented.',
    );
  }

  /// 暂停平滑移动点标记。
  Future<void> pauseSmoothMoveMarker(String markerId, {required int mapId}) {
    throw UnimplementedError(
      'pauseSmoothMoveMarker() has not been implemented.',
    );
  }

  /// 继续平滑移动点标记。
  Future<void> resumeSmoothMoveMarker(String markerId, {required int mapId}) {
    throw UnimplementedError(
      'resumeSmoothMoveMarker() has not been implemented.',
    );
  }

  /// 添加折线
  Future<void> addPolyline(Polyline polyline, {required int mapId}) {
    throw UnimplementedError('addPolyline() has not been implemented.');
  }

  /// 移除折线
  Future<void> removePolyline(String id, {required int mapId}) {
    throw UnimplementedError('removePolyline() has not been implemented.');
  }

  /// 添加导航箭头
  Future<void> addNavigateArrow(NavigateArrow arrow, {required int mapId}) {
    throw UnimplementedError('addNavigateArrow() has not been implemented.');
  }

  /// 移除导航箭头
  Future<void> removeNavigateArrow(String id, {required int mapId}) {
    throw UnimplementedError('removeNavigateArrow() has not been implemented.');
  }

  /// 添加弧线
  Future<void> addArc(Arc arc, {required int mapId}) {
    throw UnimplementedError('addArc() has not been implemented.');
  }

  /// 移除弧线
  Future<void> removeArc(String id, {required int mapId}) {
    throw UnimplementedError('removeArc() has not been implemented.');
  }

  /// 添加多边形
  Future<void> addPolygon(Polygon polygon, {required int mapId}) {
    throw UnimplementedError('addPolygon() has not been implemented.');
  }

  /// 移除多边形
  Future<void> removePolygon(String id, {required int mapId}) {
    throw UnimplementedError('removePolygon() has not been implemented.');
  }

  /// 播放点标记动画（Android：高德 Animation；iOS：annotation 视图动画）
  Future<void> animateMarker(
    String markerId,
    MarkerAnimationKind kind,
    int durationMs, {
    required int mapId,
  }) {
    throw UnimplementedError('animateMarker() has not been implemented.');
  }

  /// 取消点标记动画
  Future<void> cancelMarkerAnimation(String markerId, {required int mapId}) {
    throw UnimplementedError(
      'cancelMarkerAnimation() has not been implemented.',
    );
  }

  /// 显示指定点标记的 InfoWindow（Android [Marker.showInfoWindow]；iOS 选中 annotation 以展示 callout）
  Future<void> showInfoWindow(String markerId, {required int mapId}) {
    throw UnimplementedError('showInfoWindow() has not been implemented.');
  }

  /// 隐藏当前 InfoWindow / callout（Android [AMap.hideInfoWindow]；iOS 取消选中）
  Future<void> hideInfoWindow({required int mapId}) {
    throw UnimplementedError('hideInfoWindow() has not been implemented.');
  }

  /// 获取当前定位信息
  Future<Location> getUserLocation({required int mapId}) async {
    throw UnimplementedError('getUserLocation() has not been implemented.');
  }

  /// 获取当前比例尺（每像素代表多少米）
  Future<double> getScalePerPixel({required int mapId}) {
    throw UnimplementedError('getScalePerPixel() has not been implemented.');
  }

  /// 将指定坐标系的坐标转换为高德地图坐标。
  Future<Position> convertCoordinate(
    Position position,
    CoordinateConvertType from, {
    required int mapId,
  }) {
    throw UnimplementedError('convertCoordinate() has not been implemented.');
  }

  /// 经纬度转屏幕像素点。
  Future<Size> toScreenLocation(Position position, {required int mapId}) {
    throw UnimplementedError('toScreenLocation() has not been implemented.');
  }

  /// 屏幕像素点转经纬度。
  Future<Position> fromScreenLocation(Size point, {required int mapId}) {
    throw UnimplementedError('fromScreenLocation() has not been implemented.');
  }

  /// 计算两点距离，单位：米。
  Future<double> calculateLineDistance(
    Position start,
    Position end, {
    required int mapId,
  }) {
    throw UnimplementedError(
      'calculateLineDistance() has not been implemented.',
    );
  }

  /// 判断点是否在多边形内。
  Future<bool> containsCoordinate(
    Position point,
    List<Position> polygon, {
    required int mapId,
  }) {
    throw UnimplementedError('containsCoordinate() has not been implemented.');
  }

  /// 截取当前地图可视区域为 PNG 字节（与高德 Android [AMap.getMapScreenShot]、
  /// iOS [MAMapView takeSnapshotInRect:] 对齐）。
  Future<Uint8List> takeMapSnapshot({required int mapId}) {
    throw UnimplementedError('takeMapSnapshot() has not been implemented.');
  }

  /// 停止当前相机动画（与高德 Android [AMap.stopAnimation] 对齐；iOS 无对等 API）
  Future<void> stopCameraAnimation({required int mapId}) {
    throw UnimplementedError('stopCameraAnimation() has not been implemented.');
  }

  /// 开始
  Future<void> start({required int mapId}) {
    throw UnimplementedError('start() has not been implemented.');
  }

  /// 暂停
  Future<void> pause({required int mapId}) {
    throw UnimplementedError('pause() has not been implemented.');
  }

  /// 恢复
  Future<void> resume({required int mapId}) {
    throw UnimplementedError('resume() has not been implemented.');
  }

  /// 销毁
  Future<void> destroy({required int mapId}) {
    throw UnimplementedError('destroy() has not been implemented.');
  }

  // ==================== 搜索相关接口 ====================

  /// 请求输入提示
  Future<List<InputTip>> requestInputTips({
    required String keywords,
    String? city,
    bool cityLimit = false,
    String? types,
    Position? location,
  }) {
    throw UnimplementedError('requestInputTips() has not been implemented.');
  }

  /// 周边 POI 搜索
  ///
  /// [center] 搜索中心点坐标
  /// [keywords] 搜索关键词（可选）
  /// [types] POI 类型限制（多个类型用"|"分隔，可选）
  /// [radius] 搜索半径，单位：米（可选，不传时使用平台默认值）
  /// [page] 页码，默认 1
  /// [pageSize] 每页数量，默认 20
  /// [city] 搜索城市（可选）
  Future<List<PoiItem>> searchPOIAround({
    required Position center,
    String? keywords,
    String? types,
    int? radius,
    int page = 1,
    int pageSize = 20,
    String? city,
  }) {
    throw UnimplementedError('searchPOIAround() has not been implemented.');
  }

  /// 结构化周边 POI 搜索
  Future<PoiSearchResult> searchPOIAroundWithQuery(PoiAroundSearchQuery query) {
    throw UnimplementedError(
      'searchPOIAroundWithQuery() has not been implemented.',
    );
  }

  /// POI 关键字搜索
  Future<PoiSearchResult> searchPOIKeywords(PoiKeywordSearchQuery query) {
    throw UnimplementedError('searchPOIKeywords() has not been implemented.');
  }

  /// 地理编码
  Future<List<GeocodeResult>> searchGeocode(GeocodeQuery query) {
    throw UnimplementedError('searchGeocode() has not been implemented.');
  }

  /// 逆地理编码
  Future<ReGeocodeResult> searchReGeocode(ReGeocodeQuery query) {
    throw UnimplementedError('searchReGeocode() has not been implemented.');
  }

  /// 驾车路线规划
  Future<RoutePlanResult> searchDriveRoute(DriveRouteQuery query) {
    throw UnimplementedError('searchDriveRoute() has not been implemented.');
  }

  /// 步行路线规划
  Future<RoutePlanResult> searchWalkRoute(WalkRouteQuery query) {
    throw UnimplementedError('searchWalkRoute() has not been implemented.');
  }

  /// 骑行路线规划
  Future<RoutePlanResult> searchRideRoute(RideRouteQuery query) {
    throw UnimplementedError('searchRideRoute() has not been implemented.');
  }

  // ==================== 天气相关接口 ====================

  /// 查询实时天气
  ///
  /// [city] 城市名称或区域编码（adcode），如"北京市"或"110000"
  Future<LocalWeatherLive> searchWeatherLive({required String city}) {
    throw UnimplementedError('searchWeatherLive() has not been implemented.');
  }

  /// 查询天气预报
  ///
  /// [city] 城市名称或区域编码（adcode），如"北京市"或"110000"
  Future<LocalWeatherForecast> searchWeatherForecast({required String city}) {
    throw UnimplementedError(
      'searchWeatherForecast() has not been implemented.',
    );
  }

  /// 根据当前定位查询实时天气
  ///
  /// 内部自动获取定位信息，提取adcode后查询天气
  Future<LocalWeatherLive> searchWeatherLiveByLocation() {
    throw UnimplementedError(
      'searchWeatherLiveByLocation() has not been implemented.',
    );
  }

  /// 根据当前定位查询天气预报
  ///
  /// 内部自动获取定位信息，提取adcode后查询天气预报
  Future<LocalWeatherForecast> searchWeatherForecastByLocation() {
    throw UnimplementedError(
      'searchWeatherForecastByLocation() has not been implemented.',
    );
  }
}
