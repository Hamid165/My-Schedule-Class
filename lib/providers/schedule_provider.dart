import 'package:flutter/material.dart';
import '../models/schedule.dart';
import '../services/schedule_service.dart';

/// Provider untuk state management jadwal kuliah
/// Menggunakan ChangeNotifier untuk reactive UI updates
class ScheduleProvider extends ChangeNotifier {
  final ScheduleService _service;

  List<Schedule> _schedules = [];
  bool _isLoading = false;
  String? _errorMessage;

  ScheduleProvider(this._service);

  // ─────────────────────── Getters ───────────────────────
  List<Schedule> get schedules => _schedules;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isEmpty => _schedules.isEmpty;

  /// Jadwal hari ini
  List<Schedule> get todaySchedules => _service.getTodaySchedules();

  /// Jadwal yang sedang berlangsung saat ini
  Schedule? get currentSchedule {
    final now = TimeOfDay.now();
    final todayIdx = DateTime.now().weekday - 1;
    if (todayIdx < 0 || todayIdx > 4) return null;
    try {
      return _schedules.firstWhere(
        (s) => s.day == todayIdx && s.isCurrentlyOngoing(now),
      );
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────── Inisialisasi ───────────────────────
  Future<void> loadSchedules() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _schedules = _service.getAllSchedules();
    } catch (e) {
      _errorMessage = 'Gagal memuat data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─────────────────────── Ambil Per Hari ───────────────────────
  List<Schedule> getSchedulesByDay(int day) {
    return _schedules.where((s) => s.day == day).toList()
      ..sort((a, b) {
        final aMin = a.startTimeOfDay.hour * 60 + a.startTimeOfDay.minute;
        final bMin = b.startTimeOfDay.hour * 60 + b.startTimeOfDay.minute;
        return aMin.compareTo(bMin);
      });
  }

  // ─────────────────────── CRUD Operations ───────────────────────

  /// Tambah jadwal baru
  Future<bool> addSchedule({
    required String courseName,
    required int day,
    required String startTime,
    required String endTime,
    required String room,
    String lecturer = '',
    required Color color,
  }) async {
    try {
      final temp = Schedule(
        id: '__temp__',
        courseName: courseName,
        day: day,
        startTime: startTime,
        endTime: endTime,
        room: room,
        lecturer: lecturer,
        colorValue: color.toARGB32(),
      );

      if (_service.hasTimeConflict(temp)) {
        _errorMessage = 'Jadwal bertabrakan dengan jadwal yang sudah ada!';
        notifyListeners();
        return false;
      }

      await _service.addSchedule(
        courseName: courseName,
        day: day,
        startTime: startTime,
        endTime: endTime,
        room: room,
        lecturer: lecturer,
        color: color,
      );

      await loadSchedules();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menambah jadwal: $e';
      notifyListeners();
      return false;
    }
  }

  /// Edit jadwal yang sudah ada
  Future<bool> updateSchedule(Schedule schedule) async {
    try {
      if (_service.hasTimeConflict(schedule, excludeId: schedule.id)) {
        _errorMessage = 'Jadwal bertabrakan dengan jadwal yang sudah ada!';
        notifyListeners();
        return false;
      }

      await _service.updateSchedule(schedule);
      await loadSchedules();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengupdate jadwal: $e';
      notifyListeners();
      return false;
    }
  }

  /// Hapus jadwal
  Future<void> deleteSchedule(String id) async {
    try {
      await _service.deleteSchedule(id);
      await loadSchedules();
    } catch (e) {
      _errorMessage = 'Gagal menghapus jadwal: $e';
      notifyListeners();
    }
  }

  /// Bersihkan pesan error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
