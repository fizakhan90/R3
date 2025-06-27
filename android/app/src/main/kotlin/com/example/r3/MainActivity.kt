package com.example.r3 // Or your package name

import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.Drawable
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.r3.app/usage_stats"
    private val handler = Handler(Looper.getMainLooper())
    private lateinit var runnable: Runnable
    private var distractingApps = setOf<String>()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "startMonitoring" -> {
                    val appPackages = call.argument<List<String>>("appsToMonitor")
                    if (appPackages != null) {
                        distractingApps = appPackages.toSet()
                    }
                    if (!hasUsageStatsPermission()) {
                        startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                        result.error("PERMISSION_DENIED", "Usage stats permission is not granted.", null)
                    } else {
                        startMonitoring(flutterEngine)
                        result.success(true)
                    }
                }
                "stopMonitoring" -> {
                    stopMonitoring()
                    result.success(true)
                }
                "getInstalledApps" -> {
                    result.success(getInstalledApps())
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun hasUsageStatsPermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, android.os.Process.myUid(), packageName)
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun startMonitoring(flutterEngine: FlutterEngine) {
        stopMonitoring()
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        runnable = Runnable {
            val time = System.currentTimeMillis()
            val stats = usageStatsManager.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, time - 1000 * 5, time)
            if (stats != null && stats.isNotEmpty()) {
                val sortedStats = stats.sortedByDescending { it.lastTimeUsed }
                val foregroundApp = sortedStats.firstOrNull()?.packageName
                if (foregroundApp != null && distractingApps.contains(foregroundApp)) {
                    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("onDistraction", foregroundApp)
                    stopMonitoring()
                } else {
                    handler.postDelayed(runnable, 1000)
                }
            } else {
                 handler.postDelayed(runnable, 1000)
            }
        }
        handler.post(runnable)
    }

    private fun stopMonitoring() {
        if (::runnable.isInitialized) {
            handler.removeCallbacks(runnable)
        }
    }

    private fun getInstalledApps(): List<Map<String, Any?>> {
        val pm = packageManager
        val apps = pm.getInstalledApplications(0)
        val appList = mutableListOf<Map<String, Any?>>()
        for (app in apps) {
            if (pm.getLaunchIntentForPackage(app.packageName) != null && app.packageName != packageName) {
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