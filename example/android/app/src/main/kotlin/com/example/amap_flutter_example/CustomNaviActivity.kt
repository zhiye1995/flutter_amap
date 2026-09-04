package com.example.amap_flutter_example

import android.os.Bundle
import android.util.Log
import com.morbit.amap_flutter_navi.AMapFlutterRouteActivity

/**
 * 对应官方 CustomAmapRouteActivity 示例。
 * 间接继承 AmapRouteActivity，保留插件的系统栏及安全区适配。
 * 可在这些生命周期回调中接入宿主业务；导航页面和返回操作仍由 SDK 管理。
 */
class CustomNaviActivity : AMapFlutterRouteActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.i("CustomNaviActivity", "onCreate: 自定义导航容器已启动")
    }

    override fun onResume() {
        super.onResume()
        Log.i("CustomNaviActivity", "onResume")
    }

    override fun onPause() {
        Log.i("CustomNaviActivity", "onPause")
        super.onPause()
    }

    override fun onDestroy() {
        Log.i("CustomNaviActivity", "onDestroy")
        super.onDestroy()
    }
}
