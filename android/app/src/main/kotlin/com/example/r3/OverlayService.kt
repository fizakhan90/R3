package com.example.r3

import android.app.Service
import android.content.Context
import android.content.Intent
import android.app.usage.UsageStatsManager
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.view.*
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.content.ContextCompat
import java.time.Duration

class OverlayService : Service() {
    private var windowManager: WindowManager? = null
    private var overlayView: View? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            "SHOW_DISRUPTION" -> {
                val appName = intent.getStringExtra("app_name") ?: "a distracting app"
                showDisruptionOverlay(appName)
            }
            "HIDE_DISRUPTION" -> hideDisruptionOverlay()
        }
        return START_NOT_STICKY
    }

    private fun showDisruptionOverlay(appName: String) {
        if (overlayView != null) return

        val minutes = getTodayScreenTimeMinutes()
        overlayView = createOverlayView(appName, minutes)

        val layoutParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                @Suppress("DEPRECATION")
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                    WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.CENTER
        }

        try {
            windowManager?.addView(overlayView, layoutParams)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun getTodayScreenTimeMinutes(): Long {
        val usm = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val now = System.currentTimeMillis()
        val start = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
            now - Duration.ofDays(1).toMillis()
        else
            now - 24L * 60 * 60 * 1000

        val stats = usm.queryAndAggregateUsageStats(start, now)
        val totalMs = stats.values.sumOf { it.totalTimeInForeground }
        return totalMs / 1000 / 60
    }

    private fun createOverlayView(appName: String, minutes: Long): View {
        val ctx = this
        val container = LinearLayout(ctx).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(80, 0, 80, 0)
            gravity = Gravity.CENTER
            setBackgroundColor(ContextCompat.getColor(ctx, android.R.color.black))
            alpha = 0.95f
        }

        val title = TextView(ctx).apply {
            text = "A Mindful Pause"
            textSize = 28f
            setTextColor(ContextCompat.getColor(ctx, android.R.color.white))
            gravity = Gravity.CENTER
            setTypeface(null, android.graphics.Typeface.BOLD)
            setPadding(0, 0, 0, 40)
        }

        val subtitle = TextView(ctx).apply {
            text = "You’ve opened $appName. Would you like to pause a moment?"
            textSize = 16f
            setTextColor(ContextCompat.getColor(ctx, android.R.color.white))
            gravity = Gravity.CENTER
            alpha = 0.7f
            setPadding(0, 0, 0, 20)
        }

        val usageInfo = TextView(ctx).apply {
            text = "🎯 Screen time today: $minutes min"
            textSize = 18f
            setTextColor(ContextCompat.getColor(ctx, android.R.color.white))
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, 20)
        }

        val mentalImpact = TextView(ctx).apply {
            text = "Studies show excessive screen use is linked to anxiety, depression, and poor sleep. Take a break for your well-being."
            textSize = 14f
            setTextColor(ContextCompat.getColor(ctx, android.R.color.white))
            gravity = Gravity.CENTER
            alpha = 0.7f
            setPadding(0, 0, 0, 60)
        }

        val learnButton = Button(ctx).apply {
            text = "🌿 Take a Mindful Break"
            textSize = 16f
            setTextColor(ContextCompat.getColor(ctx, android.R.color.white))
            setBackgroundColor(ContextCompat.getColor(ctx, android.R.color.holo_green_dark))
            setPadding(40, 30, 40, 30)
            setOnClickListener {
                openMindfulBreak() // ← Launch like before
                hideDisruptionOverlay()
            }
        }

        val continueBtn = Button(ctx).apply {
            text = "Continue anyway"
            textSize = 14f
            setTextColor(ContextCompat.getColor(ctx, android.R.color.white))
            background = null
            alpha = 0.6f
            setPadding(0, 40, 0, 0)
            setOnClickListener { hideDisruptionOverlay() }
        }

        return container.apply {
            addView(title)
            addView(subtitle)
            addView(usageInfo)
            addView(mentalImpact)
            addView(learnButton)
            addView(continueBtn)
        }
    }

    private fun openMindfulBreak() {
        // 🧠 Reuse the existing "open_learning" intent to navigate inside Flutter
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("open_learning", true)
        }
        startActivity(intent)
    }

    private fun hideDisruptionOverlay() {
        overlayView?.let {
            try { windowManager?.removeView(it) }
            catch (e: Exception) { e.printStackTrace() }
            overlayView = null
        }
        stopSelf()
    }

    override fun onDestroy() {
        hideDisruptionOverlay()
        super.onDestroy()
    }
}
