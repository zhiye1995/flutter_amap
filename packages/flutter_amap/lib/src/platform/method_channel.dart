part of '../../flutter_amap.dart';

/// An implementation of [AMapFlutterPlatformInterface] that uses method channels.
class AMapFlutterMethodChannel extends AMapFlutterPlatformInterface {
  final MethodChannel _initializerChannel = const MethodChannel(
    "plugins.flutter.dev/amap_initializer",
  );

  final Map<int, MethodChannel> _channels = <int, MethodChannel>{};

  /// 搜索相关通道
  final MethodChannel _searchChannel = const MethodChannel(
    "plugins.flutter.dev/amap_search",
  );

  /// Accesses the MethodChannel associated to the passed mapId.
  MethodChannel _channel(int mapId) {
    final MethodChannel? channel = _channels[mapId];
    if (channel == null) {
      throw UnknownMapIDError(mapId);
    }
    return channel;
  }

  @override
  Future<void> init(int mapId, AMapWidget? aMapFlutter) async {
    MethodChannel? channel = _channels[mapId];
    if (channel == null) {
      channel = MethodChannel(
        "plugins.flutter.dev/amap_$mapId",
        const StandardMethodCodec(AMapApiCodec()),
      );
      channel.setMethodCallHandler(
        (MethodCall call) => _handleMethodCall(call, mapId),
      );
      _channels[mapId] = channel;
    }
  }

  Future<dynamic> _handleMethodCall(MethodCall call, int mapId) async {
    switch (call.method) {
      case "onMapInitCompleted":
        mapEventStreamController.add(MapInitCompleteEvent(mapId));
        break;

      case "onMapCompleted":
        mapEventStreamController.add(MapCompleteEvent(mapId));
        break;

      case "onMapPress":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(
          MapPressEvent(mapId, arguments["position"] as Position),
        );
        break;

      case "onMapLongPress":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(
          MapLongPressEvent(mapId, arguments["position"] as Position),
        );
        break;

      case "onCameraChange":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(
          CameraChangeEvent(mapId, arguments["camera"] as CameraPosition),
        );
        break;

      case "onCameraChangeStart":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(
          CameraChangeStartEvent(mapId, arguments["camera"] as CameraPosition),
        );
        break;

      case "onCameraChangeFinish":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(
          CameraChangeFinishEvent(mapId, arguments["camera"] as CameraPosition),
        );
        break;

      case "onMapMoveStart":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(
          MapMoveStartEvent(mapId, arguments["position"] as Position),
        );
        break;

      case "onMapMove":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(
          MapMoveEvent(mapId, arguments["position"] as Position),
        );
        break;

      case "onMapMoveEnd":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(
          MapMoveEndEvent(mapId, arguments["position"] as Position),
        );
        break;

      case "onMapResized":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(
          MapResizedEvent(mapId, arguments["size"] as Size),
        );
        break;

      case "onZoomChange":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(
          ZoomChangeEvent(mapId, arguments["zoom"] as double),
        );
        break;

      case "onZoomChangeStart":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(
          ZoomChangeStartEvent(mapId, arguments["zoom"] as double),
        );
        break;

      case "onZoomChangeEnd":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(
          ZoomChangeEndEvent(mapId, arguments["zoom"] as double),
        );
        break;

      case "onRotateChange":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(
          RotateChangeEvent(mapId, arguments["rotate"] as double),
        );
        break;

      case "onRotateChangeStart":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(
          RotateChangeStartEvent(mapId, arguments["rotate"] as double),
        );
        break;

      case "onRotateChangeEnd":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(
          RotateChangeEndEvent(mapId, arguments["rotate"] as double),
        );
        break;

      case "onPoiClick":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(
          PoiClickEvent(mapId, arguments["poi"] as Poi),
        );
        break;

      case "onMarkerClick":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(
          MarkerClickEvent(mapId, arguments["markerId"] as String),
        );
        break;
      case "onMarkerDragStart":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(
          MarkerDragStartEvent(
            mapId,
            arguments["position"] as Position,
            arguments["markerId"] as String,
          ),
        );
        break;
      case "onMarkerDrag":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(
          MarkerDragEvent(
            mapId,
            arguments["position"] as Position,
            arguments["markerId"] as String,
          ),
        );
        break;
      case "onMarkerDragEnd":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(
          MarkerDragEndEvent(
            mapId,
            arguments["position"] as Position,
            arguments["markerId"] as String,
          ),
        );
        break;
      case "onSmoothMoveMarkerCompleted":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(
          SmoothMoveMarkerCompleteEvent(
            mapId,
            arguments["position"] as Position,
            arguments["markerId"] as String,
          ),
        );
        break;
      case "onUserLocationChange":
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        mapEventStreamController.add(
          UserLocationChangeEvent(mapId, arguments["location"] as Location),
        );
        break;
      default:
        throw MissingPluginException();
    }
  }

