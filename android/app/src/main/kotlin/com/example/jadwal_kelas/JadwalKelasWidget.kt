package com.example.jadwal_kelas

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import org.json.JSONArray

class JadwalKelasWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.jadwal_kelas_widget)
            
            // Baca JSON string dengan Fallbacks dari berbagai plugin
            var prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            var jsonString = prefs.getString("flutter.widget_today_schedule", null)
            
            if (jsonString.isNullOrEmpty()) {
                prefs = context.getSharedPreferences("group.jadwal_kelas_widget", Context.MODE_PRIVATE)
                jsonString = prefs.getString("today_schedule_json", null)
            }
            if (jsonString.isNullOrEmpty()) {
                prefs = context.getSharedPreferences("${context.packageName}.home_widget", Context.MODE_PRIVATE)
                jsonString = prefs.getString("today_schedule_json", null)
            }
            if (jsonString.isNullOrEmpty()) {
                prefs = context.getSharedPreferences(context.packageName, Context.MODE_PRIVATE)
                jsonString = prefs.getString("today_schedule_json", "[]")
            }
            
            if (jsonString == null) jsonString = "[]"
            
            var isEmpty = true
            try {
                if (jsonString != "[]" && JSONArray(jsonString).length() > 0) {
                    isEmpty = false
                }
            } catch (e: Exception) {}

            if (isEmpty) {
                views.setViewVisibility(R.id.empty_schedule_text, View.VISIBLE)
                views.setViewVisibility(R.id.schedule_list, View.GONE)
            } else {
                views.setViewVisibility(R.id.empty_schedule_text, View.GONE)
                views.setViewVisibility(R.id.schedule_list, View.VISIBLE)
            }

            // Bind ListView ke Service
            val serviceIntent = Intent(context, JadwalKelasWidgetService::class.java).apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
            }
            views.setRemoteAdapter(R.id.schedule_list, serviceIntent)

            // Intent membuka aplikasi
            val appIntent = Intent(context, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                context, 0, appIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            
            views.setOnClickPendingIntent(R.id.widget_open_app, pendingIntent)
            views.setOnClickPendingIntent(R.id.empty_schedule_text, pendingIntent)
            views.setPendingIntentTemplate(R.id.schedule_list, pendingIntent)
            
            // Perbarui widget
            appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.schedule_list)
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
