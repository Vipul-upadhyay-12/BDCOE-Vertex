package com.example.vertex

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import com.example.vertex.R

class VertexWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.vertex_widget_layout).apply {
                val streak = widgetData.getString("streak_text", "🔥 0 Days") ?: "🔥 0 Days"
                val nextPlatform = widgetData.getString("next_platform", "NEXT") ?: "NEXT"
                val nextName = widgetData.getString("next_name", "No Upcoming Contests") ?: "No Upcoming Contests"
                val nextCountdown = widgetData.getString("next_countdown", "--:--") ?: "--:--"

                val reminderName = widgetData.getString("reminder_name", "No Reminder Scheduled") ?: "No Reminder Scheduled"
                val reminderCountdown = widgetData.getString("reminder_countdown", "") ?: ""

                setTextViewText(R.id.widget_streak, streak)
                setTextViewText(R.id.widget_next_platform, nextPlatform)
                setTextViewText(R.id.widget_next_name, nextName)
                setTextViewText(R.id.widget_next_countdown, nextCountdown)
                setTextViewText(R.id.widget_reminder_name, reminderName)
                setTextViewText(R.id.widget_reminder_countdown, reminderCountdown)

                // Click to open app
                val launchIntent = Intent(context, MainActivity::class.java).apply {
                    action = Intent.ACTION_MAIN
                    addCategory(Intent.CATEGORY_LAUNCHER)
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    0,
                    launchIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}