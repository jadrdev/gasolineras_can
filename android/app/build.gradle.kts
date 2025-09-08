import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.gasolineras_can"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // Enable core library desugaring for flutter_local_notifications
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.jadrdev.gasolinera"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Required for flutter_local_notifications
        multiDexEnabled = true
    // Provide MAPS_API_KEY from android/local.properties (preferred) or from project properties
    val localProps = Properties()
        val localPropsFile = rootProject.file("local.properties")
        if (localPropsFile.exists()) {
            localPropsFile.inputStream().use { localProps.load(it) }
        }
        manifestPlaceholders["MAPS_API_KEY"] =
            (localProps.getProperty("MAPS_API_KEY") ?: project.findProperty("MAPS_API_KEY")?.toString()
                ?: "")
    }

    buildTypes {
        release {
            // Load signing configuration from android/key.properties if available
            val keyPropsFile = rootProject.file("android/key.properties")
            if (keyPropsFile.exists()) {
                val keyProps = Properties()
                keyPropsFile.inputStream().use { keyProps.load(it) }
                val storeFile = file(keyProps.getProperty("storeFile"))

                signingConfigs.create("release") {
                    storeFile = if (storeFile.exists()) storeFile else null
                    storePassword = keyProps.getProperty("storePassword")
                    keyAlias = keyProps.getProperty("keyAlias")
                    keyPassword = keyProps.getProperty("keyPassword")
                }
                signingConfig = signingConfigs.getByName("release")
            } else {
                // Fallback to debug signing when no key.properties is present
                signingConfig = signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Core library desugaring for flutter_local_notifications (v2.1.4+ required)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
