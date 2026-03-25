import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import '../models/schedule.dart';

/// Service untuk operasi CRUD jadwal kuliah menggunakan Hive
class ScheduleService {
  static const String _boxName = 'schedules';
  static const String _widgetName = 'JadwalKelasWidget';

  late Box<Schedule> _box;
  final _uuid = const Uuid();

  /// Inisialisasi Hive box - dipanggil saat app start
  Future<void> init() async {
    _box = await Hive.openBox<Schedule>(_boxName);
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
    await _updateWidget();
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
      final buffer = StringBuffer();

      if (today.isEmpty) {
        buffer.write('Tidak ada jadwal hari ini');
      } else {
        for (final s in today) {
          buffer.write('${s.startTime}-${s.endTime} ${s.courseName}\n');
        }
      }

      await HomeWidget.saveWidgetData<String>('today_schedule', buffer.toString().trim());
      await HomeWidget.updateWidget(
        androidName: _widgetName,
        iOSName: _widgetName,
      );
    } catch (_) {
      // Abaikan error jika widget tidak terpasang
    }
  }
}
