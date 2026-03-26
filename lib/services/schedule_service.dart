import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/schedule.dart';
import '../models/task.dart';

/// Service untuk operasi CRUD jadwal kuliah menggunakan Hive
class ScheduleService {
  static const String _boxName = 'schedules';
  static const String _taskBoxName = 'tasks';
  static const String _widgetName = 'JadwalKelasWidget';

  late Box<Schedule> _box;
  late Box<Task> _taskBox;
  final _uuid = const Uuid();

  /// Inisialisasi Hive box - dipanggil saat app start
  Future<void> init() async {
    _box = await Hive.openBox<Schedule>(_boxName);
    _taskBox = await Hive.openBox<Task>(_taskBoxName);
    // PASTIKAN setAppGroupId sebelum operasi widget
    await HomeWidget.setAppGroupId('group.jadwal_kelas_widget');
    // Update widget saat app dibuka
    await _updateWidget();
  }

  /// Ambil semua jadwal, diurutkan berdasarkan hari dan jam
  List<Schedule> getAllSchedules() {
    final schedules = _box.values.toList();
    schedules.sort((a, b) {
      if (a.day != b.day) return a.day.compareTo(b.day);
      final aMin = a.startTimeOfDay.hour * 60 + a.startTimeOfDay.minute;
      final bMin = b.startTimeOfDay.hour * 60 + b.startTimeOfDay.minute;
      return aMin.compareTo(bMin);
    });
    return schedules;
  }

  /// Ambil jadwal berdasarkan hari tertentu
  List<Schedule> getSchedulesByDay(int day) {
    final schedules = _box.values.where((s) => s.day == day).toList();
    schedules.sort((a, b) {
      final aMin = a.startTimeOfDay.hour * 60 + a.startTimeOfDay.minute;
      final bMin = b.startTimeOfDay.hour * 60 + b.startTimeOfDay.minute;
      return aMin.compareTo(bMin);
    });
    return schedules;
  }

  /// Ambil jadwal hari ini
  List<Schedule> getTodaySchedules() {
    final todayWeekday = DateTime.now().weekday;
    final todayIndex = todayWeekday - 1;
    if (todayIndex < 0 || todayIndex > 4) return [];
    return getSchedulesByDay(todayIndex);
  }

  /// Tambah jadwal baru
  Future<Schedule> addSchedule({
    required String courseName,
    required int day,
    required String startTime,
    required String endTime,
    required String room,
    String lecturer = '',
    required Color color,
  }) async {
    final schedule = Schedule(
      id: _uuid.v4(),
      courseName: courseName,
      day: day,
      startTime: startTime,
      endTime: endTime,
      room: room,
      lecturer: lecturer,
      colorValue: color.toARGB32(),
    );
    await _box.put(schedule.id, schedule);
    await _updateWidget();
    return schedule;
  }

  /// Edit jadwal yang sudah ada
  Future<void> updateSchedule(Schedule schedule) async {
    await _box.put(schedule.id, schedule);
    await _updateWidget();
  }

  /// Hapus jadwal berdasarkan id
  Future<void> deleteSchedule(String id) async {
    await _box.delete(id);

    // Cascade Delete: Hapus juga semua tugas terkait
    final tasksToDelete = _taskBox.values.where((t) => t.scheduleId == id).toList();
    for (var task in tasksToDelete) {
      await task.delete();
    }

    await _updateWidget();
  }

  // ──────────────────── Operasi Tugas ────────────────────

  /// Ambil tugas untuk mata kuliah tertentu
  List<Task> getTasksForSchedule(String scheduleId) {
    final tasks = _taskBox.values.where((t) => t.scheduleId == scheduleId).toList();
    tasks.sort((a, b) => a.deadline.compareTo(b.deadline));
    return tasks;
  }

  /// Tambah tugas
  Future<void> addTask({
    required String scheduleId,
    required String title,
    required DateTime deadline,
    required bool isGroupTask,
  }) async {
    final task = Task(
      id: _uuid.v4(),
      scheduleId: scheduleId,
      title: title,
      deadline: deadline,
      isGroupTask: isGroupTask,
      status: 0,
    );
    await _taskBox.put(task.id, task);
    await _updateWidget();
  }

  /// Ubah status tugas (0: Belum Mulai, 1: Progres, 2: Selesai)
  Future<void> updateTaskStatus(String taskId, int status) async {
    try {
      final task = _taskBox.values.firstWhere((t) => t.id == taskId);
      task.status = status;
      await task.save();
      await _updateWidget();
    } catch (_) {}
  }

  /// Ubah info tugas
  Future<void> updateTask(Task updatedTask) async {
    try {
      final task = _taskBox.values.firstWhere((t) => t.id == updatedTask.id);
      task.title = updatedTask.title;
      task.deadline = updatedTask.deadline;
      task.isGroupTask = updatedTask.isGroupTask;
      task.status = updatedTask.status;
      await task.save();
      await _updateWidget();
    } catch (_) {}
  }

  /// Hapus tugas
  Future<void> deleteTask(String taskId) async {
    try {
      final task = _taskBox.values.firstWhere((t) => t.id == taskId);
      await task.delete();
      await _updateWidget();
    } catch (_) {}
  }

  /// Validasi konflik waktu
  bool hasTimeConflict(Schedule newSchedule, {String? excludeId}) {
    final daySchedules = getSchedulesByDay(newSchedule.day);
    final newStart = newSchedule.startTimeOfDay.hour * 60 + newSchedule.startTimeOfDay.minute;
    final newEnd = newSchedule.endTimeOfDay.hour * 60 + newSchedule.endTimeOfDay.minute;

    for (final s in daySchedules) {
      if (s.id == excludeId) continue;
      final sStart = s.startTimeOfDay.hour * 60 + s.startTimeOfDay.minute;
      final sEnd = s.endTimeOfDay.hour * 60 + s.endTimeOfDay.minute;
      if (newStart < sEnd && newEnd > sStart) return true;
    }
    return false;
  }

  /// Update Android Home Screen Widget
  Future<void> _updateWidget() async {
    try {
      final today = getTodaySchedules();
      
      // Ubah list jadwal hari ini ke dalam bentuk JSON agar Kotlin bisa membaca dan merendernya dalam List
      final List<Map<String, dynamic>> schedulesJson = today.map((s) {
        // Gabungkan list tugas yang "belum/sedang dikerjakan" (status != 2)
        final uncompletedTasks = getTasksForSchedule(s.id).where((t) => t.status != 2).toList();
        final tasksList = uncompletedTasks.map((t) => {
          'title': t.title,
          'type': t.isGroupTask ? 'Kelompok' : 'Individu',
          'status': t.status,
          'deadline': '${t.deadline.day}/${t.deadline.month}/${t.deadline.year}',
        }).toList();

        return {
          'courseName': s.courseName,
          'time': '${s.startTime} - ${s.endTime}',
          'room': s.room,
          'lecturer': s.lecturer,
          'color': s.colorValue,
          'tasks': tasksList,
        };
      }).toList();

      final jsonString = jsonEncode(schedulesJson);

      // Simpan menggunakan pure SharedPreferences agar lebih handal secara native
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('widget_today_schedule', jsonString);

      // Tetap simpan dengan library home_widget untuk kompatibilitas
      await HomeWidget.setAppGroupId('group.jadwal_kelas_widget');
      await HomeWidget.saveWidgetData<String>('today_schedule_json', jsonString);
      
      await HomeWidget.updateWidget(
        androidName: _widgetName,
        iOSName: _widgetName,
      );
    } catch (_) {
      // Abaikan error jika widget tidak terpasang
    }
  }
}
