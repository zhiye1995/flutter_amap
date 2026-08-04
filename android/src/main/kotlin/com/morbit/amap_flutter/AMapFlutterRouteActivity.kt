package com.morbit.amap_flutter

import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.view.View
import android.view.Window
import android.view.WindowInsets
import android.view.WindowInsetsController
import android.view.WindowManager
import com.amap.api.navi.AmapRouteActivity


class AMapFlutterRouteActivity : AmapRouteActivity() {

    private var contentRoot: View? = null
    private var contentRootPadding: Padding? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        setTheme(R.style.AMapFlutterRouteTheme)
        super.onCreate(savedInstanceState)
        applySystemBars()
    }

    override fun onResume() {
        super.onResume()
        applySystemBars()
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus) {
            applySystemBars()
        }
    }

    private fun applySystemBars() {
        val window = window

        window.clearFlags(
            WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS or
                WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION
        )
        window.addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)
        window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.setDecorFitsSystemWindows(false)
            window.insetsController?.run {
                hide(WindowInsets.Type.statusBars())
                systemBarsBehavior =
                    WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
            }
        }

        window.statusBarColor = Color.TRANSPARENT
        window.navigationBarColor = Color.WHITE

        window.decorView.systemUiVisibility = lightSystemBarFlags(window)
        applyContentInsets()
    }

    private fun applyContentInsets() {
        val content = findViewById<View>(android.R.id.content) ?: return
        if (contentRoot !== content) {
            contentRoot = content
            contentRootPadding = Padding(
                left = content.paddingLeft,
                top = content.paddingTop,
                right = content.paddingRight,
                bottom = content.paddingBottom
            )
            content.setOnApplyWindowInsetsListener { view, insets ->
                applyInsetsPadding(view, insets)
                insets
            }
        }

        content.requestApplyInsets()
        content.post { content.requestApplyInsets() }
    }

    private fun applyInsetsPadding(view: View, insets: WindowInsets) {
        val padding = contentRootPadding ?: return
        val navigationBars = navigationBars(insets)

        view.setPadding(
            padding.left + navigationBars.left,
            padding.top,
            padding.right + navigationBars.right,
            padding.bottom + navigationBars.bottom
        )
    }

    @Suppress("DEPRECATION")
    private fun navigationBars(insets: WindowInsets): Padding {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val bars = insets.getInsets(WindowInsets.Type.navigationBars())
            Padding(
                left = bars.left,
                top = 0,
                right = bars.right,
                bottom = bars.bottom
            )
        } else {
            Padding(
                left = insets.systemWindowInsetLeft,
                top = 0,
                right = insets.systemWindowInsetRight,
                bottom = insets.systemWindowInsetBottom
            )
        }
    }

    private fun lightSystemBarFlags(window: Window): Int {
        var flags = window.decorView.systemUiVisibility
        flags = flags and View.SYSTEM_UI_FLAG_HIDE_NAVIGATION.inv()
        flags = flags and View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION.inv()
        flags = flags and View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR.inv()
        flags = flags or View.SYSTEM_UI_FLAG_FULLSCREEN
        flags = flags or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
        flags = flags or View.SYSTEM_UI_FLAG_LAYOUT_STABLE
        flags = flags or View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            flags = flags or View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR
        }

        return flags
    }

    private data class Padding(
        val left: Int,
        val top: Int,
        val right: Int,
        val bottom: Int
    )
}


