package com.example.jadwal_kelas

import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import org.json.JSONArray
import org.json.JSONObject

class JadwalKelasWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return JadwalKelasWidgetFactory(this.applicationContext)
    }
}

class JadwalKelasWidgetFactory(private val context: Context) : RemoteViewsService.RemoteViewsFactory {
    
    // Array untuk menampung data JSON jadwal dari Flutter
    private val schedules = mutableListOf<JSONObject>()

    override fun onCreate() {}

    override fun onDataSetChanged() {
        // Method ini dipanggil setiap kali widget diupdate atau notifyAppWidgetViewDataChanged dipanggil
        schedules.clear()
        
        // Membaca penyimpanan JSON (Dengan Fallback Lengkap!)
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
            jsonString = prefs.getString("today_schedule_json", null)
        }
        
        if (!jsonString.isNullOrEmpty()) {
            try {
                val jsonArray = JSONArray(jsonString)
                for (i in 0 until jsonArray.length()) {
                    schedules.add(jsonArray.getJSONObject(i))
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    override fun onDestroy() {
        schedules.clear()
    }

    override fun getCount(): Int = schedules.size

    override fun getViewAt(position: Int): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.jadwal_kelas_widget_item)
        
        if (position < schedules.size) {
            val s = schedules[position]
            
            views.setTextViewText(R.id.item_course_name, s.optString("courseName", "Mata Kuliah"))
            views.setTextViewText(R.id.item_time, s.optString("time", ""))
            
            val room = s.optString("room", "")
            val lecturer = s.optString("lecturer", "")
            
            var roomLecturerInfo = ""
            if (room.isNotEmpty() && lecturer.isNotEmpty()) {
                roomLecturerInfo = "$room  •  $lecturer"
            } else if (room.isNotEmpty()) {
                roomLecturerInfo = room
            } else if (lecturer.isNotEmpty()) {
                roomLecturerInfo = lecturer
            }
            views.setTextViewText(R.id.item_room_lecturer, roomLecturerInfo)
            
            // Warnai background membulat secara proporsional!
            val colorValue = s.optInt("color", Color.parseColor("#D4A853"))
            views.setInt(R.id.item_bg_image, "setColorFilter", colorValue)
            
            // Proses daftar tugas jika ada
            val tasksArray = s.optJSONArray("tasks")
            
            // Definisikan array dari statis View IDs
            val taskIds = arrayOf(
                intArrayOf(R.id.task_title_1, R.id.task_detail_1, R.id.task_divider_1),
                intArrayOf(R.id.task_title_2, R.id.task_detail_2, R.id.task_divider_2),
                intArrayOf(R.id.task_title_3, R.id.task_detail_3, 0) // Tidak ada divider utk yg terkahir dirender (statis)
            )
            
            // Sembunyikan semuanya terlebih dahulu di awal (Reset)
            views.setViewVisibility(R.id.tasks_container, android.view.View.GONE)
            views.setViewVisibility(R.id.item_tasks_header, android.view.View.GONE)
            for (ids in taskIds) {
                views.setViewVisibility(ids[0], android.view.View.GONE)
                views.setViewVisibility(ids[1], android.view.View.GONE)
                if (ids[2] != 0) views.setViewVisibility(ids[2], android.view.View.GONE)
            }

            // Jika ada tugas
            if (tasksArray != null && tasksArray.length() > 0) {
                views.setViewVisibility(R.id.item_tasks_header, android.view.View.VISIBLE)
                views.setViewVisibility(R.id.tasks_container, android.view.View.VISIBLE)
                
                // Max render 3 task pertama untuk mencegah over-layout statis
                val renderCount = Math.min(tasksArray.length(), 3)
                
                for (i in 0 until renderCount) {
                    val t = tasksArray.optJSONObject(i)
                    if (t != null) {
                        val title = t.optString("title", "Tugas")
                        val type = t.optString("type", "Individu")
                        val deadline = t.optString("deadline", "")
                        
                        // Menampilkan Elemen Row Tersebut
                        views.setViewVisibility(taskIds[i][0], android.view.View.VISIBLE)
                        views.setViewVisibility(taskIds[i][1], android.view.View.VISIBLE)
                        
                        // Set nilai text-nya
                        views.setTextViewText(taskIds[i][0], title)
                        views.setTextViewText(taskIds[i][1], "Tugas $type • Dl $deadline")
                        
                        // Menampilkan Divider jika dia bukan tugas terkahir yang di-render
                        if (i < renderCount - 1 && taskIds[i][2] != 0) {
                            views.setViewVisibility(taskIds[i][2], android.view.View.VISIBLE)
                        }
                    }
                }
            }
            
            // Berikan izin item ini bisa diklik agar membuka aplikasi (PendingIntentTemplate di class Widget)
            val fillInIntent = Intent()
            views.setOnClickFillInIntent(R.id.item_bg_image, fillInIntent)
            views.setOnClickFillInIntent(R.id.item_content, fillInIntent)
        }
        
        return views
    }

    override fun getLoadingView(): RemoteViews? = null
    
    override fun getViewTypeCount(): Int = 1
    
    override fun getItemId(position: Int): Long = position.toLong()
    
    override fun hasStableIds(): Boolean = true
}
