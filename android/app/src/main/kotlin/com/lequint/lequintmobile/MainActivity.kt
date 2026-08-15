package com.lequint.lequintmobile

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    companion object {
        // Debe coincidir con el meta-data
        // `com.google.firebase.messaging.default_notification_channel_id` en
        // AndroidManifest.xml — ver TASK-012 / SPEC-009.
        const val NOTIFICATION_CHANNEL_ID = "le_quint_high_importance"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannel()
    }

    /**
     * Canal de importancia alta para que las notificaciones push (check-in,
     * check-out, tareas de housekeeping) se muestren con heads-up/sonido en
     * Android 8+. Sin un canal explícito, FCM usa uno de importancia por
     * defecto.
     */
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                NOTIFICATION_CHANNEL_ID,
                "Notificaciones de Le Quint",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Check-ins, check-outs, tareas de housekeeping y alertas del hotel"
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }
}
