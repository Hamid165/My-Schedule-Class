import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/schedule.dart';
import '../providers/schedule_provider.dart';
import '../theme/app_theme.dart';
import 'schedule_card.dart';

/// Widget timetable grid - tampilan jadwal mingguan Senin-Jumat
class TimetableGrid extends StatelessWidget {
  const TimetableGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: kDayNames.length,
      child: Column(
        children: [
          const _DayTabBar(),
          Expanded(
            child: TabBarView(
              children: List.generate(
                kDayNames.length,
                (i) => _DayScheduleView(dayIndex: i),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayTabBar extends StatelessWidget {
  const _DayTabBar();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final todayIdx = DateTime.now().weekday - 1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: TabBar(
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: isDark ? AppTheme.accentColor : AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: isDark ? Colors.black : Colors.white,
        unselectedLabelColor: AppTheme.textSecondary,
        labelStyle: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: Theme.of(context).textTheme.bodyLarge,
        tabs: List.generate(kDayNames.length, (i) {
          final isToday = i == todayIdx;
          return Tab(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(kDayNames[i]),
                  if (isToday) ...[
                    const SizedBox(width: 4),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _DayScheduleView extends StatelessWidget {
  final int dayIndex;

  const _DayScheduleView({required this.dayIndex});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleProvider>();
    final schedules = provider.getSchedulesByDay(dayIndex);

    if (schedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available_rounded,
              size: 56,
              color: AppTheme.textSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            Text(
              'Tidak ada jadwal',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap + untuk menambah jadwal',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 80),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      itemCount: schedules.length,
      itemBuilder: (_, i) {
        final schedule = schedules[i];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 300 + i * 80),
          curve: Curves.easeOut,
          builder: (_, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: child,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ScheduleCard(schedule: schedule),
          ),
        );
      },
    );
  }
}