  Map<String, Object?> _getArgumentDictionary(MethodCall call) {
    return (call.arguments as Map<Object?, Object?>).cast<String, Object?>();
  }

  /// 设置SDK Api key，显示地图前必须调用
  @override
  Future<void> setApiKey(ApiKey apiKey) {
    return _initializerChannel.invokeMethod("setApiKey", <String, dynamic>{
      "iosKey": apiKey.iosKey,
      "androidKey": apiKey.androidKey,
    });
  }

  /// 同意隐私协议，显示地图前必须调用
  @override
  Future<void> agreePrivacy(bool agree) {
    return _initializerChannel.invokeMethod("agreePrivacy", <String, dynamic>{
      "agree": agree,
    });
  }

  /// 设置地图属性
  @override
  Future<void> updateMapConfig(MapUpdateConfig config, {required int mapId}) {
    return _channel(
      mapId,
    ).invokeMethod("updateMapConfig", <String, dynamic>{"config": config});
  }

  /// 移动地图视野
  @override
  Future<void> moveCamera(
    CameraPosition position,
    int duration, {
    required int mapId,
  }) {
    return _channel(mapId).invokeMethod("moveCamera", <String, dynamic>{
      "position": position,
      "duration": duration,
    });
  }

  /// 移动地图视野到某个地图区域
  @override
  Future<void> moveCameraToRegion(
    Region region,
    int duration, {
    required int mapId,
  }) {
    return _channel(mapId).invokeMethod("moveCameraToRegion", <String, dynamic>{
      "region": region,
      "duration": duration,
    });
  }

  /// 移动地图视野到包含一组坐标点的某个地图区域
  @override
  Future<void> moveCameraToFitPosition(
    List<Position>? positions,
    EdgePadding padding,
    int duration, {
    required int mapId,
  }) {
    return _channel(mapId).invokeMethod(
      "moveCameraToRegionWithPosition",
      <String, dynamic>{
        "positions": positions,
        "padding": padding,
        "duration": duration,
      },
    );
  }

  /// 限制地图显示区域
  @override
  Future<void> setRestrictRegion(Region region, {required int mapId}) {
    return _channel(
      mapId,
    ).invokeMethod("setRestrictRegion", <String, dynamic>{"region": region});
  }

  /// 取消地图显示区域限制
  @override
  Future<void> removeRestrictRegion({required int mapId}) {
    return _channel(mapId).invokeMethod("removeRestrictRegion");
  }

  /// 添加标记点
  @override
  Future<void> addMarker(Marker marker, {required int mapId}) {
    return _channel(
      mapId,
    ).invokeMethod("addMarker", <String, dynamic>{"marker": marker});
  }

  /// 移除标记点
  @override
  Future<void> removeMarker(String id, {required int mapId}) {
    return _channel(
      mapId,
    ).invokeMethod("removeMarker", <String, dynamic>{"id": id});
  }

