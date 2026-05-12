package com.morbit.amap_flutter

import android.os.Bundle
import android.view.View
import android.view.WindowManager
import androidx.core.view.ViewCompat
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import com.amap.api.navi.AmapRouteActivity


class AMapFlutterRouteActivity : AmapRouteActivity() {

override fun onCreate(savedInstanceState: Bundle?) {
        window.addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)
        WindowCompat.setDecorFitsSystemWindows(window, true)

        super.onCreate(savedInstanceState)

        hideStatusBar()
        applySystemBarInsets()
    }

    override fun onResume() {
        super.onResume()
        window.decorView.post {
            hideStatusBar()
            ViewCompat.requestApplyInsets(window.decorView)
        }
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus) {
            hideStatusBar()
            ViewCompat.requestApplyInsets(window.decorView)
        }
    }

    private fun hideStatusBar() {
        window.addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)

        window.decorView.systemUiVisibility =
            window.decorView.systemUiVisibility or View.SYSTEM_UI_FLAG_FULLSCREEN and
                View.SYSTEM_UI_FLAG_HIDE_NAVIGATION.inv() and
                View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION.inv()

        WindowInsetsControllerCompat(window, window.decorView).hide(WindowInsetsCompat.Type.statusBars())
        WindowInsetsControllerCompat(window, window.decorView).show(WindowInsetsCompat.Type.navigationBars())
    }

    private fun applySystemBarInsets() {
        val contentView = window.decorView.findViewById<View>(android.R.id.content)

        ViewCompat.setOnApplyWindowInsetsListener(window.decorView) { _, insets ->
            val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            val navigationBars = insets.getInsets(WindowInsetsCompat.Type.navigationBars())
            val tappableElement = insets.getInsets(WindowInsetsCompat.Type.tappableElement())
            val bottomInset = maxOf(
                navigationBars.bottom,
                tappableElement.bottom
            )

            contentView.setPadding(systemBars.left, 0, systemBars.right, bottomInset)
            insets
        }

        ViewCompat.requestApplyInsets(window.decorView)
    }
}


