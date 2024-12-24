# Keep AndroidGesturesManager and related classes
-keep class com.mapbox.android.gestures.** { *; }
-keep class org.maplibre.** { *; }

# Keep MapLibre and Mapbox SDK classes for gestures and annotations
-keep class com.mapbox.android.gestures.** { *; }
-keep class org.maplibre.android.** { *; }
-keep class com.mapbox.geojson.** { *; }

# Keep classes for MapLibre annotations and plugins
-keep class org.maplibre.maplibregl.** { *; }
-keep class org.maplibre.geojson.** { *; }
-keep class com.mapbox.** { *; }
#-keep class com.mapbox.android.gestures.MoveGestureDetector { *; }



-dontwarn com.mapbox.android.gestures.AndroidGesturesManager
-dontwarn com.mapbox.android.gestures.MoveGestureDetector$OnMoveGestureListener