  /// 启动点标记平滑移动
  @override
  Future<void> startSmoothMoveMarker(
    Marker marker,
    List<Position> points,
    int durationMs, {
    required int mapId,
  }) {
    return _channel(mapId).invokeMethod(
      "startSmoothMoveMarker",
      <String, dynamic>{
        "marker": marker,
        "points": points,
        "durationMs": durationMs,
      },
    );
  }

  /// 停止并移除平滑移动点标记
  @override
  Future<void> stopSmoothMoveMarker(String markerId, {required int mapId}) {
    return _channel(mapId).invokeMethod(
      "stopSmoothMoveMarker",
      <String, dynamic>{"markerId": markerId},
    );
  }

  /// 暂停平滑移动点标记
  @override
  Future<void> pauseSmoothMoveMarker(String markerId, {required int mapId}) {
    return _channel(mapId).invokeMethod(
      "pauseSmoothMoveMarker",
      <String, dynamic>{"markerId": markerId},
    );
  }

  /// 继续平滑移动点标记
  @override
  Future<void> resumeSmoothMoveMarker(String markerId, {required int mapId}) {
    return _channel(mapId).invokeMethod(
      "resumeSmoothMoveMarker",
      <String, dynamic>{"markerId": markerId},
    );
  }

  /// 添加折线
  @override
  Future<void> addPolyline(Polyline polyline, {required int mapId}) {
    return _channel(
      mapId,
    ).invokeMethod("addPolyline", <String, dynamic>{"polyline": polyline});
  }

  /// 移除折线
  @override
  Future<void> removePolyline(String id, {required int mapId}) {
    return _channel(
      mapId,
    ).invokeMethod("removePolyline", <String, dynamic>{"id": id});
  }

  /// 添加导航箭头
  @override
  Future<void> addNavigateArrow(NavigateArrow arrow, {required int mapId}) {
    return _channel(
      mapId,
    ).invokeMethod("addNavigateArrow", <String, dynamic>{"arrow": arrow});
  }

  /// 移除导航箭头
  @override
  Future<void> removeNavigateArrow(String id, {required int mapId}) {
    return _channel(
      mapId,
    ).invokeMethod("removeNavigateArrow", <String, dynamic>{"id": id});
  }

  /// 添加弧线
  @override
  Future<void> addArc(Arc arc, {required int mapId}) {
    return _channel(
      mapId,
    ).invokeMethod("addArc", <String, dynamic>{"arc": arc});
  }

  /// 移除弧线
  @override
  Future<void> removeArc(String id, {required int mapId}) {
    return _channel(
      mapId,
    ).invokeMethod("removeArc", <String, dynamic>{"id": id});
  }

  /// 添加多边形
  @override
  Future<void> addPolygon(Polygon polygon, {required int mapId}) {
    return _channel(
      mapId,
    ).invokeMethod("addPolygon", <String, dynamic>{"polygon": polygon});
  }

  /// 移除多边形
  @override
  Future<void> removePolygon(String id, {required int mapId}) {
    return _channel(
      mapId,
    ).invokeMethod("removePolygon", <String, dynamic>{"id": id});
  }

  /// 点标记动画
  @override
  Future<void> animateMarker(
    String markerId,
    MarkerAnimationKind kind,
    int durationMs, {
    required int mapId,
  }) {
    return _channel(mapId).invokeMethod("animateMarker", <String, dynamic>{
      "markerId": markerId,
      "kind": kind.code,
      "durationMs": durationMs,
    });
  }

  /// 取消点标记动画
  @override
  Future<void> cancelMarkerAnimation(String markerId, {required int mapId}) {
    return _channel(mapId).invokeMethod(
      "cancelMarkerAnimation",
      <String, dynamic>{"markerId": markerId},
    );
  }

  @override
  Future<void> showInfoWindow(String markerId, {required int mapId}) {
    return _channel(
      mapId,
    ).invokeMethod("showInfoWindow", <String, dynamic>{"markerId": markerId});
  }

