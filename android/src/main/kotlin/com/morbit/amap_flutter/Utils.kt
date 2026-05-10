package com.morbit.amap_flutter

import android.graphics.BitmapFactory
import androidx.core.graphics.scale
import com.amap.api.maps.AMap
import com.amap.api.maps.AMapOptions
import com.amap.api.maps.model.ArcOptions
import com.amap.api.maps.model.BitmapDescriptor
import com.amap.api.maps.model.BitmapDescriptorFactory
import com.amap.api.maps.model.LatLng
import com.amap.api.maps.model.LatLngBounds
import com.amap.api.maps.model.MarkerOptions
import com.amap.api.maps.model.MyLocationStyle
import com.amap.api.maps.model.PolygonOptions
import com.amap.api.maps.model.PolylineOptions
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import android.location.Location as AndroidLocation
import com.amap.api.maps.model.CameraPosition as AMapCameraPosition
import com.amap.api.maps.model.Poi as AMapPoi

fun MapType.toMapType(): Int? {
    return when (this) {
        MapType.STANDARD -> AMap.MAP_TYPE_NORMAL
        MapType.SATELLITE -> AMap.MAP_TYPE_SATELLITE
        MapType.STANDARD_NIGHT -> AMap.MAP_TYPE_NIGHT
        MapType.NAVI -> AMap.MAP_TYPE_NAVI
        MapType.BUS -> AMap.MAP_TYPE_BUS
        else -> null
    }
}

fun UIControlAnchor.toLogoPosition(): Int? {
    return when (this) {
        UIControlAnchor.BOTTOM_LEFT -> AMapOptions.LOGO_POSITION_BOTTOM_LEFT
        UIControlAnchor.BOTTOM_CENTER -> AMapOptions.LOGO_POSITION_BOTTOM_CENTER
        UIControlAnchor.BOTTOM_RIGHT -> AMapOptions.LOGO_POSITION_BOTTOM_RIGHT
        else -> null
    }
}

fun UIControlAnchor.toZoomPosition(): Int? {
    return when (this) {
        UIControlAnchor.CENTER_RIGHT -> AMapOptions.ZOOM_POSITION_RIGHT_CENTER
        UIControlAnchor.BOTTOM_RIGHT -> AMapOptions.ZOOM_POSITION_RIGHT_BUTTOM
        else -> null
    }
}

fun Bitmap.toBitmapDescriptor(binding: FlutterPluginBinding): BitmapDescriptor? {
    var bitmap: android.graphics.Bitmap? = null
    asset?.let {
        bitmap = BitmapDescriptorFactory.fromAsset(binding.flutterAssets.getAssetFilePathByName(it)).bitmap
    }
    bytes?.let {
        bitmap = BitmapFactory.decodeByteArray(it, 0, it.size)
    }
    size?.let {
        bitmap = bitmap?.scale(it.width.toInt(), it.height.toInt())
    }
    return BitmapDescriptorFactory.fromBitmap(bitmap)
}

fun AMapCameraPosition.toCameraPosition(): CameraPosition {
    return CameraPosition(
        target.toPosition(),
        bearing.toDouble(),
        tilt.toDouble(),
        zoom.toDouble(),
    )
}

/**
 * 将 CameraPosition 转换为 AMapCameraPosition
 * 如果 position 为 null，则返回 null（因为 AMapCameraPosition 必须有 target）
 */
fun CameraPosition.toCameraPosition(): AMapCameraPosition? {
    // AMapCameraPosition.Builder 必须设置 target，否则 build() 会抛异常
    val target = position?.toPosition() ?: return null
    return AMapCameraPosition.Builder().let { builder ->
        builder.target(target)
        skew?.let { builder.tilt(skew.toFloat()) }
        zoom?.let { builder.zoom(zoom.toFloat()) }
        heading?.let { builder.bearing(heading.toFloat()) }
        builder.build()
    }
}

fun AndroidLocation.toLocation(): Location {
    return Location(
        Position(latitude, longitude), bearing.toDouble(), accuracy.toDouble()
    )
}

fun Marker.toMarkerOptions(binding: FlutterPluginBinding): MarkerOptions {
    return MarkerOptions().let { options ->
        position.toPosition().let { options.position(it) }
        bitmap?.toBitmapDescriptor(binding)?.let { options.icon(it) }
        title?.takeIf { it.isNotBlank() }?.let { options.title(it) }
        snippet?.takeIf { it.isNotBlank() }?.let { options.snippet(it) }
        options
    }
}

