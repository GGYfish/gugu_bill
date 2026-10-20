import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ===== Release 签名凭据读取 =====
// 优先级:android/key.properties > 环境变量 ANDROID_KEYSTORE_* > 留空(降级为 debug 签名)
// key.properties 已被 android/.gitignore 忽略,不会进入仓库。
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        keystorePropertiesFile.inputStream().use { load(it) }
    }
}

fun resolveKeystoreProp(name: String): String {
    return (keystoreProperties[name] as? String)
        ?.takeIf { it.isNotBlank() }
        ?: System.getenv("ANDROID_KEYSTORE_${name.uppercase()}")
        ?.takeIf { it.isNotBlank() }
        ?: ""
}

val storeFilePath = resolveKeystoreProp("storeFile")
val storePassword = resolveKeystoreProp("storePassword")
val keyAlias = resolveKeystoreProp("keyAlias")
val keyPassword = resolveKeystoreProp("keyPassword")

val hasReleaseSigningMaterial =
    storeFilePath.isNotBlank() && storePassword.isNotBlank() &&
        keyAlias.isNotBlank() && keyPassword.isNotBlank()

android {
    namespace = "com.guguyu.gugu_bill"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.guguyu.gugu_bill"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (hasReleaseSigningMaterial) {
                // storeFile 支持相对路径(相对 android/ 目录)
                val sfFile = if (storeFilePath.startsWith("/") ||
                    storeFilePath.contains(":")
                ) {
                    file(storeFilePath)
                } else {
                    rootProject.file(storeFilePath)
                }
                storeFile = sfFile
                this.storePassword = storePassword
                this.keyAlias = keyAlias
                this.keyPassword = keyPassword
            }
            // 无凭据时不报错,buildTypes.release 会自动降级到 debug
        }
    }

    buildTypes {
        debug {
            applicationIdSuffix = ".debug"
            signingConfig = signingConfigs.getByName("debug")
        }
        release {
            // 没有 release 签名凭据时降级到 debug 签名,确保新成员 / CI 至少能出包
            signingConfig = if (hasReleaseSigningMaterial) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

flutter {
    source = "../.."
}
