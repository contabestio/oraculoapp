package com.example.oraculo

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class EventAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val id = intent.getIntExtra("id", 0)
        val title = intent.getStringExtra("title") ?: "Lembrete de Evento"
        val body = intent.getStringExtra("body") ?: "Você tem um evento marcado no Oráculo!"
        val dateKey = intent.getStringExtra("dateKey")

        NotificationHelper.showNotification(
            context = context,
            id = id,
            title = title,
            body = body,
            dateKey = dateKey
        )
    }
}
