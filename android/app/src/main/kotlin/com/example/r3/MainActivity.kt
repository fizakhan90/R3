package com.example.r3

import android.app.AppOpsManager
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.Drawable
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import android.app.usage.UsageStatsManager

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "com.r3.app/usage_stats"
    private val handler = Handler(Looper.getMainLooper())
    private var monitoringRunnable: Runnable? = null // It's a nullable type
    private var distractingApps = setOf<String>()
    private var lastForegroundApp: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startMonitoring" -> {
                    val appPackages = call.argument<List<String>>("appsToMonitor")
                    if (appPackages != null) {
                        distractingApps = appPackages.toSet()
                    }

                    if (!hasUsageStatsPermission()) {
                        result.success("PERMISSION_DENIED")
                        startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                    } else {
                        startMonitoring(flutterEngine)
                        result.success("STARTED_SUCCESSFULLY")
                    }
                }
                "getInstalledApps" -> result.success(getInstalledApps())
                else -> result.notImplemented()
            }
        }
    }

    private fun startMonitoring(flutterEngine: FlutterEngine) {
        monitoringRunnable?.let { handler.removeCallbacks(it) }
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        
        monitoringRunnable = Runnable {
            val currentTime = System.currentTimeMillis()
            val stats = usageStatsManager.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, currentTime - 1000 * 5, currentTime)
            
            val foregroundApp = stats?.filter { it.lastTimeUsed > currentTime - 1000 * 5 }
                                     ?.maxByOrNull { it.lastTimeUsed }
                                     ?.packageName
            
            if (foregroundApp != null && foregroundApp != lastForegroundApp) {
                lastForegroundApp = foregroundApp
                if (distractingApps.contains(foregroundApp)) {
                    // Stop monitoring temporarily to avoid loops
                    monitoringRunnable?.let { handler.removeCallbacks(it) }
                    // Send signal to Flutter
                    flutterEngine.dartExecutor.binaryMessenger.let {
                        MethodChannel(it, CHANNEL).invokeMethod("onDistraction", foregroundApp)
                    }
                } else {
                    monitoringRunnable?.let { r -> handler.postDelayed(r, 2000) }
                }
            } else {
                monitoringRunnable?.let { r -> handler.postDelayed(r, 2000) }
            }
        }
        // --- THIS IS THE FIX ---
        // The !! asserts that monitoringRunnable is not null at this point,
        // which is true because we just assigned it above.
        handler.post(monitoringRunnable!!) 
    }
    
    private fun hasUsageStatsPermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, android.os.Process.myUid(), packageName)
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun getInstalledApps(): List<Map<String, Any?>> {
        val pm = packageManager
        val mainIntent = Intent(Intent.ACTION_MAIN, null)
        mainIntent.addCategory(Intent.CATEGORY_LAUNCHER)
        val resolvableApps = pm.queryIntentActivities(mainIntent, 0)
        val launcherPackage = pm.resolveActivity(mainIntent, 0)?.activityInfo?.packageName
        val appList = mutableListOf<Map<String, Any?>>()
        for (info in resolvableApps) {
            val app = info.activityInfo.applicationInfo
            if (app.packageName != packageName && app.packageName != launcherPackage) {
                val appInfo = mapOf(
                    "name" to app.loadLabel(pm).toString(),
                    "packageName" to app.packageName,
                    "icon" to drawableToByteArray(app.loadIcon(pm))
                )
                appList.add(appInfo)
            }
        }
        return appList
    }

    private fun drawableToByteArray(drawable: Drawable?): ByteArray? {
        if (drawable == null) return null
        val width = if (drawable.intrinsicWidth > 0) drawable.intrinsicWidth else 96
        val height = if (drawable.intrinsicHeight > 0) drawable.intrinsicHeight else 96
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        drawable.setBounds(0, 0, canvas.width, canvas.height)
        drawable.draw(canvas)
        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
        return stream.toByteArray()
    }
}