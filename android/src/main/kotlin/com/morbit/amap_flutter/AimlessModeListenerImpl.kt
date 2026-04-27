package com.morbit.amap_flutter

import android.util.Log
import com.amap.api.navi.AimlessModeListener
import com.amap.api.navi.model.AMapNaviTrafficFacilityInfo
import com.amap.api.navi.model.AimLessModeCongestionInfo
import com.amap.api.navi.model.AimLessModeStat
import com.amap.api.maps.model.LatLng
import io.flutter.plugin.common.EventChannel

/**
 * 智能巡航 [AimlessModeListener] 实现，将事件转发到与 [AMapNaviListenerImpl] 共用的 [EventChannel.EventSink]。
 */
class AimlessModeListenerImpl : AimlessModeListener {
    companion object {
        private const val TAG = "AimlessModeListener"
    }

    var eventSink: EventChannel.EventSink? = null

    private fun send(m: Map<String, Any?>) {
        try {
            eventSink?.success(m)
        } catch (e: Exception) {
            Log.e(TAG, "send event", e)
        }
    }

    override fun onUpdateTrafficFacility(infos: Array<out AMapNaviTrafficFacilityInfo>?) {
        send(
            mapOf(
                "type" to "cruiseTrafficFacilities",
                "facilities" to (infos?.map { trafficFacilityToMap(it, "specialRoad") } ?: emptyList())
            )
        )
    }

    override fun onUpdateAimlessModeElecCameraInfo(cameraInfo: Array<out AMapNaviTrafficFacilityInfo>?) {
        send(
            mapOf(
                "type" to "cruiseTrafficFacilities",
                "facilities" to (cameraInfo?.map { trafficFacilityToMap(it, "elecCamera") } ?: emptyList())
            )
        )
    }

    override fun updateAimlessModeStatistics(stat: AimLessModeStat?) {
        send(statToFlutterMap(stat))
    }

    override fun updateAimlessModeCongestionInfo(info: AimLessModeCongestionInfo?) {
        send(congestionToFlutterMap(info))
    }

    private fun invokeGetter(target: Any, vararg methodNames: String): Any? {
        val clazz = target.javaClass
        for (name in methodNames) {
            try {
                val m = clazz.methods.firstOrNull { it.name == name && it.parameterCount == 0 }
                if (m != null) {
                    return m.invoke(target)
                }
            } catch (_: Throwable) {
                // try next
            }
        }
        return null
    }

    private fun trafficFacilityToMap(info: AMapNaviTrafficFacilityInfo?, source: String): Map<String, Any?> {
        if (info == null) return emptyMap()
        val typeVal = invokeGetter(
            info,
            "getType",
            "getFacilityType",
            "getSubType"
        )
        val coord = invokeGetter(
            info,
            "getCoordinate",
            "getCoord",
            "getLatLng",
            "getPoint"
        )
        var lat: Double? = null
        var lng: Double? = null
        when (coord) {
            is LatLng -> {
                lat = coord.latitude
                lng = coord.longitude
            }
            else -> {
                val la = invokeGetter(info, "getLatitude", "getLat")
                val lo = invokeGetter(info, "getLongitude", "getLng")
                if (la is Number) lat = la.toDouble()
                if (lo is Number) lng = lo.toDouble()
            }
        }
        val dist = invokeGetter(info, "getDistance", "getDist", "getRemainDistance")
        val limit = invokeGetter(info, "getLimitSpeed", "getSpeedLimit")
        val extra = mutableMapOf<String, Any?>()
        extra["sdkString"] = info.toString()
        return mapOf(
            "source" to source,
            "type" to (typeVal as? Number)?.toInt(),
            "latitude" to lat,
            "longitude" to lng,
            "remainDistanceMeters" to (dist as? Number)?.toInt(),
            "speedLimitKmh" to (limit as? Number)?.toInt(),
            "raw" to extra
        )
    }

    private fun statToFlutterMap(stat: AimLessModeStat?): Map<String, Any?> {
        if (stat == null) {
            return mapOf(
                "type" to "cruiseStatistics",
                "cumulativeDistanceMeters" to null,
                "cumulativeTimeSeconds" to null,
                "extra" to emptyMap<String, Any?>()
            )
        }
        val dist = invokeGetter(
            stat,
            "getAimlessModeDistance",
            "getTotalAimlessModeDistance",
            "getTotalDistance",
            "getDistance"
        )
        val timeSec = invokeGetter(
            stat,
            "getAimlessModeTime",
            "getTotalAimlessModeTime",
            "getTotalTime",
            "getTime"
        )
        val extra = mutableMapOf<String, Any?>()
        extra["sdkString"] = stat.toString()
        return mapOf(
            "type" to "cruiseStatistics",
            "cumulativeDistanceMeters" to (dist as? Number)?.toInt(),
            "cumulativeTimeSeconds" to (timeSec as? Number)?.toInt(),
            "extra" to extra
        )
    }

    private fun congestionToFlutterMap(info: AimLessModeCongestionInfo?): Map<String, Any?> {
        if (info == null) {
            return mapOf(
                "type" to "cruiseCongestion",
                "raw" to emptyMap<String, Any?>()
            )
        }
        val raw = mutableMapOf<String, Any?>()
        raw["sdkString"] = info.toString()
        val desc = invokeGetter(info, "getDescription", "getRoadName")
        if (desc != null) raw["description"] = desc.toString()
        return mapOf(
            "type" to "cruiseCongestion",
            "raw" to raw
        )
    }
}
