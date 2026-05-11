package com.morbit.amap_flutter

import android.util.Log
import com.amap.api.navi.AimlessModeListener
import com.amap.api.navi.model.AMapNaviTrafficFacilityInfo
import com.amap.api.navi.model.AimLessModeCongestionInfo
import com.amap.api.navi.model.AimLessModeStat
import com.amap.api.maps.model.LatLng
import com.amap.api.navi.model.NaviLatLng
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
                "facilities" to (infos?.map {
                    trafficFacilityToMap(it, "specialRoad", "onUpdateTrafficFacility")
                } ?: emptyList())
            )
        )
    }

    override fun onUpdateAimlessModeElecCameraInfo(cameraInfo: Array<out AMapNaviTrafficFacilityInfo>?) {
        send(
            mapOf(
                "type" to "cruiseElecCameraInfo",
                "facilities" to (cameraInfo?.map {
                    trafficFacilityToMap(it, "elecCamera", "onUpdateAimlessModeElecCameraInfo")
                } ?: emptyList())
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

    private fun numberToInt(v: Number?): Int? = v?.toInt()

    private fun numberToDouble(v: Number?): Double? = v?.toDouble()

    private fun coordToMap(coord: Any?): Map<String, Any?>? {
        if (coord == null) return null
        val lat = when (coord) {
            is LatLng -> coord.latitude
            is NaviLatLng -> coord.latitude
            else -> numberToDouble(readNumber(coord, "latitude", "lat"))
        }
        val lng = when (coord) {
            is LatLng -> coord.longitude
            is NaviLatLng -> coord.longitude
            else -> numberToDouble(readNumber(coord, "longitude", "lng", "lon"))
        }
        if (lat == null || lng == null) return null
        return mapOf("latitude" to lat, "longitude" to lng)
    }

    private fun trafficFacilityToMap(
        info: AMapNaviTrafficFacilityInfo?,
        source: String,
        callbackName: String
    ): Map<String, Any?> {
        if (info == null) return emptyMap()
        val typeVal = try {
            info.broadcastType
        } catch (_: Throwable) {
            numberToInt(readNumber(info, "broadcastType", "type", "facilityType", "subType"))
        }
        val coord = readMember(info, "coordinate", "coord", "latLng", "point")
        val coordMap = coordToMap(coord)
        val lat = coordMap?.get("latitude") as? Double ?: numberToDouble(readNumber(info, "coorY", "latitude", "lat"))
        val lng = coordMap?.get("longitude") as? Double ?: numberToDouble(readNumber(info, "coorX", "longitude", "lng", "lon"))
        val dist = try {
            info.distance
        } catch (_: Throwable) {
            numberToInt(readNumber(info, "distance", "dist", "remainDistance"))
        }
        val limit = try {
            info.limitSpeed
        } catch (_: Throwable) {
            numberToInt(readNumber(info, "limitSpeed", "speedLimit"))
        }
        val extra = mutableMapOf<String, Any?>()
        extra["platform"] = "android"
        extra["callbackName"] = callbackName
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
            "type" to typeVal,
            "latitude" to lat,
            "longitude" to lng,
            "remainDistanceMeters" to dist,
            "speedLimitKmh" to limit,
            "callbackName" to callbackName,
            "raw" to extra
        )
    }

    private fun statToFlutterMap(stat: AimLessModeStat?): Map<String, Any?> {
        if (stat == null) {
            return mapOf(
                "type" to "cruiseStatistics",
                "cumulativeDistanceMeters" to null,
                "cumulativeTimeSeconds" to null,
                "extra" to mapOf(
                    "platform" to "android",
                    "callbackName" to "updateAimlessModeStatistics"
                )
            )
        }
        val dist = try {
            stat.aimlessModeDistance
        } catch (_: Throwable) {
            numberToInt(
                readNumber(
                    stat,
                    "aimlessModeDistance",
                    "totalAimlessModeDistance",
                    "totalDistance",
                    "distance"
                )
            )
        }
        val timeSec = try {
            stat.aimlessModeTime
        } catch (_: Throwable) {
            numberToInt(
                readNumber(
                    stat,
                    "aimlessModeTime",
                    "totalAimlessModeTime",
                    "totalTime",
                    "time"
                )
            )
        }
        val extra = mutableMapOf<String, Any?>()
        extra["platform"] = "android"
        extra["callbackName"] = "updateAimlessModeStatistics"
        extra["sdkString"] = stat.toString()
        return mapOf(
            "type" to "cruiseStatistics",
            "cumulativeDistanceMeters" to dist,
            "cumulativeTimeSeconds" to timeSec,
            "extra" to extra
        )
    }

    private fun congestionLinkToMap(link: Any): Map<String, Any?> {
        val coords = (readMember(link, "coords") as? Iterable<*>)
            ?.mapNotNull { coordToMap(it) }
            ?: emptyList()
        val status = numberToInt(readNumber(link, "status", "congestionStatus"))
        val raw = mutableMapOf<String, Any?>()
        raw["sdkString"] = link.toString()
        raw["sdkClass"] = link.javaClass.name
        return mapOf(
            "status" to status,
            "coords" to coords,
            "raw" to raw
        )
    }

    private fun congestionToFlutterMap(info: AimLessModeCongestionInfo?): Map<String, Any?> {
        if (info == null) {
            return mapOf(
                "type" to "cruiseCongestion",
                "roadName" to null,
                "lengthMeters" to null,
                "status" to null,
                "estimatedTimeSeconds" to null,
                "links" to emptyList<Map<String, Any?>>(),
                "raw" to mapOf(
                    "platform" to "android",
                    "callbackName" to "updateAimlessModeCongestionInfo"
                )
            )
        }
        val raw = mutableMapOf<String, Any?>()
        raw["platform"] = "android"
        raw["callbackName"] = "updateAimlessModeCongestionInfo"
        raw["sdkString"] = info.toString()
        raw["sdkClass"] = info.javaClass.name
        val roadName = try {
            info.roadName
        } catch (_: Throwable) {
            readMember(info, "roadName", "description")?.toString()
        }
        val length = try {
            info.length
        } catch (_: Throwable) {
            numberToInt(readNumber(info, "length", "distance"))
        }
        val status = try {
            info.congestionStatus
        } catch (_: Throwable) {
            numberToInt(readNumber(info, "congestionStatus", "status"))
        }
        val time = try {
            info.time
        } catch (_: Throwable) {
            numberToInt(readNumber(info, "time", "estimatedTime", "estimatedTimeSeconds"))
        }
        val links = (try {
            info.amapCongestionLinks
        } catch (_: Throwable) {
            readMember(info, "amapCongestionLinks", "congestionLinks", "links")
        } as? Iterable<*>)
            ?.mapNotNull { it?.let(::congestionLinkToMap) }
            ?: emptyList()
        raw["roadName"] = roadName
        raw["length"] = length
        raw["congestionStatus"] = status
        raw["time"] = time
        raw["linksCount"] = links.size
        return mapOf(
            "type" to "cruiseCongestion",
            "roadName" to roadName,
            "lengthMeters" to length,
            "status" to status,
            "estimatedTimeSeconds" to time,
            "links" to links,
            "raw" to raw
        )
    }
}
