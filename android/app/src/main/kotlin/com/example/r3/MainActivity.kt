// android/app/src/main/kotlin/com/example/r3/MainActivity.kt
package com.example.r3

import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.util.*

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.r3.app/usage_stats"
    private lateinit var channel: MethodChannel
    private val handler = Handler(Looper.getMainLooper())
    private var monitoringRunnable: Runnable? = null
    private var appsToMonitor: List<String> = emptyList()
    private var lastForegroundApp: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getInstalledApps" -> {
                    val apps = getInstalledApps()
                    result.success(apps)
                }
                "startMonitoring" -> {
                    val apps = call.argument<List<String>>("appsToMonitor") ?: emptyList()
                    val resultMessage = startMonitoring(apps)
                    result.success(resultMessage)
                }
                "stopMonitoring" -> {
                    stopMonitoring()
                    result.success("STOPPED")
                }
                "checkOverlayPermission" -> {
                    val hasPermission = checkOverlayPermission()
                    result.success(hasPermission)
                }
                "requestOverlayPermission" -> {
                    requestOverlayPermission()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Check if opened from learning activity intent
        if (intent.getBooleanExtra("open_learning", false)) {
            // Navigate to learning screen in Flutter
            Handler(Looper.getMainLooper()).postDelayed({
                channel.invokeMethod("openLearningScreen", null)
            }, 500)
        }
    }

    private fun getInstalledApps(): List<Map<String, Any?>> {
        val packageManager = packageManager
        val apps = mutableListOf<Map<String, Any?>>()
        
        val installedApps = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)
        
        for (app in installedApps) {
            if (app.flags and ApplicationInfo.FLAG_SYSTEM == 0) {
                val appName = packageManager.getApplicationLabel(app).toString()
                val packageName = app.packageName
                val icon = packageManager.getApplicationIcon(app)
                
                apps.add(mapOf(
                    "name" to appName,
                    "packageName" to packageName,
                    "icon" to drawableToByteArray(icon)
                ))
            }
        }
        
        return apps.sortedBy { it["name"] as String }
    }

    private fun drawableToByteArray(drawable: Drawable): ByteArray {
        val bitmap = if (drawable is BitmapDrawable) {
            drawable.bitmap
        } else {
            val bitmap = Bitmap.createBitmap(
                drawable.intrinsicWidth,
                drawable.intrinsicHeight,
                Bitmap.Config.ARGB_8888
            )
            val canvas = Canvas(bitmap)
            drawable.setBounds(0, 0, canvas.width, canvas.height)
            drawable.draw(canvas)
            bitmap
        }
        
        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 80, stream)
        return stream.toByteArray()
    }

    private fun startMonitoring(apps: List<String>): String {
        if (!hasUsageStatsPermission()) {
            requestUsageStatsPermission()
            return "PERMISSION_REQUIRED"
        }
        
        if (!checkOverlayPermission()) {
            return "OVERLAY_PERMISSION_REQUIRED"
        }
        
        appsToMonitor = apps
        
        monitoringRunnable?.let { handler.removeCallbacks(it) }
        
        monitoringRunnable = object : Runnable {
            override fun run() {
                checkForegroundApp()
                handler.postDelayed(this, 2000)
            }
        }
        
        handler.post(monitoringRunnable!!)
        return "MONITORING_STARTED"
    }

    private fun stopMonitoring() {
        monitoringRunnable?.let { handler.removeCallbacks(it) }
        monitoringRunnable = null
    }

    private fun checkForegroundApp() {
        val foregroundApp = getForegroundApp()
        
        if (foregroundApp != lastForegroundApp) {
            lastForegroundApp = foregroundApp
            
            channel.invokeMethod("onForegroundAppUpdate", foregroundApp)
            
            if (foregroundApp != null && appsToMonitor.contains(foregroundApp)) {
                // Show overlay instead of Flutter screen
                showDisruptionOverlay(foregroundApp)
                // Still notify Flutter for logging/analytics
                channel.invokeMethod("onDistraction", foregroundApp)
            }
        }
    }

    private fun showDisruptionOverlay(packageName: String) {
        val appName = getAppName(packageName)
        val intent = Intent(this, OverlayService::class.java).apply {
            action = "SHOW_DISRUPTION"
            putExtra("app_name", appName)
        }
        startService(intent)
    }

    private fun getAppName(packageName: String): String {
        return try {
            val appInfo = packageManager.getApplicationInfo(packageName, 0)
            packageManager.getApplicationLabel(appInfo).toString()
        } catch (e: Exception) {
            "the app"
        }
    }

    private fun getForegroundApp(): String? {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val currentTime = System.currentTimeMillis()
        val stats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_BEST,
            currentTime - 5000,
            currentTime
        )
        
        if (stats.isNotEmpty()) {
            val sortedStats = stats.sortedByDescending { it.lastTimeUsed }
            val mostRecent = sortedStats.firstOrNull()
            
            if (mostRecent != null && mostRecent.lastTimeUsed > currentTime - 5000) {
                return mostRecent.packageName
            }
        }
        
        return null
    }

    private fun hasUsageStatsPermission(): Boolean {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val currentTime = System.currentTimeMillis()
        val stats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            currentTime - 1000 * 60 * 60 * 24,
            currentTime
        )
        return stats.isNotEmpty()
    }

    private fun requestUsageStatsPermission() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        startActivity(intent)
    }

    private fun checkOverlayPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(this)
        } else {
            true
        }
    }

    private fun requestOverlayPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:$packageName")
            )
            startActivity(intent)
        }
    }
}