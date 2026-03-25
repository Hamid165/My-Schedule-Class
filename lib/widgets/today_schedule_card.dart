import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';
import '../theme/app_theme.dart';
import 'schedule_card.dart';

/// Widget tampilan jadwal hari ini dengan highlight "sedang berlangsung"
class TodayScheduleView extends StatefulWidget {
  const TodayScheduleView({super.key});

  @override
  State<TodayScheduleView> createState() => _TodayScheduleViewState();
}

class _TodayScheduleViewState extends State<TodayScheduleView> {
  late final Stream<DateTime> _timeStream;

  @override
  void initState() {
    super.initState();
    _timeStream = Stream.periodic(
      const Duration(seconds: 30),
      (_) => DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleProvider>();
    final schedules = provider.todaySchedules;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dayNames = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    final todayIdx = DateTime.now().weekday - 1;
    final dayLabel =
        todayIdx >= 0 && todayIdx < 7 ? dayNames[todayIdx] : '-';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header Hari Ini ───
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.accentColor.withValues(alpha: 0.15)
                        : AppTheme.primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.today_rounded,
                    color: isDark
                        ? AppTheme.accentColor
                        : AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hari ini — $dayLabel',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      schedules.isEmpty
                          ? 'Tidak ada jadwal'
                          : '${schedules.length} jadwal kuliah',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (schedules.isEmpty)
            _buildEmptyToday(context)
          else
            StreamBuilder<DateTime>(
              stream: _timeStream,
              initialData: DateTime.now(),
              builder: (_, __) {
                final now = TimeOfDay.now();
                return Column(
                  children: schedules.map((s) {
                    final isOngoing = s.isCurrentlyOngoing(now);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ScheduleCard(
                        schedule: s,
                        isHighlighted: isOngoing,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyToday(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.free_breakfast_rounded,
              size: 64,
              color: AppTheme.textSecondary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada kuliah hari ini!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Saatnya istirahat 🎉',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
