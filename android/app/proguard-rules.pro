# ==


=============================
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
