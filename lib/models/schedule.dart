import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'schedule.g.dart';

/// Model utama untuk data jadwal kuliah
@HiveType(typeId: 0)
class Schedule extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String courseName; // Nama mata kuliah

  @HiveField(2)
  int day; // 0=Senin, 1=Selasa, ..., 4=Jumat

  @HiveField(3)
  String startTime; // Format "HH:mm"

  @HiveField(4)
  String endTime; // Format "HH:mm"

  @HiveField(5)
  String room; // Ruangan

  @HiveField(6)
  String lecturer; // Nama dosen (opsional)

  @HiveField(7)
  int colorValue; // Warna card (ARGB int)

  Schedule({
    required this.id,
    required this.courseName,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.room,
    this.lecturer = '',
    required this.colorValue,
  });

  /// Konversi colorValue menjadi Color Flutter
  Color get color => Color(colorValue);

  /// Nama hari dalam Bahasa Indonesia
  String get dayName {
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    return days[day];
  }

  /// Parse jam mulai menjadi TimeOfDay
  TimeOfDay get startTimeOfDay {
    final parts = startTime.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  /// Parse jam selesai menjadi TimeOfDay
  TimeOfDay get endTimeOfDay {
    final parts = endTime.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  /// Hitung durasi dalam menit
  int get durationMinutes {
    final start = startTimeOfDay.hour * 60 + startTimeOfDay.minute;
    final end = endTimeOfDay.hour * 60 + endTimeOfDay.minute;
    return end - start;
  }

  /// Cek apakah jadwal sedang berlangsung sekarang
  bool isCurrentlyOngoing(TimeOfDay now) {
    final nowMin = now.hour * 60 + now.minute;
    final startMin = startTimeOfDay.hour * 60 + startTimeOfDay.minute;
    final endMin = endTimeOfDay.hour * 60 + endTimeOfDay.minute;
    return nowMin >= startMin && nowMin < endMin;
  }

  /// Copy dengan modifikasi (untuk edit)
  Schedule copyWith({
    String? id,
    String? courseName,
    int? day,
    String? startTime,
    String? endTime,
    String? room,
    String? lecturer,
    int? colorValue,
  }) {
    return Schedule(
      id: id ?? this.id,
      courseName: courseName ?? this.courseName,
      day: day ?? this.day,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      room: room ?? this.room,
      lecturer: lecturer ?? this.lecturer,
      colorValue: colorValue ?? this.colorValue,
    );
  }
}

/// Daftar hari kuliah
const List<String> kDayNames = [
  'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'
];

/// Palet warna card jadwal (soft & aesthetic)
const List<Color> kScheduleColors = [
  Color(0xFFE8D5C4), // Beige
  Color(0xFFD4E8C2), // Mint
  Color(0xFFC2D4E8), // Sky Blue
  Color(0xFFE8C2D4), // Rose
  Color(0xFFE8E8C2), // Yellow Cream
  Color(0xFFC2E8E8), // Aqua
  Color(0xFFD4C2E8), // Lavender
  Color(0xFFE8CAC2), // Peach
];
