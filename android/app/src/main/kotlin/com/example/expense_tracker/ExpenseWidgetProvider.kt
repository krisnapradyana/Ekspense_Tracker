package com.example.expense_tracker

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class ExpenseWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.expense_widget_layout).apply {
                // Get data from SharedPreferences (set by home_widget in Flutter)
                val amount = widgetData.getString("remaining_budget", "Rp 0") ?: "Rp 0"
                setTextViewText(R.id.widget_amount, amount)
                
                // Deep link to add expense
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("expensetracker://add")
                )
                setOnClickPendingIntent(R.id.widget_button, pendingIntent)
                setOnClickPendingIntent(R.id.widget_root, pendingIntent)
                
                // Set update time
                val currentTime = java.text.SimpleDateFormat("HH:mm", java.util.Locale.getDefault()).format(java.util.Date())
                setTextViewText(R.id.widget_status, "Terakhir update: $currentTime")
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