  @override
  Future<void> hideInfoWindow({required int mapId}) {
    return _channel(mapId).invokeMethod("hideInfoWindow");
  }

  /// 获取当前定位信息
  @override
  Future<Location> getUserLocation({required int mapId}) async {
    final result = await _channel(
      mapId,
    ).invokeMethod<Location>("getUserLocation");
    if (result == null) {
      throw StateError(
        "Failed to get user location. "
        "This usually means the native map SDK has not produced a location fix yet, "
        "or location permission was not granted, "
        "or user location display is disabled (showUserLocation/isMyLocationEnabled). "
        "Wait for onUserLocationChange callback/event, and ensure runtime location permission is granted.",
      );
    }
    return result;
  }

  /// 获取当前比例尺（每像素代表多少米）
  @override
  Future<double> getScalePerPixel({required int mapId}) async {
    final result = await _channel(
      mapId,
    ).invokeMethod<double>("getScalePerPixel");
    return result ?? 0.0;
  }

  @override
  Future<Position> convertCoordinate(
    Position position,
    CoordinateConvertType from, {
    required int mapId,
  }) async {
    final result = await _channel(mapId).invokeMethod<Position>(
      "convertCoordinate",
      <String, dynamic>{"position": position, "from": from.value},
    );
    if (result == null) {
      throw StateError("convertCoordinate: native result is null");
    }
    return result;
  }

  @override
  Future<Size> toScreenLocation(Position position, {required int mapId}) async {
    final result = await _channel(mapId).invokeMethod<Size>(
      "toScreenLocation",
      <String, dynamic>{"position": position},
    );
    if (result == null) {
      throw StateError("toScreenLocation: native result is null");
    }
    return result;
  }

  @override
  Future<Position> fromScreenLocation(Size point, {required int mapId}) async {
    final result = await _channel(mapId).invokeMethod<Position>(
      "fromScreenLocation",
      <String, dynamic>{"point": point},
    );
    if (result == null) {
      throw StateError("fromScreenLocation: native result is null");
    }
    return result;
  }

  @override
  Future<double> calculateLineDistance(
    Position start,
    Position end, {
    required int mapId,
  }) async {
    final result = await _channel(mapId).invokeMethod<double>(
      "calculateLineDistance",
      <String, dynamic>{"start": start, "end": end},
    );
    return result ?? 0.0;
  }

  @override
  Future<bool> containsCoordinate(
    Position point,
    List<Position> polygon, {
    required int mapId,
  }) async {
    final result = await _channel(mapId).invokeMethod<bool>(
      "containsCoordinate",
      <String, dynamic>{"point": point, "polygon": polygon},
    );
    return result ?? false;
  }

  /// 地图可视区域 PNG 截图
  @override
  Future<Uint8List> takeMapSnapshot({required int mapId}) async {
    final Object? result = await _channel(
      mapId,
    ).invokeMethod<Object>("takeMapSnapshot");
    if (result is Uint8List && result.isNotEmpty) {
      return result;
    }
    if (result is List<int>) {
      return Uint8List.fromList(result);
    }
    throw StateError("takeMapSnapshot: unexpected native result");
  }

  @override
  Future<void> stopCameraAnimation({required int mapId}) {
    return _channel(mapId).invokeMethod("stopCameraAnimation");
  }

  /// 开始
  @override
  Future<void> start({required int mapId}) {
    return _channel(mapId).invokeMethod("start");
  }

  /// 暂停
  @override
  Future<void> pause({required int mapId}) {
    return _channel(mapId).invokeMethod("pause");
  }

  /// 恢复
  @override
  Future<void> resume({required int mapId}) {
    return _channel(mapId).invokeMethod("resume");
  }

