# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Google Maps
-keep class com.google.android.gms.maps.** { *; }
-keep interface com.google.android.gms.maps.** { *; }
-keep class com.google.android.gms.common.** { *; }

# Awesome Notifications
-keep class me.carda.awesome_notifications.** { *; }

# Flutter Secure Storage
-keep class property.storage.** { *; }

# WebView
-keep class android.webkit.** { *; }

# Models / Data classes
# Since you use Dio/Http, keep your data models from being obfuscated if they use reflection
-keep class com.wavee.community.models.** { *; }

# Prevent obfuscation of native methods
-keepclasseswithmembernames class * {
    native <methods>;
}
