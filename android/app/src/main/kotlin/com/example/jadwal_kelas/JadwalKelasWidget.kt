package com.example.jadwal_kelas

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews

/**
 * Android Home Screen Widget untuk Jadwal Kuliah
 *
 * Menggunakan AppWidgetProvider biasa (bukan HomeWidgetProvider) agar
 * lebih kompatibel dengan MIUI/HyperOS (Redmi/Xiaomi).
 *
 * home_widget Flutter plugin menyimpan data di SharedPreferences.
 * Kita baca langsung dari SharedPreferences tanpa dependency ke HomeWidgetPlugin.
 */
class JadwalKelasWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            // home_widget menyimpan data di salah satu dari dua nama ini.
            // Coba keduanya agar kompatibel dengan berbagai versi.
            val todaySchedule = readScheduleData(context) ?: "Buka aplikasi untuk melihat jadwal"

            val views = RemoteViews(context.packageName, R.layout.jadwal_kelas_widget)
            views.setTextViewText(R.id.today_schedule, todaySchedule)
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private fun readScheduleData(context: Context): String? {
            // Coba SharedPreferences name: packageName + ".home_widget"
            val prefs1 = context.getSharedPreferences(
                "${context.packageName}.home_widget", Context.MODE_PRIVATE
            )
            val data1 = prefs1.getString("today_schedule", null)
            if (!data1.isNullOrEmpty()) return data1

            // Fallback: packageName saja (digunakan saat setAppGroupId dipanggil)
            val prefs2 = context.getSharedPreferences(
                context.packageName, Context.MODE_PRIVATE
            )
            val data2 = prefs2.getString("today_schedule", null)
            if (!data2.isNullOrEmpty()) return data2

            // Fallback: FlutterSharedPreferences (beberapa versi lama)
            val prefs3 = context.getSharedPreferences(
                "FlutterSharedPreferences", Context.MODE_PRIVATE
            )
            return prefs3.getString("flutter.today_schedule", null)
        }
    }
}
