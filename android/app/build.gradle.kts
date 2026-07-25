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
    namespace = "com.jadrdev.gasolinera"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Enable core library desugaring for flutter_local_notifications
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.jadrdev.gasolinera"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Required for flutter_local_notifications
        multiDexEnabled = true

        // Provide MAPS_API_KEY from android/local.properties (preferred)
        val localProps = Properties()
        val localPropsFile = rootProject.file("local.properties")
        if (localPropsFile.exists()) {
            localPropsFile.inputStream().use { localProps.load(it) }
        }
        manifestPlaceholders["MAPS_API_KEY"] =
            (localProps.getProperty("MAPS_API_KEY")
                ?: project.findProperty("MAPS_API_KEY")?.toString()
                ?: "")
    }

    buildTypes {
        release {
            // Algunas configuraciones de macOS fallan al strip de símbolos de
            // librerías nativas. Desactivamos el strip para evitar el error.
            isDebuggable = false
            isMinifyEnabled = true
            isShrinkResources = true
            ndk {
                debugSymbolLevel = "none"
            }

            packagingOptions {
                jniLibs {
                    keepDebugSymbols += "**/*.so"
                }
            }

            // Load signing configuration from key.properties if available
            val keyPropsFile = rootProject.file("key.properties")
            if (keyPropsFile.exists()) {
                val keyProps = Properties()
                keyPropsFile.inputStream().use { keyProps.load(it) }
                val storeFilePath = keyProps.getProperty("storeFile")
                val keystoreFile = file(storeFilePath)

                if (keystoreFile.exists()) {
                    signingConfigs.create("release") {
                        storeFile = keystoreFile
                        storePassword = keyProps.getProperty("storePassword")
                        keyAlias = keyProps.getProperty("keyAlias")
                        keyPassword = keyProps.getProperty("keyPassword")
                    }
                    signingConfig = signingConfigs.getByName("release")
                } else {
                    signingConfig = signingConfigs.getByName("debug")
                }
            } else {
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
