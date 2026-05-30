import 'package:flutter/material.dart';
import '../data/profile_data.dart';
import '../theme/app_theme.dart';
import '../widgets/magnetic.dart';
import '../widgets/terminal_window.dart';

class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return TerminalWindow(
      title: 'skills',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '\$ ls skills/',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textDim),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final skill in ProfileData.skills)
                Magnetic(strength: 0.4, child: _SkillsBadge(label: skill)),
            ],
          ),

          const SizedBox(height: 26),
          Text(
            '\$ cat awards.txt',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textDim),
          ),
          const SizedBox(height: 12),
          for (final award in ProfileData.awards)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '* ',
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.amber,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      award,
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SkillsBadge extends StatelessWidget {
  const _SkillsBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: textTheme.bodyMedium?.copyWith(color: AppColors.green),
      ),
    );
  }
}