fun Polyline.toPolylineOptions(): PolylineOptions {
    return PolylineOptions().let { options ->
        options.addAll(points.map { it.toPosition() })
        options.color(color.toArgb())
        if (colors.isNotEmpty()) {
            options.colorValues(colors.map { it.toArgb() })
            options.useGradient(gradient)
        }
        options.geodesic(geodesic)
        options.width(width.toFloat())
        options.visible(visible)
        options
    }
}

fun Arc.toArcOptions(): ArcOptions {
    return ArcOptions().let { options ->
        options.point(start.toPosition(), passed.toPosition(), end.toPosition())
        options.strokeColor(color.toArgb())
        options.strokeWidth(width.toFloat())
        options.visible(visible)
        options
    }
}

fun Polygon.toPolygonOptions(): PolygonOptions {
    return PolygonOptions().let { options ->
        options.addAll(points.map { it.toPosition() })
        options.strokeWidth(strokeWidth.toFloat())
        options.strokeColor(strokeColor.toArgb())
        options.fillColor(fillColor.toArgb())
        options.visible(visible)
        options
    }
}

fun AMapPoi.toPoi(): Poi {
    return Poi(name, coordinate.toPosition())
}

fun Position.toPosition(): LatLng {
    return LatLng(latitude, longitude)
}

fun LatLng.toPosition(): Position {
    return Position(latitude, longitude)
}

fun Region.toLatLngBounds(): LatLngBounds {
    return LatLngBounds(LatLng(south, west), LatLng(north, east))
}

fun UserLocationStyle.toLocationStyle(binding: FlutterPluginBinding): MyLocationStyle {
    val myLocationStyle = MyLocationStyle()
    userLocationType?.toMyLocationType()?.let { myLocationStyle.myLocationType(it) }
    myLocationStyle.interval(normalizedIntervalMs())
    showLocationDot?.let { myLocationStyle.showMyLocation(it) }
    anchor?.let { myLocationStyle.anchor(it.x.toFloat(), it.y.toFloat()) }
    fillColor?.toArgb()?.let { myLocationStyle.radiusFillColor(it) }
    strokeColor?.toArgb()?.let { myLocationStyle.strokeColor(it) }
    lineWidth?.toFloat()?.let { myLocationStyle.strokeWidth(it) }
    if (showsAccuracyRing == false) {
        myLocationStyle.radiusFillColor(android.graphics.Color.TRANSPARENT)
        myLocationStyle.strokeColor(android.graphics.Color.TRANSPARENT)
        myLocationStyle.strokeWidth(0f)
    }
    image?.let { myLocationStyle.myLocationIcon(it.toBitmapDescriptor(binding)) }
    return myLocationStyle
}

fun UserLocationStyle.normalizedIntervalMs(): Long {
    return (intervalMs ?: 1000L).coerceAtLeast(1000L)
}

fun UserLocationType.toMyLocationType(): Int {
    return when (this) {
        UserLocationType.LOCATION_TYPE_SHOW -> MyLocationStyle.LOCATION_TYPE_SHOW
        UserLocationType.LOCATION_TYPE_LOCATE -> MyLocationStyle.LOCATION_TYPE_LOCATE
        UserLocationType.LOCATION_TYPE_FOLLOW -> MyLocationStyle.LOCATION_TYPE_FOLLOW
        UserLocationType.LOCATION_TYPE_MAP_ROTATE -> MyLocationStyle.LOCATION_TYPE_MAP_ROTATE
        UserLocationType.LOCATION_TYPE_LOCATION_ROTATE -> MyLocationStyle.LOCATION_TYPE_LOCATION_ROTATE
        UserLocationType.LOCATION_TYPE_LOCATION_ROTATE_NO_CENTER -> MyLocationStyle.LOCATION_TYPE_LOCATION_ROTATE_NO_CENTER
        UserLocationType.LOCATION_TYPE_FOLLOW_NO_CENTER -> MyLocationStyle.LOCATION_TYPE_FOLLOW_NO_CENTER
        UserLocationType.LOCATION_TYPE_MAP_ROTATE_NO_CENTER -> MyLocationStyle.LOCATION_TYPE_MAP_ROTATE_NO_CENTER
    }
}

fun UserLocationType.isOnceLocationMode(): Boolean {
    return this == UserLocationType.LOCATION_TYPE_SHOW ||
        this == UserLocationType.LOCATION_TYPE_LOCATE
}
