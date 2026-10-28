# Prevent R8 from obfuscating Room & WorkManager internal classes
-keep class androidx.work.** { *; }
-keep class androidx.work.impl.** { *; }
-keep class androidx.work.impl.WorkDatabase { *; }
-keep class * extends androidx.work.impl.WorkDatabase { *; }
-keep class androidx.room.** { *; }
-keep class * extends androidx.room.RoomDatabase { *; }

# Keep Flutter plugin receivers & services
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class es.antonborri.home_widget.** { *; }
-keep class com.example.vertex.VertexWidgetProvider { *; }

# Don't warn on missing optional references
-dontwarn androidx.work.**
-dontwarn androidx.room.**