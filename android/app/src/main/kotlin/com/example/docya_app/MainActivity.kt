package com.example.docya_app

import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Crear canal de notificación para Android 8+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "docya_channel", // ID del canal (coincide con el del Manifest)
                "Notificaciones DocYa", // Nombre visible
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Canal para notificaciones de consultas médicas"
                enableLights(true)
                lightColor = 0xFF14B8A6.toInt() // verde DocYa
                enableVibration(true)
            }

            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }
    }
}
