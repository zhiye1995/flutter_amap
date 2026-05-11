part of '../flutter_amap.dart';

/// 高德导航 API
///
/// 使用导航组件模式启动高德导航页面，支持驾车、步行、骑行导航。
/// 通过事件流获取导航过程中的各种回调信息。
///
/// 使用事项（强烈建议先读）：
///
/// - 支持 **Android** 和 **iOS** 平台。
/// - 调用前请先执行 `AMapFlutter.init(apiKey: ..., agreePrivacy: ...)` 完成 SDK 初始化与隐私合规设置。
/// - 若 `NaviConfig.start == null`（默认使用当前位置），请确保已授予运行时定位权限，否则可能导致路线计算失败/定位不更新。
/// - Android 端建议在宿主 `AndroidManifest.xml` 的 `<application>` 内配置 `com.amap.api.v2.apikey`（内置导航/路线规划页常依赖该 meta-data）。
/// - iOS 端需要在 `Info.plist` 中配置 `NSLocationWhenInUseUsageDescription` 定位权限描述。
/// - 建议在 `startNavigation` 前就订阅事件流（例如 `onNaviInitFailure` / `onNaviExit`），并在页面 `dispose` 时取消订阅、必要时调用 `stopNavigation`。
/// - **智能巡航**（`startCruiseMode`）与正式导航 **互斥**：使用前需停止另一种模式。巡航依赖联网，且官方建议在真实驾车场景验证效果。
/// - 调用 `stopNavigation()` 时原生可能销毁 `AMapNavi`：若正在巡航，请先 `stopCruiseMode()`（插件已在原生侧尽量先停巡航再销毁，仍建议业务侧保持顺序）。
///
/// 使用示例:
/// ```dart
/// // 启动导航
/// await AMapNavi.startNavigation(
///   config: NaviConfig(
///     naviType: NaviType.driver,
///     end: NaviPoint(
///       position: Position(latitude: 39.908, longitude: 116.397),
///       name: "天安门",
///     ),
///   ),
/// );
///
/// // 监听导航信息
/// AMapNavi.onNaviInfoUpdate.listen((event) {
///   print("剩余距离: ${event.naviInfo.pathRetainDistance}");
/// });
/// ```
class AMapNavi {
  AMapNavi._();

  /// 是否正在导航（全局状态）。
  ///
  /// - `startNavigation` 调用成功后会置为 true；
  /// - 收到退出/到达目的地/失败等事件或调用 `stopNavigation` 后会置为 false。
  ///
  /// Flutter UI 建议用 `ValueListenableBuilder` 监听它来切换“启动/继续/停止”等按钮。
  static final ValueNotifier<bool> _isNavigating = ValueNotifier<bool>(false);

  /// 当前是否正在导航
  static bool get isNavigating => _isNavigating.value;

  /// 监听“是否正在导航”的变化（适合 UI）
  static ValueListenable<bool> get isNavigatingListenable => _isNavigating;

  static void _setIsNavigating(bool value) {
    if (_isNavigating.value == value) return;
    _isNavigating.value = value;
  }

  static final ValueNotifier<bool> _isCruising = ValueNotifier<bool>(false);

  /// 当前是否在智能巡航模式
  static bool get isCruising => _isCruising.value;

  /// 监听是否在巡航（便于 UI）
  static ValueListenable<bool> get isCruisingListenable => _isCruising;

  static void _setIsCruising(bool value) {
    if (_isCruising.value == value) return;
    _isCruising.value = value;
  }

  /// 启动导航
  ///
  /// [config] 导航配置，包括起终点、导航类型等
  static Future<void> startNavigation({required NaviConfig config}) async {
    if (isCruising) {
      throw StateError(
        '无法在智能巡航进行中启动导航：请先调用 stopCruiseMode()',
      );
    }
    await AMapFlutterPlatformInterface.instance.startNavigation(config);
    // 启动方法调用成功后即认为进入导航态；若后续失败，会在事件回调里回落为 false
    _setIsNavigating(true);
  }

  /// 停止导航
  static Future<void> stopNavigation() async {
    await AMapFlutterPlatformInterface.instance.stopNavigation();
    _setIsNavigating(false);
  }

  /// 开启智能巡航（无起终点、不算路）。
  ///
  /// 与 [startNavigation] 互斥；需联网；详见类注释。
  static Future<void> startCruiseMode({
    required CruiseBroadcastMode mode,
    bool useInnerVoice = true,
    bool allowsBackgroundLocationUpdates = true,
    bool pausesLocationUpdatesAutomatically = false,
  }) {
    return startCruise(
      CruiseConfig(
        mode: mode,
        useInnerVoice: useInnerVoice,
        allowsBackgroundLocationUpdates: allowsBackgroundLocationUpdates,
        pausesLocationUpdatesAutomatically: pausesLocationUpdatesAutomatically,
      ),
    );
  }

  /// 使用完整配置开启智能巡航。
  static Future<void> startCruise(CruiseConfig config) async {
    if (isNavigating) {
      throw StateError(
        '无法在导航进行中开启巡航：请先调用 stopNavigation()',
      );
    }
    // Android 巡航会复用 AMapNaviListener，并可能在原生调用返回前发出
    // startNavi 事件。先进入巡航态，避免该事件把 Dart 状态误置为导航中。
    _setIsCruising(true);
    try {
      await AMapFlutterPlatformInterface.instance.startCruiseMode(config);
    } catch (_) {
      _setIsCruising(false);
      rethrow;
    }
  }

