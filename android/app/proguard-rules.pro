# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.engine.plugins.** { *; }

# 保留所有 JNI 相关
-keepclasseswithmembernames class * {
    native <methods>;
}

# 保留 MainActivity 和所有 Android Channel 组件（精确包名，防止 R8 误删）
-keep public class com.guguyu.gugu_bill.MainActivity { *; }
-keep public class com.guguyu.gugu_bill.BootReceiver { *; }
-keep public class com.guguyu.gugu_bill.BillAccessibilityService { *; }
-keep public class com.guguyu.gugu_bill.MethodChannelWrapper { *; }
-keep public class com.guguyu.gugu_bill.AccessibilityEventChannel { *; }

# 保留所有枚举
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# 保留 Parcelable
-keepclassmembers class * implements android.os.Parcelable {
    public static final ** CREATOR;
}

# 保留 Serializable
-keepnames class * implements java.io.Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    !private <fields>;
    !private <methods>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Drift 数据库（使用代码生成）
-keep class com.guguyu.gugu_bill.** { *; }
-keep class **$Companion { *; }
-keep class * extends androidx.room.RoomDatabase { *; }
-keep class * extends androidx.sqlite.db.SupportSQLiteOpenHelper { *; }
-keep class * extends androidx.sqlite.db.SupportSQLiteOpenHelper$Factory { *; }
-dontwarn org.bouncycastle.**
-dontwarn org.conscrypt.**
-dontwarn org.openjsse.**

# 保留所有 Drift 生成的代码
-keep class **.drift.** { *; }
-keep class **.Drift* { *; }
-keep class **$Drift* { *; }

# 保留所有 build_runner 生成的代码
-keep class **_generated { *; }
-keep class **.generated.** { *; }

# Provider
-keep class provider.** { *; }

# Dio 网络库
-keep class dio.** { *; }
-dontwarn dio.**

# JSON 序列化字段
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Plugin: path_provider
-keep class io.flutter.plugins.pathprovider.** { *; }

# Plugin: shared_preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Plugin: connectivity_plus
-keep class dev.fluttercommunity.plus.connectivity.** { *; }

# Plugin: permission_handler
-keep class com.baseflow.permissionhandler.** { *; }

# sqlite3_flutter_libs
-keep class com.tekartik.sqflite.** { *; }
-dontwarn com.tekartik.sqflite.**

# fl_chart
-keep class fl_chart.** { *; }
-dontwarn fl_chart.**

# 保留 Kotlin metadata
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**

# Google Play Core (Flutter deferred components, not used)
-dontwarn com.google.android.play.**
-keep class com.google.android.play.** { *; }

# 协程
-keepclassmembernames class kotlinx.** {
    volatile <fields>;
}

# 反射相关 - Provider/Drift 大量使用
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-keepattributes SourceFile,LineNumberTable

# 保留自定义 Application 类
-keep public class * extends android.app.Application

# 保留 MainActivity
-keep public class * extends io.flutter.embedding.android.FlutterActivity
-keep public class * extends io.flutter.embedding.android.FlutterFragmentActivity

# Android Channel 自定义 Service 和 Receiver
-keep public class * extends android.content.BroadcastReceiver { *; }
-keep public class * extends android.app.Service { *; }
-keep public class * extends android.accessibilityservice.AccessibilityService { *; }

# 移除日志（减小体积）
-assumenosideeffects class android.util.Log {
    public static *** v(...);
    public static *** d(...);
    public static *** i(...);
}
