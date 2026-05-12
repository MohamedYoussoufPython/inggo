plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.inggo.vtc"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11)
        }
    }

    // ─── Signing configs ───
    // For Play Store release, create a keystore:
    //   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
    // Then set env vars (or uncomment and fill the block below):
    //   SIGNING_STORE_FILE=upload-keystore.jks
    //   SIGNING_STORE_PASSWORD=...
    //   SIGNING_KEY_ALIAS=upload
    //   SIGNING_KEY_PASSWORD=...
    signingConfigs {
        create("release") {
            val storeFile = System.getenv("SIGNING_STORE_FILE")
            if (storeFile != null) {
                this.storeFile = file(storeFile)
                this.storePassword = System.getenv("SIGNING_STORE_PASSWORD")
                this.keyAlias = System.getenv("SIGNING_KEY_ALIAS")
                this.keyPassword = System.getenv("SIGNING_KEY_PASSWORD")
            }
        }
    }

    defaultConfig {
        applicationId = "com.inggo.vtc"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Google Maps API Key — read from GOOGLE_MAPS_API_KEY env var
        // or from local.properties file. Falls back to empty string.
        val mapsKey = System.getenv("GOOGLE_MAPS_API_KEY")
            ?: (project.findProperty("GOOGLE_MAPS_API_KEY") as? String)
            ?: ""
        manifestPlaceholders["GOOGLE_MAPS_API_KEY"] = mapsKey
    }

    buildTypes {
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
        release {
            // Use release signing when keystore env vars are set,
            // otherwise fall back to debug signing for `flutter run --release`
            val hasReleaseSigning = System.getenv("SIGNING_STORE_FILE") != null
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
