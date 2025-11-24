package com.mediminder.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

class MedicineReminderReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        Log.d("MedicineReminder", "🔔 MedicineReminderReceiver triggered!")
        
        if (context != null && intent != null) {
            val notificationId = intent.getIntExtra("notification_id", -1)
            val title = intent.getStringExtra("title") ?: "Nhắc nhở uống thuốc"
            val body = intent.getStringExtra("body") ?: ""
            
            Log.d("MedicineReminder", "Notification ID: $notificationId")
            Log.d("MedicineReminder", "Title: $title")
            Log.d("MedicineReminder", "Body: $body")
            
            if (notificationId > 0) {
                // Show notification immediately when triggered
                val notification = NotificationCompat.Builder(context, "medicine_alarm_channel_v6")
                    .setSmallIcon(android.R.drawable.ic_dialog_info)
                    .setContentTitle(title)
                    .setContentText(body)
                    .setPriority(NotificationCompat.PRIORITY_MAX)
                    .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                    .setVibrate(longArrayOf(0, 1000, 500, 1000))
                    .setSound(android.provider.Settings.System.DEFAULT_NOTIFICATION_URI)
                    .build()
                
                NotificationManagerCompat.from(context).notify(notificationId, notification)
                Log.d("MedicineReminder", "✅ Notification shown: ID=$notificationId")
            }
        }
    }
}
