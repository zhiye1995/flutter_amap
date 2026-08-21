package com.morbit.amap_flutter

import android.graphics.Color
import android.graphics.Insets
import android.os.Build
import android.os.Bundle
import android.view.View
import android.view.ViewGroup
import android.view.ViewTreeObserver
import android.view.Window
import android.view.WindowInsets
import android.view.WindowInsetsController
import android.view.WindowManager
import android.widget.TextView
import com.amap.api.navi.AmapRouteActivity
import com.amap.api.navi.view.SlidingUpPanelLayout


class AMapFlutterRouteActivity : AmapRouteActivity() {

    private var contentRoot: View? = null
    private var contentRootPadding: Padding? = null
    private var routePanel: View? = null
    private var routeSlidingPanel: SlidingUpPanelLayout? = null
    private var routePanelBaseCollapsedHeight = 0
    private var routePanelBasePadding: Padding? = null
    private var routePanelBottomInset = 0
    private var routePanelLayoutListener: ViewTreeObserver.OnGlobalLayoutListener? = null

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
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            window.isNavigationBarContrastEnforced = false
        }
    }

    private fun applySystemBars() {
        prepareWindowForFullscreen()
        enforceSystemBarVisibility()
        applyContentInsets()
    }

    private fun enforceSystemBarVisibility() {
        val decorView = window.decorView
        val targetFlags = lightSystemBarFlags(window)
        if (decorView.systemUiVisibility != targetFlags) {
            decorView.systemUiVisibility = targetFlags
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.insetsController?.run {
                hide(WindowInsets.Type.statusBars())
                show(WindowInsets.Type.navigationBars())
                systemBarsBehavior =
                    WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
            }
        }
    }

    private fun applyContentInsets() {
        val content = findViewById<View>(android.R.id.content) ?: return
        if (contentRoot !== content) {
            contentRoot?.viewTreeObserver?.let { observer ->
                routePanelLayoutListener?.let { listener ->
                    if (observer.isAlive) {
                        observer.removeOnGlobalLayoutListener(listener)
                    }
                }
            }
            contentRoot = content
            contentRootPadding = Padding(
                left = content.paddingLeft,
                top = 0,
                right = content.paddingRight,
                bottom = content.paddingBottom
            )
            content.setOnApplyWindowInsetsListener { view, insets ->
                applyInsetsPadding(view, insets)
                removeTopAndBottomInsets(insets)
            }
            routePanelLayoutListener = ViewTreeObserver.OnGlobalLayoutListener {
                resizeRoutePanel(content, routePanelBottomInset)
                enforceSystemBarVisibility()
            }.also { listener ->
                content.viewTreeObserver.addOnGlobalLayoutListener(listener)
            }
        }

        content.requestApplyInsets()
        content.post { content.requestApplyInsets() }
    }

    private fun applyInsetsPadding(view: View, insets: WindowInsets) {
        val padding = contentRootPadding ?: return
        val navigationBars = navigationBars(insets)

        // Keep AMap content above the opaque system navigation bar.
        view.setPadding(
            padding.left + navigationBars.left,
            padding.top,
            padding.right + navigationBars.right,
            padding.bottom + navigationBars.bottom
        )

        resizeRoutePanel(view, navigationBars.bottom)
    }

    private fun resizeRoutePanel(content: View, bottomInset: Int) {
        routePanelBottomInset = bottomInset
        val currentPanel = routePanel
        val currentSlidingPanel = routeSlidingPanel
        val (panel, slidingPanel) =
            if (
                currentPanel?.isAttachedToWindow == true &&
                currentSlidingPanel?.isAttachedToWindow == true
            ) {
                currentPanel to currentSlidingPanel
            } else {
                findRoutePanel(content) ?: return
            }

        if (routePanel !== panel || routeSlidingPanel !== slidingPanel) {
            routePanel = panel
            routeSlidingPanel = slidingPanel
            routePanelBaseCollapsedHeight = slidingPanel.panelHeight
            routePanelBasePadding = Padding(
                left = panel.paddingLeft,
                top = panel.paddingTop,
                right = panel.paddingRight,
                bottom = panel.paddingBottom
            )
        }

        if (routePanelBaseCollapsedHeight <= 0) {
            routePanelBaseCollapsedHeight = slidingPanel.panelHeight
        }
        val basePadding = routePanelBasePadding ?: return
        if (routePanelBaseCollapsedHeight <= 0) return

        // The route-planning panel is the collapsed part of AMap's
        // SlidingUpPanelLayout. The drag view itself fills the parent, so
        // changing its LayoutParams height is clipped and has no visible
        // effect. Increase the SDK panel's collapsed height instead.
        val targetHeight = routePanelBaseCollapsedHeight + bottomInset
        if (slidingPanel.panelHeight != targetHeight) {
            slidingPanel.panelHeight = targetHeight
        }

        panel.setPadding(
            basePadding.left,
            basePadding.top,
            basePadding.right,
            basePadding.bottom
        )
    }

    private fun findRoutePanel(content: View): Pair<View, SlidingUpPanelLayout>? {
        findViewByResourceEntryName(content, "navi_sdk_dragView")?.let { panel ->
            findSlidingPanelParent(panel)?.let { slidingPanel ->
                return panel to slidingPanel
            }
        }

        val startButton = findTextView(content, "开始导航") ?: return null
        var child: View = startButton
        var parent = child.parent as? View
        while (parent != null && parent !== content) {
            if (parent is SlidingUpPanelLayout) {
                return child to parent
            }
            child = parent
            parent = parent.parent as? View
        }

        return null
    }

    private fun findSlidingPanelParent(view: View): SlidingUpPanelLayout? {
        var parent = view.parent as? View
        while (parent != null) {
            if (parent is SlidingUpPanelLayout) {
                return parent
            }
            parent = parent.parent as? View
        }

        return null
    }

    private fun findViewByResourceEntryName(view: View, targetName: String): View? {
        if (view.id != View.NO_ID) {
            try {
                if (view.resources.getResourceEntryName(view.id) == targetName) {
                    return view
                }
            } catch (_: android.content.res.Resources.NotFoundException) {
                // AMap loads part of its UI from a private resource package.
            }
        }

        if (view is ViewGroup) {
            for (index in 0 until view.childCount) {
                findViewByResourceEntryName(view.getChildAt(index), targetName)?.let {
                    return it
                }
            }
        }

        return null
    }

    private fun findTextView(view: View, targetText: String): TextView? {
        if (view is TextView && view.text?.toString() == targetText) {
            return view
        }

        if (view is ViewGroup) {
            for (index in 0 until view.childCount) {
                findTextView(view.getChildAt(index), targetText)?.let {
                    return it
                }
            }
        }

        return null
    }

    @Suppress("DEPRECATION")
    private fun removeTopAndBottomInsets(insets: WindowInsets): WindowInsets {
        // AMap handles the insets dispatched to its own view hierarchy. Remove
        // the top and bottom values so it does not reserve system-bar bands.
        return when {
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.R -> {
                val topInsets =
                    WindowInsets.Type.statusBars() or WindowInsets.Type.displayCutout()
                val navigationBars = insets.getInsets(WindowInsets.Type.navigationBars())
                val navigationBarsIgnoringVisibility =
                    insets.getInsetsIgnoringVisibility(WindowInsets.Type.navigationBars())
                WindowInsets.Builder(insets)
                    .setInsets(topInsets, Insets.NONE)
                    .setInsetsIgnoringVisibility(topInsets, Insets.NONE)
                    .setInsets(
                        WindowInsets.Type.navigationBars(),
                        Insets.of(navigationBars.left, 0, navigationBars.right, 0)
                    )
                    .setInsetsIgnoringVisibility(
                        WindowInsets.Type.navigationBars(),
                        Insets.of(
                            navigationBarsIgnoringVisibility.left,
                            0,
                            navigationBarsIgnoringVisibility.right,
                            0
                        )
                    )
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
                            0
                        )
                    )
                    .setStableInsets(
                        Insets.of(
                            insets.stableInsetLeft,
                            0,
                            insets.stableInsetRight,
                            0
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
                    0
                ).consumeDisplayCutout()
            }

            else -> {
                insets.replaceSystemWindowInsets(
                    insets.systemWindowInsetLeft,
                    0,
                    insets.systemWindowInsetRight,
                    0
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


