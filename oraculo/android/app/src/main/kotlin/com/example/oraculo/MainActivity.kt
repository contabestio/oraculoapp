package com.example.oraculo

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.oraculo/notifications"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        NotificationHelper.ensureChannel(applicationContext)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "requestPermission" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            val granted = ContextCompat.checkSelfPermission(
                                this,
                                Manifest.permission.POST_NOTIFICATIONS
                            ) == PackageManager.PERMISSION_GRANTED
                            if (!granted) {
                                ActivityCompat.requestPermissions(
                                    this,
                                    arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                                    1001
                                )
                            }
                            result.success(granted)
                        } else {
                            result.success(true)
                        }
                    }
                    "showNotification" -> {
                        val id = call.argument<Int>("id") ?: 1
                        val title = call.argument<String>("title") ?: "Oráculo"
                        val body = call.argument<String>("body") ?: ""
                        val dateKey = call.argument<String>("dateKey")
                        NotificationHelper.showNotification(
                            context = applicationContext,
                            id = id,
                            title = title,
                            body = body,
                            dateKey = dateKey
                        )
                        result.success(true)
                    }
                    "scheduleNotification" -> {
                        val id = call.argument<Int>("id") ?: 1
                        val title = call.argument<String>("title") ?: "Oráculo"
                        val body = call.argument<String>("body") ?: ""
                        val triggerAtMillis = call.argument<Number>("triggerAtMillis")?.toLong() ?: 0L
                        val dateKey = call.argument<String>("dateKey")
                        NotificationHelper.scheduleNotification(
                            context = applicationContext,
                            id = id,
                            title = title,
                            body = body,
                            triggerAtMillis = triggerAtMillis,
                            dateKey = dateKey
                        )
                        result.success(true)
                    }
                    "cancelNotification" -> {
                        val id = call.argument<Int>("id") ?: 1
                        NotificationHelper.cancelNotification(applicationContext, id)
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
