package com.morbit.amap_flutter_navi

import com.amap.api.navi.AMapNavi
import com.amap.api.navi.enums.TravelStrategy
import com.amap.api.navi.model.NaviPoi
import org.mockito.Mockito.*
import kotlin.test.Test
import kotlin.test.assertFalse
import kotlin.test.assertTrue

class TravelRouteCalculatorTest {
    @Test
    fun walkingUsesWalkEngineWithOriginalPointsAndStrategy() {
        val engine = mock(AMapNavi::class.java)
        val start = mock(NaviPoi::class.java)
        val end = mock(NaviPoi::class.java)
        val points = listOf(mock(NaviPoi::class.java))
        `when`(engine.calculateWalkRoute(start, points, end, TravelStrategy.MULTIPLE)).thenReturn(true)
        assertTrue(calculateTravelRoute(engine, true, start, points, end, TravelStrategy.MULTIPLE))
        verify(engine).calculateWalkRoute(start, points, end, TravelStrategy.MULTIPLE)
        verifyNoMoreInteractions(engine)
    }

    @Test
    fun cyclingUsesRideEngineAndDoesNotFallbackToDrivingOnFailure() {
        val engine = mock(AMapNavi::class.java)
        val end = mock(NaviPoi::class.java)
        assertFalse(calculateTravelRoute(engine, false, null, emptyList(), end, TravelStrategy.SINGLE))
        verify(engine).calculateRideRoute(null, emptyList(), end, TravelStrategy.SINGLE)
        verifyNoMoreInteractions(engine)
    }
}
