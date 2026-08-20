group = "com.morbit.amap_flutter"
version = "1.0-SNAPSHOT"

buildscript {
    val kotlinVersion = "2.3.20"
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:9.0.1")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

plugins {
    id("com.android.library")
}

android {
    namespace = "com.morbit.amap_flutter"
    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
        getByName("test") {
            java.srcDirs("src/test/kotlin")
        }
    }

    defaultConfig {
        minSdk = 24
        // 将高德 SDK 的混淆规则自动传递给集成方 App（App 开启 R8/ProGuard 时会生效）
        consumerProguardFiles("consumer-rules.pro")
    }

    lint {
        disable.add("InvalidPackage")
    }

    testOptions {
        unitTests {
            all {
                it.useJUnitPlatform()

                it.outputs.upToDateWhen { false }

                it.testLogging {
                    events("passed", "skipped", "failed", "standardOut", "standardError")
                    showStandardStreams = true
                }
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    // 3D地图
//    implementation("com.amap.api:3dmap:9.8.3")
    // 2D地图
//    implementation("com.amap.api:map2d:latest.integration")
    // 导航
//    implementation("com.amap.api:navi-3dmap:latest.integration")
    // 搜索
//    implementation("com.amap.api:search:latest.integration")
    // 定位
//    implementation("com.amap.api:location:latest.integration")

//    implementation("com.amap.api:navi-3dmap-location-search:latest.integration")

//    implementation("com.amap.api:navi-3dmap-location-search:10.0.900_3dmap10.0.1000_loc6.4.8_sea9.7.4")  导航时，二次退出，无法路劲规划
//    implementation("com.amap.api:navi-3dmap-location-search:10.1.500_3dmap10.1.500_loc6.5.0_sea9.7.4")   导航时，二次退出，无法路劲规划
//    implementation("com.amap.api:navi-3dmap-location-search:10.1.600_3dmap10.1.600_loc6.5.1_sea9.7.4")

//    implementation("com.amap.api:navi-3dmap-location-search:11.1.000_3dmap11.1.000_loc11.1.000_sea9.7.4") 打包闪退
//    implementation("com.amap.api:navi-3dmap-location-search:11.1.001_3dmap11.1.001_loc11.1.001_sea9.7.4") 打包闪退
//    implementation("com.amap.api:navi-3dmap-location-search:11.1.200_3dmap11.1.200_loc11.1.200_sea9.7.4")打包闪退

//    implementation("com.amap.api:navi-3dmap-location-search:11.2.000_3dmap11.2.000_loc11.2.000_sea9.8.0") 起点 我的位置无法规划

    implementation("com.amap.api:navi-3dmap-location-search:11.2.100_3dmap11.2.100_loc11.2.100_sea9.8.1")

    testImplementation("org.jetbrains.kotlin:kotlin-test")
    testImplementation("org.mockito:mockito-core:5.0.0")
}
