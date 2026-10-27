# Aturan untuk mencegah R8 (ProGuard) membuang/mengubah class WorkManager dan Room
-keep class androidx.work.** { *; }
-keep class androidx.room.** { *; }
-keep class androidx.sqlite.** { *; }
-keep class androidx.startup.** { *; }

-dontwarn androidx.work.**
-dontwarn androidx.room.**
-dontwarn androidx.sqlite.**

# Aturan untuk Firebase agar komponennya tidak terhapus saat rilis
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class io.flutter.plugins.firebase.** { *; }

-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Flutter Engine, Embedding & ReLinker
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class com.getkeepsafe.relinker.** { *; }
-dontwarn io.flutter.**
-dontwarn com.getkeepsafe.relinker.**
