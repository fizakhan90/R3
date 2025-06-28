// android/app/src/main/kotlin/com/example/r3/OverlayService.kt
package com.example.r3

import android.app.Service
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.view.*
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.content.ContextCompat

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
            "HIDE_DISRUPTION" -> {
                hideDisruptionOverlay()
            }
        }
        return START_NOT_STICKY
    }

    private fun showDisruptionOverlay(appName: String) {
        if (overlayView != null) return // Already showing

        // Create the overlay layout
        overlayView = createOverlayView(appName)

        val layoutParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            } else {
                @Suppress("DEPRECATION")
                WindowManager.LayoutParams.TYPE_PHONE
            },
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                    WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED,
            PixelFormat.TRANSLUCENT
        )

        layoutParams.gravity = Gravity.CENTER

        try {
            windowManager?.addView(overlayView, layoutParams)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun createOverlayView(appName: String): View {
        val context = this
        
        // Create main container
        val container = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(80, 0, 80, 0)
            gravity = Gravity.CENTER
            setBackgroundColor(ContextCompat.getColor(context, android.R.color.black))
            alpha = 0.95f
        }

        // Title
        val title = TextView(context).apply {
            text = "A Mindful Pause"
            textSize = 28f
            setTextColor(ContextCompat.getColor(context, android.R.color.white))
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, 40)
            setTypeface(null, android.graphics.Typeface.BOLD)
        }

        // Subtitle
        val subtitle = TextView(context).apply {
            text = "You've opened $appName. Choose a better reward."
            textSize = 16f
            setTextColor(ContextCompat.getColor(context, android.R.color.white))
            gravity = Gravity.CENTER
            alpha = 0.7f
            setPadding(0, 0, 0, 80)
        }

        // Learn button
        val learnButton = Button(context).apply {
            text = "🧠 Learn Something New"
            textSize = 16f
            setTextColor(ContextCompat.getColor(context, android.R.color.white))
            setBackgroundColor(ContextCompat.getColor(context, android.R.color.holo_purple))
            setPadding(40, 30, 40, 30)
            
            setOnClickListener {
                // Open your learning activity and close overlay
                openLearningActivity()
                hideDisruptionOverlay()
            }
        }

        // Continue button
        val continueButton = Button(context).apply {
            text = "Continue to app anyway"
            textSize = 14f
            setTextColor(ContextCompat.getColor(context, android.R.color.white))
            background = null
            alpha = 0.6f
            setPadding(0, 40, 0, 0)
            
            setOnClickListener {
                hideDisruptionOverlay()
            }
        }

        // Add all views to container
        container.addView(title)
        container.addView(subtitle)
        container.addView(learnButton)
        container.addView(continueButton)

        return container
    }

    private fun openLearningActivity() {
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("open_learning", true)
        }
        startActivity(intent)
    }

    private fun hideDisruptionOverlay() {
        overlayView?.let {
            try {
                windowManager?.removeView(it)
            } catch (e: Exception) {
                e.printStackTrace()
            }
            overlayView = null
        }
        stopSelf()
    }

    override fun onDestroy() {
        hideDisruptionOverlay()
        super.onDestroy()
    }
}