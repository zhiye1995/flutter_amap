part of '../../flutter_amap_navi.dart';

/// 导航事件基类。
abstract class NaviEvent<T> {
  NaviEvent(this.value);

  final T value;
}

class NaviInitSuccessEvent extends NaviEvent<void> {
  NaviInitSuccessEvent() : super(null);
}

class NaviInitFailureEvent extends NaviEvent<String> {
  NaviInitFailureEvent(super.message);

  String get message => value;
}

class NaviInfoUpdateEvent extends NaviEvent<NaviInfo> {
  NaviInfoUpdateEvent(super.naviInfo);

  NaviInfo get naviInfo => value;
}

class NaviLocationChangeEvent extends NaviEvent<NaviLocation> {
  NaviLocationChangeEvent(super.location);

  NaviLocation get location => value;
}

class NaviTextEvent extends NaviEvent<String> {
  NaviTextEvent(super.text);

  String get text => value;
}

class NaviArriveDestinationEvent extends NaviEvent<void> {
  NaviArriveDestinationEvent() : super(null);
}

class NaviStartEvent extends NaviEvent<int> {
  NaviStartEvent(super.type);

  int get type => value;
}

class NaviRouteCalculateSuccessEvent extends NaviEvent<List<int>> {
  NaviRouteCalculateSuccessEvent(super.routeIds);

  List<int> get routeIds => value;
}

class NaviRouteCalculateFailureEvent extends NaviEvent<int> {
  NaviRouteCalculateFailureEvent(super.errorCode);

  int get errorCode => value;
}

class NaviReCalculateRouteForYawEvent extends NaviEvent<void> {
  NaviReCalculateRouteForYawEvent() : super(null);
}

class NaviReCalculateRouteForTrafficJamEvent extends NaviEvent<void> {
  NaviReCalculateRouteForTrafficJamEvent() : super(null);
}

class NaviArrivedWayPointEvent extends NaviEvent<int> {
  NaviArrivedWayPointEvent(super.wayPointIndex);

  int get wayPointIndex => value;
}

class NaviGpsSignalEvent extends NaviEvent<bool> {
  NaviGpsSignalEvent(super.isWeak);

  bool get isWeak => value;
}

class NaviTrafficStatusUpdateEvent extends NaviEvent<void> {
  NaviTrafficStatusUpdateEvent() : super(null);
}

class NaviEndEmulatorEvent extends NaviEvent<void> {
  NaviEndEmulatorEvent() : super(null);
}

class NaviExitEvent extends NaviEvent<int> {
  NaviExitEvent(super.exitCode);

  int get exitCode => value;
}

class CruiseTrafficFacilityEvent
    extends NaviEvent<List<CruiseTrafficFacilityItem>> {
  CruiseTrafficFacilityEvent(super.facilities);

  List<CruiseTrafficFacilityItem> get facilities => value;
}

class CruiseElecCameraInfoEvent
    extends NaviEvent<List<CruiseTrafficFacilityItem>> {
  CruiseElecCameraInfoEvent(super.cameraInfos);

  List<CruiseTrafficFacilityItem> get cameraInfos => value;
}

class CruiseTrafficFacilitiesEvent
    extends NaviEvent<List<CruiseTrafficFacilityItem>> {
  CruiseTrafficFacilitiesEvent(super.facilities);

  List<CruiseTrafficFacilityItem> get facilities => value;
}

class CruiseStatisticsEvent extends NaviEvent<CruiseStatisticsInfo> {
  CruiseStatisticsEvent(super.statistics);

  CruiseStatisticsInfo get statistics => value;
}

class CruiseCongestionEvent extends NaviEvent<CruiseCongestionInfo> {
  CruiseCongestionEvent(super.congestion);

  CruiseCongestionInfo get congestion => value;
}
