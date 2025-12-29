package com.morbit.amap_flutter

import android.os.Bundle
import android.view.View
import android.view.WindowManager
import androidx.core.view.ViewCompat
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import com.amap.api.navi.AmapRouteActivity

/**
 * 用于承载高德内置路线规划/导航页面的自定义 Activity：
 * - 强制显示状态栏/导航栏（避免 SDK 或宿主开启沉浸式后变成全屏）
 * - 将 WindowInsets 转为 padding，达到类似 Flutter SafeArea 的效果
 */
class AMapFlutterRouteActivity : AmapRouteActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        applySafeAreaAndSystemBars()
    }

    override fun onResume() {
        super.onResume()
        applySafeAreaAndSystemBars()
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus) {
            applySafeAreaAndSystemBars()
        }
    }

    private fun applySafeAreaAndSystemBars() {
        // 防止全屏/透明系统栏导致“状态栏/底部栏都不见了”
        window.clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)
        window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS)
        window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION)

        // 让内容可以绘制到系统栏区域，但我们用 Insets 转 padding 来做 SafeArea
        WindowCompat.setDecorFitsSystemWindows(window, false)

        // 强制显示系统栏（某些 SDK Activity 会在 onResume/onFocus 时重置沉浸式）
        val controller = WindowInsetsControllerCompat(window, window.decorView)
        controller.systemBarsBehavior =
            WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
        controller.show(WindowInsetsCompat.Type.systemBars())

        // 兼容旧 API：清除隐藏系统栏相关 flag
        @Suppress("DEPRECATION")
        window.decorView.systemUiVisibility = window.decorView.systemUiVisibility and
            View.SYSTEM_UI_FLAG_FULLSCREEN.inv() and
            View.SYSTEM_UI_FLAG_HIDE_NAVIGATION.inv() and
            View.SYSTEM_UI_FLAG_IMMERSIVE.inv() and
            View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY.inv()

        val content = findViewById<View>(android.R.id.content) ?: return
        ViewCompat.setOnApplyWindowInsetsListener(content) { v, insets ->
            val safeInsets = insets.getInsets(
                WindowInsetsCompat.Type.systemBars() or WindowInsetsCompat.Type.displayCutout()
            )
            v.setPadding(safeInsets.left, safeInsets.top, safeInsets.right, safeInsets.bottom)
            insets
        }
        ViewCompat.requestApplyInsets(content)
    }
}


