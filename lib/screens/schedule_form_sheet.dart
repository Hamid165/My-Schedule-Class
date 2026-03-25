import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/schedule.dart';
import '../providers/schedule_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/color_picker_widget.dart';

/// Bottom sheet form untuk tambah/edit jadwal
class ScheduleFormSheet extends StatefulWidget {
  final Schedule? schedule;

  const ScheduleFormSheet({super.key, this.schedule});

  @override
  State<ScheduleFormSheet> createState() => _ScheduleFormSheetState();
}

class _ScheduleFormSheetState extends State<ScheduleFormSheet>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _courseController;
  late TextEditingController _roomController;
  late TextEditingController _lecturerController;

  int _selectedDay = 0;
  String _startTime = '08:00';
  String _endTime = '10:00';
  Color _selectedColor = kScheduleColors.first;
  bool _isSaving = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  bool get _isEdit => widget.schedule != null;

  @override
  void initState() {
    super.initState();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();

    final s = widget.schedule;
    _courseController = TextEditingController(text: s?.courseName ?? '');
    _roomController = TextEditingController(text: s?.room ?? '');
    _lecturerController = TextEditingController(text: s?.lecturer ?? '');
    _selectedDay = s?.day ?? 0;
    _startTime = s?.startTime ?? '08:00';
    _endTime = s?.endTime ?? '10:00';
    _selectedColor =
        s != null ? Color(s.colorValue) : kScheduleColors.first;
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _courseController.dispose();
    _roomController.dispose();
    _lecturerController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isStart) async {
    final current = _parseTime(isStart ? _startTime : _endTime);
    final picked = await showTimePicker(
      context: context,
      initialTime: current,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) {
      final fmt =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        if (isStart) {
          _startTime = fmt;
          if (_parseMinutes(_startTime) >= _parseMinutes(_endTime)) {
            final endMin = _parseMinutes(fmt) + 100;
            final h = (endMin ~/ 60).clamp(0, 23);
            final m = endMin % 60;
            _endTime =
                '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
          }
        } else {
          _endTime = fmt;
        }
      });
    }
  }

  TimeOfDay _parseTime(String t) {
    final p = t.split(':');
    return TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
  }

  int _parseMinutes(String t) {
    final p = t.split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_parseMinutes(_startTime) >= _parseMinutes(_endTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jam selesai harus lebih dari jam mulai!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final provider = context.read<ScheduleProvider>();

    bool success;
    if (_isEdit) {
      final updated = widget.schedule!.copyWith(
        courseName: _courseController.text.trim(),
        day: _selectedDay,
        startTime: _startTime,
        endTime: _endTime,
        room: _roomController.text.trim(),
        lecturer: _lecturerController.text.trim(),
        colorValue: _selectedColor.toARGB32(),
      );
      success = await provider.updateSchedule(updated);
    } else {
      success = await provider.addSchedule(
        courseName: _courseController.text.trim(),
        day: _selectedDay,
        startTime: _startTime,
        endTime: _endTime,
        room: _roomController.text.trim(),
        lecturer: _lecturerController.text.trim(),
        color: _selectedColor,
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit
              ? 'Jadwal berhasil diperbarui'
              : 'Jadwal berhasil ditambahkan'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      final err = provider.errorMessage;
      provider.clearError();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err ?? 'Terjadi kesalahan'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardDark : Colors.white,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[600] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    Text(
                      _isEdit ? 'Edit Jadwal' : 'Tambah Jadwal',
                      style: textTheme.headlineMedium,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    16,
                    20,
                    MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Mata Kuliah *'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _courseController,
                          decoration: const InputDecoration(
                            hintText: 'Contoh: Algoritma & Pemrograman',
                            prefixIcon: Icon(Icons.school_outlined),
                          ),
                          textCapitalization: TextCapitalization.words,
                          validator: (v) =>
                              v == null || v.trim().isEmpty
                                  ? 'Nama mata kuliah wajib diisi'
                                  : null,
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Hari *'),
                        const SizedBox(height: 6),
                        _buildDaySelector(),
                        const SizedBox(height: 16),
                        _buildLabel('Jam *'),
                        const SizedBox(height: 6),
                        _buildTimeRow(),
                        const SizedBox(height: 16),
                        _buildLabel('Ruangan *'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _roomController,
                          decoration: const InputDecoration(
                            hintText: 'Contoh: F-201',
                            prefixIcon: Icon(Icons.meeting_room_outlined),
                          ),
                          textCapitalization: TextCapitalization.characters,
                          validator: (v) =>
                              v == null || v.trim().isEmpty
                                  ? 'Ruangan wajib diisi'
                                  : null,
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Dosen (opsional)'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _lecturerController,
                          decoration: const InputDecoration(
                            hintText: 'Contoh: Dr. Budi Santoso',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Warna Card'),
                        const SizedBox(height: 10),
                        ColorPickerWidget(
                          selected: _selectedColor,
                          colors: kScheduleColors,
                          onSelected: (c) =>
                              setState(() => _selectedColor = c),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _save,
                            child: _isSaving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white),
                                  )
                                : Text(_isEdit
                                    ? 'Simpan Perubahan'
                                    : 'Tambah Jadwal'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: AppTheme.textSecondary,
          ),
    );
  }

  Widget _buildDaySelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Wrap(
      spacing: 8,
      children: List.generate(kDayNames.length, (i) {
        final selected = _selectedDay == i;
        return GestureDetector(
          onTap: () => setState(() => _selectedDay = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected
                  ? (isDark
                      ? AppTheme.accentColor
                      : AppTheme.primaryColor)
                  : (isDark
                      ? AppTheme.surfaceDark
                      : AppTheme.surfaceLight),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected
                    ? Colors.transparent
                    : (isDark
                        ? AppTheme.dividerDark
                        : AppTheme.dividerLight),
              ),
            ),
            child: Text(
              kDayNames[i],
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: selected
                        ? (isDark ? Colors.black : Colors.white)
                        : null,
                    fontWeight: selected
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTimeRow() {
    return Row(
      children: [
        Expanded(
            child: _buildTimeTile(
                'Mulai', _startTime, () => _pickTime(true))),
        const SizedBox(width: 12),
        const Icon(Icons.arrow_forward,
            size: 18, color: AppTheme.textSecondary),
        const SizedBox(width: 12),
        Expanded(
            child: _buildTimeTile(
                'Selesai', _endTime, () => _pickTime(false))),
      ],
    );
  }

  Widget _buildTimeTile(String label, String time, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time,
                size: 18, color: AppTheme.textSecondary),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  time,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
