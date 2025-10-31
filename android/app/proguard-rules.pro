# ===============================
#  Razorpay SDK ProGuard Rules
# ===============================
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**

# Keep annotations used by Razorpay
-keep class proguard.annotation.** { *; }
-dontwarn proguard.annotation.**

# =================================
#  General Flutter / Firebase Fixes
# =================================
-keepattributes *Annotation*
-dontwarn io.flutter.embedding.**
-keep class io.flutter.embedding.** { *; }

# =================================
#  JavaScript Interface Safety
# =================================
-keepclassmembers class ** {
    @android.webkit.JavascriptInterface <methods>;
}

# Google Maps Flutter Plugin
-keep class io.flutter.plugins.googlemaps.** { *; }
-dontwarn io.flutter.plugins.googlemaps.**
-keep class com.google.android.gms.maps.** { *; }
-keep interface com.google.android.gms.maps.** { *; }
