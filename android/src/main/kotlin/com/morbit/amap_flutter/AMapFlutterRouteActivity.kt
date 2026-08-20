package com.morbit.amap_flutter

import android.graphics.Color
import android.graphics.Insets
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
        prepareWindowForFullscreen()
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

    private fun prepareWindowForFullscreen() {
        val window = window

        window.clearFlags(
            WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS or
                WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION
        )
        window.addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)
        window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            window.attributes = window.attributes.apply {
                layoutInDisplayCutoutMode =
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                        WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_ALWAYS
                    } else {
                        WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
                    }
            }
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.setDecorFitsSystemWindows(false)
        }

        window.statusBarColor = Color.TRANSPARENT
        window.navigationBarColor = Color.WHITE
    }

    private fun applySystemBars() {
        prepareWindowForFullscreen()
        window.decorView.systemUiVisibility = lightSystemBarFlags(window)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.insetsController?.run {
                hide(WindowInsets.Type.statusBars())
                systemBarsBehavior =
                    WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
            }
        }

        applyContentInsets()
    }

    private fun applyContentInsets() {
        val content = findViewById<View>(android.R.id.content) ?: return
        if (contentRoot !== content) {
            contentRoot = content
            contentRootPadding = Padding(
                left = content.paddingLeft,
                top = 0,
                right = content.paddingRight,
                bottom = content.paddingBottom
            )
            content.setOnApplyWindowInsetsListener { view, insets ->
                applyInsetsPadding(view, insets)
                removeTopInsets(insets)
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
    private fun removeTopInsets(insets: WindowInsets): WindowInsets {
        return when {
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.R -> {
                val topInsets =
                    WindowInsets.Type.statusBars() or WindowInsets.Type.displayCutout()
                WindowInsets.Builder(insets)
                    .setInsets(topInsets, Insets.NONE)
                    .setInsetsIgnoringVisibility(topInsets, Insets.NONE)
                    .setDisplayCutout(null)
                    .build()
            }

            Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q -> {
                WindowInsets.Builder(insets)
                    .setSystemWindowInsets(
                        Insets.of(
                            insets.systemWindowInsetLeft,
                            0,
                            insets.systemWindowInsetRight,
                            insets.systemWindowInsetBottom
                        )
                    )
                    .setStableInsets(
                        Insets.of(
                            insets.stableInsetLeft,
                            0,
                            insets.stableInsetRight,
                            insets.stableInsetBottom
                        )
                    )
                    .setDisplayCutout(null)
                    .build()
            }

            Build.VERSION.SDK_INT >= Build.VERSION_CODES.P -> {
                insets.replaceSystemWindowInsets(
                    insets.systemWindowInsetLeft,
                    0,
                    insets.systemWindowInsetRight,
                    insets.systemWindowInsetBottom
                ).consumeDisplayCutout()
            }

            else -> {
                insets.replaceSystemWindowInsets(
                    insets.systemWindowInsetLeft,
                    0,
                    insets.systemWindowInsetRight,
                    insets.systemWindowInsetBottom
                )
            }
        }
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


