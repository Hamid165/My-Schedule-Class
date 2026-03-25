// GENERATED CODE - DO NOT MODIFY BY HAND
// Hive TypeAdapter untuk model Schedule
// File ini dibuat manual karena tidak bisa menjalankan build_runner saat ini

part of 'schedule.dart';

class ScheduleAdapter extends TypeAdapter<Schedule> {
  @override
  final int typeId = 0;

  @override
  Schedule read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Schedule(
      id: fields[0] as String,
      courseName: fields[1] as String,
      day: fields[2] as int,
      startTime: fields[3] as String,
      endTime: fields[4] as String,
      room: fields[5] as String,
      lecturer: fields[6] as String? ?? '',
      colorValue: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Schedule obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.courseName)
      ..writeByte(2)
      ..write(obj.day)
      ..writeByte(3)
      ..write(obj.startTime)
      ..writeByte(4)
      ..write(obj.endTime)
      ..writeByte(5)
      ..write(obj.room)
      ..writeByte(6)
      ..write(obj.lecturer)
      ..writeByte(7)
      ..write(obj.colorValue);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
