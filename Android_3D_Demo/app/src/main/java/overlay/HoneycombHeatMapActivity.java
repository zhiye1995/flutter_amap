package com.amap.map3d.demo.overlay;

import android.app.Activity;
import android.content.Context;
import android.content.res.AssetManager;
import android.graphics.Color;
import android.os.Bundle;
import android.widget.TextView;

import com.amap.api.maps.AMap;
import com.amap.api.maps.CameraUpdateFactory;
import com.amap.api.maps.MapView;
import com.amap.api.maps.model.Gradient;
import com.amap.api.maps.model.HeatMapLayerOptions;
import com.amap.api.maps.model.LatLng;
import com.amap.api.maps.model.WeightedLatLng;
import com.amap.map3d.demo.R;

import java.io.IOException;
import java.io.InputStream;
import java.util.Arrays;


public class HoneycombHeatMapActivity extends Activity {

    private MapView mMapView ;
    private AMap mMap;
    private TextView heatItemTv = null;
    private com.amap.api.maps.model.HeatMapLayer heatMapLayer = null;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_heatmap_overlay);

        mMapView = findViewById(R.id.mapview);
        mMapView.onCreate(savedInstanceState);

        heatItemTv = findViewById(R.id.heat_item_tv);

        mMap = mMapView.getMap();


        mMap.setOnMapLoadedListener(new AMap.OnMapLoadedListener() {
            @Override
            public void onMapLoaded() {
                testHeatMapOverlay();
            }
        });


    }


    private void testHeatMapOverlay() {

        // 因为数据都在青岛附近，将地图中心点移动到青岛
        mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(36.673927,119.996751), 8.5f));

        String heatMapStr = new String(readFileContentsFromAssets(this, "heatmap/heatmap_honey.data"));
        String[] heatMapStrs = heatMapStr.split("\n");

        WeightedLatLng[] weightlatlngs = new WeightedLatLng[heatMapStrs.length];
        int index = 0;
        for (String str : heatMapStrs) {
            String[] dataItem = str.split(",");
            if (dataItem != null && dataItem.length == 3) {
				weightlatlngs[index] = new WeightedLatLng(new LatLng(Double.parseDouble(dataItem[1]), Double.parseDouble(dataItem[0])), Double.parseDouble(dataItem[2]));
            } else {
                android.util.Log.e("mapcore","read file failed");
            }
            index++;
        }

        int[] colors = {
                Color.parseColor("#ecda9a"),
                Color.parseColor("#efc47e"),
                Color.parseColor("#f3ad6a"),
                Color.parseColor("#f7945d"),
                Color.parseColor("#f97b57"),
                Color.parseColor("#f66356"),
                Color.parseColor("#ee4d5a")};
        float[] startPoints = new float[colors.length];
        for(int i =0 ;i < startPoints.length; i ++) {
            startPoints[i] = i * 1.0f / startPoints.length ;
        }


		HeatMapLayerOptions heatMapLayerOptions = new HeatMapLayerOptions();

        // 带权重的经纬度
		heatMapLayerOptions.weightedData(Arrays.asList(weightlatlngs));

		// 指定颜色和颜色变化索引
		Gradient gradient = new Gradient(colors, startPoints);
		heatMapLayerOptions.gradient(gradient);

		// 大小和间隔
		heatMapLayerOptions.size(6000);
        heatMapLayerOptions.gap(300);

        // 最大最小缩放级别
        heatMapLayerOptions.minZoom(5);
        heatMapLayerOptions.maxZoom(19);

        // 整个覆盖物的透明度
        heatMapLayerOptions.opacity(0.85f);

        // 热力图类型为蜂窝
        heatMapLayerOptions.type(HeatMapLayerOptions.TYPE_HEXAGON);

        // 控制在底图文字的上面，默认底图文字级别是0
        heatMapLayerOptions.zIndex(1);

		heatMapLayer = mMap.addHeatMapLayer(heatMapLayerOptions);

		// 获取指定位置的热力情况
        mMap.setOnMapClickListener(new AMap.OnMapClickListener() {

            @Override
            public void onMapClick(LatLng latLng) {
                if (heatMapLayer != null && mMap != null && latLng != null) {
                    com.amap.api.maps.model.HeatMapItem item = heatMapLayer.getHeatMapItem(latLng);
                    if (item != null) {
                        StringBuffer stringBuffer = new StringBuffer();
                        stringBuffer.append("热力中心：").append(item.getCenter()).append("\n");
                        stringBuffer.append("热力值：").append(item.getIntensity()).append("\n");
                        String indexes = "";
                        for(Integer integer : item.getIndexes()) {
                            indexes += integer + ",";
                        }
                        stringBuffer.append("热力索引：").append(indexes).append("\n");
                        stringBuffer.append("数据数量：").append(item.getIndexes().length);
                        updateHeatItemTv(stringBuffer.toString());
                    } else {
                        updateHeatItemTv("未找到热力信息");
                    }


                }
            }

		});

    }

    private void updateHeatItemTv(final String text) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if(heatItemTv != null && text != null) {
                    heatItemTv.setText(text);
                }
            }
        });
    }


    public static byte[] readFileContentsFromAssets(Context context, String assetsPath) {
        AssetManager assetManager = context.getAssets();
        InputStream is = null;
        try {
            String path = assetsPath;
            is = assetManager.open(path);
            int count = is.available();
            if (count == 0) {
                return null;
            }

            byte[] bufferByte = new byte[count];
            // 已经成功读取的字节的个数
            int readCount = 0;
            while (readCount < count) {
                readCount += is.read(bufferByte, readCount, count - readCount);
            }

            is.close();
            return bufferByte;
        } catch (IOException e) {
            return null;
        } catch (OutOfMemoryError e) {
            return null;
        }

    }


    @Override
    protected void onResume() {
        super.onResume();
        if (mMapView != null) {
            mMapView.onResume();
        }
    }

    @Override
    protected void onPause() {
        if (mMapView != null) {
            mMapView.onPause();
        }
        super.onPause();
    }

    @Override
    protected void onDestroy() {
        if (mMapView != null) {
            mMapView.onDestroy();
        }
        super.onDestroy();
    }
}
