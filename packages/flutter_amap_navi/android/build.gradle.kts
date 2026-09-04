group = "com.morbit.amap_flutter_navi"
version = "1.0-SNAPSHOT"

val amapMapSdkModule = "com.amap.api:3dmap-location-search"
val amapNaviSdkCoordinate =
    "com.amap.api:navi-3dmap-location-search:11.2.100_3dmap11.2.100_loc11.2.100_sea9.8.1"

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
    namespace = "com.morbit.amap_flutter_navi"
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
    // 导航 SDK 已包含 3D 地图、定位和搜索，导航包无需再引入独立地图 SDK。
    // 自定义导航 Activity 需要在宿主编译期继承 AmapRouteActivity。
    api(amapNaviSdkCoordinate)

    testImplementation("org.jetbrains.kotlin:kotlin-test")
    testImplementation("org.mockito:mockito-core:5.0.0")
}

// 当宿主同时引入 flutter_amap 与 flutter_amap_navi 时，导航合包已提供全部地图类。
// 在整个 Android 构建中用导航合包替换纯地图合包，避免重复类和两份 native 库。
rootProject.allprojects {
    configurations.configureEach {
        resolutionStrategy.dependencySubstitution {
            substitute(module(amapMapSdkModule))
                .using(module(amapNaviSdkCoordinate))
                .because("AMap navigation SDK already contains 3D map, location and search")
        }
    }
}
