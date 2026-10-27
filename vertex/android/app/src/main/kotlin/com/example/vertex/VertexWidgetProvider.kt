package com.example.vertex

import android.appwidget.AppWidgetManager
import android.content.Context
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
                val solves = widgetData.getString("solves_text", "0 Solved (24h)") ?: "0 Solved (24h)"
                val contest = widgetData.getString("contest_name", "No Upcoming Alarms") ?: "No Upcoming Alarms"
                val countdown = widgetData.getString("countdown_text", "--:--") ?: "--:--"

                setTextViewText(R.id.widget_streak, streak)
                setTextViewText(R.id.widget_solves, solves)
                setTextViewText(R.id.widget_contest_name, contest)
                setTextViewText(R.id.widget_countdown, countdown)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}