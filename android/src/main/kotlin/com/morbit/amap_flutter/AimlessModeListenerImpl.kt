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

    private fun readMember(target: Any, vararg names: String): Any? {
        val clazz = target.javaClass
        for (name in names) {
            val methodNames = mutableListOf(name)
            if (!name.startsWith("get") && !name.startsWith("is")) {
                val cap = if (name.isNotEmpty()) {
                    Character.toUpperCase(name[0]) + name.substring(1)
                } else {
                    name
                }
                methodNames.add("get$cap")
                methodNames.add("is$cap")
            }

            for (methodName in methodNames) {
                try {
                    val m = clazz.methods.firstOrNull { it.name == methodName && it.parameterCount == 0 }
                    if (m != null) {
                        return m.invoke(target)
                    }
                } catch (_: Throwable) {
                    // try next
                }
            }

            try {
                val f = clazz.fields.firstOrNull { it.name == name }
                if (f != null) return f.get(target)
            } catch (_: Throwable) {
                // try declared field
            }

            try {
                val f = clazz.declaredFields.firstOrNull { it.name == name }
                if (f != null) {
                    f.isAccessible = true
                    return f.get(target)
                }
            } catch (_: Throwable) {
                // try next
            }
        }
        return null
    }

    private fun readNumber(target: Any, vararg names: String): Number? {
        for (name in names) {
            val v = readMember(target, name) ?: continue
            when (v) {
                is Number -> return v
                is String -> v.toDoubleOrNull()?.let { return it }
            }
        }
        return null
    }

    private fun trafficFacilityToMap(info: AMapNaviTrafficFacilityInfo?, source: String): Map<String, Any?> {
        if (info == null) return emptyMap()
        val typeVal = readNumber(
            info,
            "broadcastType",
            "type",
            "facilityType",
            "subType"
        )
        val coord = readMember(info, "coordinate", "coord", "latLng", "point")
        val coordLat = when (coord) {
            is LatLng -> coord.latitude
            null -> null
            else -> readNumber(coord, "latitude", "lat")?.toDouble()
        }
        val coordLng = when (coord) {
            is LatLng -> coord.longitude
            null -> null
            else -> readNumber(coord, "longitude", "lng", "lon")?.toDouble()
        }
        val lat = coordLat ?: readNumber(info, "coorY", "latitude", "lat")?.toDouble()
        val lng = coordLng ?: readNumber(info, "coorX", "longitude", "lng", "lon")?.toDouble()
        val dist = readNumber(info, "distance", "dist", "remainDistance")
        val limit = readNumber(info, "limitSpeed", "speedLimit")
        val extra = mutableMapOf<String, Any?>()
        extra["sdkString"] = info.toString()
        extra["sdkClass"] = info.javaClass.name
        extra["sourceCallback"] = source
        extra["type"] = typeVal
        extra["latitude"] = lat
        extra["longitude"] = lng
        extra["distance"] = dist
        extra["limitSpeed"] = limit
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
        val dist = readNumber(
            stat,
            "aimlessModeDistance",
            "totalAimlessModeDistance",
            "totalDistance",
            "distance"
        )
        val timeSec = readNumber(
            stat,
            "aimlessModeTime",
            "totalAimlessModeTime",
            "totalTime",
            "time"
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
        val desc = readMember(info, "description", "roadName")
        if (desc != null) raw["description"] = desc.toString()
        return mapOf(
            "type" to "cruiseCongestion",
            "raw" to raw
        )
    }
}
