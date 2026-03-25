import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Widget empty state saat belum ada jadwal tersimpan
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_month_rounded,
                size: 56,
                color: isDark
                    ? AppTheme.accentColor.withValues(alpha: 0.6)
                    : AppTheme.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum Ada Jadwal',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Mulai tambahkan jadwal kuliah kamu\nagar tidak ketinggalan kelas!',
              style:
                  Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.accentColor.withValues(alpha: 0.1)
                    : AppTheme.primaryColor.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.touch_app_rounded,
                    size: 18,
                    color:
                        isDark ? AppTheme.accentColor : AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tap tombol + di bawah',
                    style:
                        Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: isDark
                                  ? AppTheme.accentColor
                                  : AppTheme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
