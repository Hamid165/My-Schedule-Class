import 'package:hive/hive.dart';

part 'task.g.dart';

/// Model untuk tugas mata kuliah
@HiveType(typeId: 1)
class Task extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String scheduleId; // Relasi ke ID Jadwal Mata Kuliah

  @HiveField(2)
  String title; // Judul tugas

  @HiveField(3)
  DateTime deadline; // Tenggat waktu tugas

  @HiveField(4)
  bool isGroupTask; // true = Kelompok, false = Individu

  @HiveField(5)
  int status; // 0 = Belum mulai, 1 = Progres, 2 = Selesai

  Task({
    required this.id,
    required this.scheduleId,
    required this.title,
    required this.deadline,
    required this.isGroupTask,
    this.status = 0,
  });

  /// Menggandakan tugas untuk proses edit
  Task copyWith({
    String? id,
    String? scheduleId,
    String? title,
    DateTime? deadline,
    bool? isGroupTask,
    int? status,
  }) {
    return Task(
      id: id ?? this.id,
      scheduleId: scheduleId ?? this.scheduleId,
      title: title ?? this.title,
      deadline: deadline ?? this.deadline,
      isGroupTask: isGroupTask ?? this.isGroupTask,
      status: status ?? this.status,
    );
  }
}