  /// 停止智能巡航
  static Future<void> stopCruiseMode() async {
    await AMapFlutterPlatformInterface.instance.stopCruiseMode();
    _setIsCruising(false);
    // 防御旧版/原生回调把巡航误标为导航中的遗留状态。
    _setIsNavigating(false);
  }

  /// 导航初始化成功事件流
  static Stream<NaviInitSuccessEvent> get onNaviInitSuccess =>
      AMapFlutterPlatformInterface.instance.onNaviInitSuccess;

  /// 导航初始化失败事件流
  static Stream<NaviInitFailureEvent> get onNaviInitFailure =>
      AMapFlutterPlatformInterface.instance.onNaviInitFailure;

  /// 导航引导信息更新事件流
  ///
  /// 包含转向图标类型、剩余距离、下一路名、剩余时间等信息
  static Stream<NaviInfoUpdateEvent> get onNaviInfoUpdate =>
      AMapFlutterPlatformInterface.instance.onNaviInfoUpdate;

  /// 导航定位变化事件流
  static Stream<NaviLocationChangeEvent> get onNaviLocationChange =>
      AMapFlutterPlatformInterface.instance.onNaviLocationChange;

  /// 导航语音播报事件流
  ///
  /// 可用于自定义语音播报
  static Stream<NaviTextEvent> get onNaviText =>
      AMapFlutterPlatformInterface.instance.onNaviText;

  /// 到达目的地事件流
  static Stream<NaviArriveDestinationEvent> get onNaviArriveDestination =>
      AMapFlutterPlatformInterface.instance.onNaviArriveDestination;

  /// 导航开始事件流
  static Stream<NaviStartEvent> get onNaviStart =>
      AMapFlutterPlatformInterface.instance.onNaviStart;

  /// 路线计算成功事件流
  static Stream<NaviRouteCalculateSuccessEvent>
      get onNaviRouteCalculateSuccess =>
          AMapFlutterPlatformInterface.instance.onNaviRouteCalculateSuccess;

  /// 路线计算失败事件流
  static Stream<NaviRouteCalculateFailureEvent>
      get onNaviRouteCalculateFailure =>
          AMapFlutterPlatformInterface.instance.onNaviRouteCalculateFailure;

  /// 偏航重新计算路线事件流
  static Stream<NaviReCalculateRouteForYawEvent>
      get onNaviReCalculateRouteForYaw =>
          AMapFlutterPlatformInterface.instance.onNaviReCalculateRouteForYaw;

  /// 拥堵重新计算路线事件流
  static Stream<NaviReCalculateRouteForTrafficJamEvent>
      get onNaviReCalculateRouteForTrafficJam => AMapFlutterPlatformInterface
          .instance.onNaviReCalculateRouteForTrafficJam;

  /// 到达途经点事件流
  static Stream<NaviArrivedWayPointEvent> get onNaviArrivedWayPoint =>
      AMapFlutterPlatformInterface.instance.onNaviArrivedWayPoint;

  /// GPS信号状态变化事件流
  static Stream<NaviGpsSignalEvent> get onNaviGpsSignal =>
      AMapFlutterPlatformInterface.instance.onNaviGpsSignal;

  /// 交通状态更新事件流
  static Stream<NaviTrafficStatusUpdateEvent> get onNaviTrafficStatusUpdate =>
      AMapFlutterPlatformInterface.instance.onNaviTrafficStatusUpdate;

  /// 模拟导航结束事件流
  static Stream<NaviEndEmulatorEvent> get onNaviEndEmulator =>
      AMapFlutterPlatformInterface.instance.onNaviEndEmulator;

  /// 退出导航页面事件流
  static Stream<NaviExitEvent> get onNaviExit =>
      AMapFlutterPlatformInterface.instance.onNaviExit;

  // ====================================== 智能巡航相关事件流 ======================================
  /// 巡航道路设施信息，对应 Android `AimlessModeListener.onUpdateTrafficFacility`。
  static Stream<CruiseTrafficFacilityEvent> get onCruiseTrafficFacility =>
      AMapFlutterPlatformInterface.instance.onCruiseTrafficFacility;

  /// 巡航电子眼信息，对应 Android `AimlessModeListener.onUpdateAimlessModeElecCameraInfo`。
  static Stream<CruiseElecCameraInfoEvent> get onCruiseElecCameraInfo =>
      AMapFlutterPlatformInterface.instance.onCruiseElecCameraInfo;

  /// 巡航道路设施 / 电子眼等信息（兼容旧版合并事件，新代码建议分别订阅上面两个流）
  static Stream<CruiseTrafficFacilitiesEvent> get onCruiseTrafficFacilities =>
      AMapFlutterPlatformInterface.instance.onCruiseTrafficFacilities;

  /// 巡航统计（连续距离、连续时间等）
  static Stream<CruiseStatisticsEvent> get onCruiseStatistics =>
      AMapFlutterPlatformInterface.instance.onCruiseStatistics;

  /// 巡航拥堵信息（主要为 Android）
  static Stream<CruiseCongestionEvent> get onCruiseCongestion =>
      AMapFlutterPlatformInterface.instance.onCruiseCongestion;
}
