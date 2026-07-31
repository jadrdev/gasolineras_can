# ProGuard/R8 rules for GasoCan release builds
# Keep Flutter embedding classes and generated plugin registrant
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.android.FlutterActivity { *; }
-keep class io.flutter.embedding.android.FlutterFragment { *; }
-keep class io.flutter.embedding.android.FlutterSurfaceView { *; }
-keep class io.flutter.embedding.engine.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.util.** { *; }
-dontwarn io.flutter.embedding.**

# Keep the application entry point
-keep class com.jadrdev.gasolinera.MainActivity { *; }

# Keep generated plugin registrant
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# Keep Application class if you have a custom one (e.g. for Firebase)
-keep class com.jadrdev.gasolinera.** { *; }
-dontwarn com.jadrdev.gasolinera.**

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Firebase Cloud Messaging service
-keep class com.google.firebase.messaging.** { *; }
-keep class com.google.firebase.iid.** { *; }
-keep class com.google.firebase.installations.** { *; }

# Keep FCM token callbacks in Flutter plugin
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# Google Maps
-keep class com.google.android.gms.maps.** { *; }
-keep class com.google.android.libraries.maps.** { *; }
-keep class com.google.maps.** { *; }

# Play Services / Tasks / Auth / Identity
-keep class com.google.android.gms.tasks.** { *; }
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.internal.** { *; }
-dontwarn com.google.android.gms.internal.**

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}
-keepclassmembers class kotlin.Metadata {
    public <methods>;
}
-assumenosideeffects class kotlin.jvm.internal.Intrinsics {
    static void checkParameterIsNotNull(java.lang.Object, java.lang.String);
}

# Kotlin coroutines
-keep class kotlinx.coroutines.** { *; }
-dontwarn kotlinx.coroutines.**
-keepclassmembernames class kotlinx.** {
    volatile <fields>;
}

# Kotlin serialization
-keep class kotlinx.serialization.** { *; }
-keepclassmembers class kotlinx.serialization.json.** { *; }
-dontwarn kotlinx.serialization.**

# Supabase / PostgREST / GoTrue / Realtime
-keep class io.supabase.** { *; }
-keep class com.supabase.** { *; }
-keep class io.github.jan.supabase.** { *; }
-dontwarn io.github.jan.supabase.**

# Drift (SQLite FFI)
-keep class com.squareup.sqldelight.** { *; }
-keep class io.drift.** { *; }
-keep class drift.** { *; }
-dontwarn drift.**

# Shared preferences / SQLite
-keep class android.content.SharedPreferences { *; }

# Geolocator
-keep class com.baseflow.geolocator.** { *; }
-dontwarn com.baseflow.geolocator.**

# Flutter local notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# url_launcher / share / path_provider
-keep class io.flutter.plugins.urllauncher.** { *; }
-keep class io.flutter.plugins.pathprovider.** { *; }
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Google Fonts
-keep class io.flutter.plugins.googlefonts.** { *; }

# Map launcher
-keep class com.example.maplauncher.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Parcelables
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator CREATOR;
}

# Keep serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep attributes needed by reflection
-keepattributes Annotation
-keepattributes Signature
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-keepattributes Deprecated
-keepattributes SourceFile
-keepattributes LineNumberTable
-keepattributes *Annotation*
-keepattributes RuntimeVisibleAnnotations
-keepattributes RuntimeInvisibleAnnotations
-keepattributes RuntimeVisibleParameterAnnotations
-keepattributes RuntimeInvisibleParameterAnnotations

# Remove logging in release
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}

# Flutter specific: keep JSON method channels
-keepclassmembers class * {
    @io.flutter.plugin.common.MethodChannel$MethodCallHandler <methods>;
}
