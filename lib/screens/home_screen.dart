import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/timetable_grid.dart';
import '../widgets/today_schedule_card.dart';
import '../widgets/empty_state_widget.dart';
import 'schedule_form_sheet.dart';

/// Home Screen - menampilkan timetable mingguan dan jadwal hari ini
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedTab = 0; // 0=Timetable, 1=Hari Ini

  late AnimationController _fabAnimCtrl;
  late Animation<double> _fabAnim;

  @override
  void initState() {
    super.initState();
    _fabAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fabAnim = CurvedAnimation(parent: _fabAnimCtrl, curve: Curves.elasticOut);
    _fabAnimCtrl.forward();

    // Load data saat pertama kali buka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleProvider>().loadSchedules();
    });
  }

  @override
  void dispose() {
    _fabAnimCtrl.dispose();
    super.dispose();
  }

  void _openAddForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ScheduleFormSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();
    final scheduleProvider = context.watch<ScheduleProvider>();

    return Scaffold(
      // ─── AppBar ───
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jadwal Kuliah',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              'Semester ini',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                key: ValueKey(isDark),
              ),
            ),
            onPressed: themeProvider.toggleTheme,
            tooltip: isDark ? 'Light Mode' : 'Dark Mode',
          ),
          const SizedBox(width: 4),
        ],
      ),

      // ─── Body ───
      body: Column(
        children: [
          _buildTabBar(isDark),
          Expanded(
            child: scheduleProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildContent(scheduleProvider, isDark),
          ),
        ],
      ),

      // ─── FAB ───
      floatingActionButton: ScaleTransition(
        scale: _fabAnim,
        child: FloatingActionButton.extended(
          onPressed: _openAddForm,
          backgroundColor:
              isDark ? AppTheme.accentColor : AppTheme.primaryColor,
          foregroundColor: isDark ? Colors.black : Colors.white,
          elevation: 4,
          icon: const Icon(Icons.add_rounded),
          label: Text(
            'Tambah Jadwal',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _buildTab(0, Icons.grid_view_rounded, 'Mingguan', isDark),
          _buildTab(1, Icons.today_rounded, 'Hari Ini', isDark),
        ],
      ),
    );
  }

  Widget _buildTab(int idx, IconData icon, String label, bool isDark) {
    final selected = _selectedTab == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = idx),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? (isDark ? AppTheme.cardDark : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected
                    ? (isDark
                        ? AppTheme.accentColor
                        : AppTheme.primaryColor)
                    : AppTheme.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected
                          ? (isDark
                              ? AppTheme.accentColor
                              : AppTheme.primaryColor)
                          : AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ScheduleProvider provider, bool isDark) {
    if (provider.isEmpty) {
      return const EmptyStateWidget();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _selectedTab == 0
          ? TimetableGrid(key: const ValueKey('timetable'))
          : TodayScheduleView(key: const ValueKey('today')),
    );
  }
}