  /// 销毁
  @override
  Future<void> destroy({required int mapId}) async {
    final MethodChannel? channel = _channels.remove(mapId);
    if (channel == null) {
      // If already disposed (or never initialized), treat as no-op.
      return;
    }
    await channel.invokeMethod("destroy");
  }

  // ==================== 搜索相关方法实现 ====================

  /// 请求输入提示
  @override
  Future<List<InputTip>> requestInputTips({
    required String keywords,
    String? city,
    bool cityLimit = false,
    String? types,
    Position? location,
  }) async {
    final result = await _searchChannel
        .invokeMethod<List<dynamic>>('requestInputTips', <String, dynamic>{
          'keywords': keywords,
          'city': city,
          'cityLimit': cityLimit,
          'types': types,
          'latitude': location?.latitude,
          'longitude': location?.longitude,
        });

    if (result == null) {
      return [];
    }

    return result.map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      return InputTip.decodeFromMap(map);
    }).toList();
  }

  /// 周边 POI 搜索
  @override
  Future<List<PoiItem>> searchPOIAround({
    required Position center,
    String? keywords,
    String? types,
    int? radius,
    int page = 1,
    int pageSize = 20,
    String? city,
  }) async {
    final result = await _searchChannel
        .invokeMethod<List<dynamic>>('searchPOIAround', <String, dynamic>{
          'latitude': center.latitude,
          'longitude': center.longitude,
          'keywords': keywords ?? '',
          'types': types ?? '',
          if (radius != null) 'radius': radius,
          'page': page,
          'pageSize': pageSize,
          'city': city ?? '',
        });

    if (result == null) {
      return [];
    }

    return result.map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      return PoiItem.decodeFromMap(map);
    }).toList();
  }

  /// 结构化周边 POI 搜索
  @override
  Future<PoiSearchResult> searchPOIAroundWithQuery(
    PoiAroundSearchQuery query,
  ) async {
    final result = await _searchChannel.invokeMethod<Map<dynamic, dynamic>>(
      'searchPOIAroundWithQuery',
      <String, dynamic>{
        'latitude': query.center.latitude,
        'longitude': query.center.longitude,
        'keywords': query.keywords ?? '',
        'types': query.types ?? '',
        'radius': query.radius,
        'city': query.city ?? '',
        'page': query.page,
        'pageSize': query.pageSize,
        'extensions': query.extensions.value,
        'children': query.children,
        'sortByDistance': query.sortByDistance,
      },
    );

    if (result == null) {
      return PoiSearchResult(
        items: const <PoiItem>[],
        page: query.page,
        pageSize: query.pageSize,
      );
    }

    return PoiSearchResult.decodeFromMap(Map<String, dynamic>.from(result));
  }

  /// POI 关键字搜索
  @override
  Future<PoiSearchResult> searchPOIKeywords(PoiKeywordSearchQuery query) async {
    final result = await _searchChannel.invokeMethod<Map<dynamic, dynamic>>(
      'searchPOIKeywords',
      <String, dynamic>{
        'keywords': query.keywords,
        'types': query.types ?? '',
        'city': query.city ?? '',
        'cityLimit': query.cityLimit,
        'page': query.page,
        'pageSize': query.pageSize,
        'latitude': query.location?.latitude,
        'longitude': query.location?.longitude,
        'extensions': query.extensions.value,
        'children': query.children,
        'sortByDistance': query.sortByDistance,
      },
    );

    if (result == null) {
      return PoiSearchResult(
        items: const <PoiItem>[],
        page: query.page,
        pageSize: query.pageSize,
      );
    }

    return PoiSearchResult.decodeFromMap(Map<String, dynamic>.from(result));
  }

  /// 地理编码
  @override
  Future<List<GeocodeResult>> searchGeocode(GeocodeQuery query) async {
    final result = await _searchChannel
        .invokeMethod<List<dynamic>>('searchGeocode', <String, dynamic>{
          'address': query.address,
          'city': query.city ?? '',
          'country': query.country ?? '',
        });

    if (result == null) {
      return const <GeocodeResult>[];
    }

    return result.map((item) {
      return GeocodeResult.decodeFromMap(
        Map<String, dynamic>.from(item as Map),
      );
    }).toList();
  }

  /// 逆地理编码
  @override
  Future<ReGeocodeResult> searchReGeocode(ReGeocodeQuery query) async {
    final result = await _searchChannel.invokeMethod<Map<dynamic, dynamic>>(
      'searchReGeocode',
      <String, dynamic>{
        'latitude': query.position.latitude,
        'longitude': query.position.longitude,
        'radius': query.radius,
        'extensions': query.extensions.value,
        'coordinateType': query.coordinateType.value,
        'poiTypes': query.poiTypes ?? '',
      },
    );

    if (result == null) {
      throw StateError('Failed to get re-geocode data');
    }

    return ReGeocodeResult.decodeFromMap(Map<String, dynamic>.from(result));
  }

  /// 驾车路线规划
  @override
  Future<RoutePlanResult> searchDriveRoute(DriveRouteQuery query) {
    return _searchRoute('searchDriveRoute', query);
  }

  /// 步行路线规划
  @override
  Future<RoutePlanResult> searchWalkRoute(WalkRouteQuery query) {
    return _searchRoute('searchWalkRoute', query);
  }

  /// 骑行路线规划
  @override
  Future<RoutePlanResult> searchRideRoute(RideRouteQuery query) {
    return _searchRoute('searchRideRoute', query);
  }

  Future<RoutePlanResult> _searchRoute(
    String method,
    RoutePlanQuery query,
  ) async {
    final result = await _searchChannel.invokeMethod<Map<dynamic, dynamic>>(
      method,
      query.toMap(),
    );
    if (result == null) {
      return RoutePlanResult.empty(type: query.type);
    }
    return RoutePlanResult.decodeFromMap(Map<String, dynamic>.from(result));
  }

  // ==================== 天气相关方法实现 ====================

  /// 查询实时天气
  @override
  Future<LocalWeatherLive> searchWeatherLive({required String city}) async {
    final result = await _searchChannel.invokeMethod<Map<dynamic, dynamic>>(
      'searchWeatherLive',
      <String, dynamic>{'city': city},
    );

    if (result == null) {
      throw StateError('Failed to get weather live data');
    }

    final map = Map<String, dynamic>.from(result);
    return LocalWeatherLive.decodeFromMap(map);
  }

  /// 查询天气预报
  @override
  Future<LocalWeatherForecast> searchWeatherForecast({
    required String city,
  }) async {
    final result = await _searchChannel.invokeMethod<Map<dynamic, dynamic>>(
      'searchWeatherForecast',
      <String, dynamic>{'city': city},
    );

    if (result == null) {
      throw StateError('Failed to get weather forecast data');
    }

    final map = Map<String, dynamic>.from(result);
    return LocalWeatherForecast.decodeFromMap(map);
  }

  /// 根据当前定位查询实时天气
  @override
  Future<LocalWeatherLive> searchWeatherLiveByLocation() async {
    final result = await _searchChannel.invokeMethod<Map<dynamic, dynamic>>(
      'searchWeatherLiveByLocation',
    );

    if (result == null) {
      throw StateError('Failed to get weather live data by location');
    }

    final map = Map<String, dynamic>.from(result);
    return LocalWeatherLive.decodeFromMap(map);
  }

  /// 根据当前定位查询天气预报
  @override
  Future<LocalWeatherForecast> searchWeatherForecastByLocation() async {
    final result = await _searchChannel.invokeMethod<Map<dynamic, dynamic>>(
      'searchWeatherForecastByLocation',
    );

    if (result == null) {
      throw StateError('Failed to get weather forecast data by location');
    }

    final map = Map<String, dynamic>.from(result);
    return LocalWeatherForecast.decodeFromMap(map);
  }
}
