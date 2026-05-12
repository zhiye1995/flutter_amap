package com.morbit.amap_flutter

import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.view.View
import android.view.Window
import android.view.WindowInsets
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
            WindowManager.LayoutParams.FLAG_FULLSCREEN or
                WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS or
                WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION
        )
        window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.setDecorFitsSystemWindows(false)
        }

        window.statusBarColor = Color.WHITE
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
        val systemBars = systemBars(insets)

        view.setPadding(
            padding.left + systemBars.left,
            padding.top + systemBars.top,
            padding.right + systemBars.right,
            padding.bottom + systemBars.bottom
        )
    }

    @Suppress("DEPRECATION")
    private fun systemBars(insets: WindowInsets): Padding {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val bars = insets.getInsets(WindowInsets.Type.systemBars())
            Padding(
                left = bars.left,
                top = bars.top,
                right = bars.right,
                bottom = bars.bottom
            )
        } else {
            Padding(
                left = insets.systemWindowInsetLeft,
                top = insets.systemWindowInsetTop,
                right = insets.systemWindowInsetRight,
                bottom = insets.systemWindowInsetBottom
            )
        }
    }

    private fun lightSystemBarFlags(window: Window): Int {
        var flags = window.decorView.systemUiVisibility
        flags = flags and View.SYSTEM_UI_FLAG_FULLSCREEN.inv()
        flags = flags and View.SYSTEM_UI_FLAG_HIDE_NAVIGATION.inv()
        flags = flags and View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN.inv()
        flags = flags and View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION.inv()
        flags = flags and View.SYSTEM_UI_FLAG_IMMERSIVE.inv()
        flags = flags and View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY.inv()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            flags = flags or View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR
        }
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


