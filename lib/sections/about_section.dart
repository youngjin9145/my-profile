import 'package:flutter/material.dart';
import '../data/profile_data.dart';
import '../theme/app_theme.dart';
import '../widgets/terminal_window.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return TerminalWindow(
      title: 'about.md',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '\$ cat about.md',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textDim),
          ),
          const SizedBox(height: 12),
          Text(
            ProfileData.about,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.text,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
