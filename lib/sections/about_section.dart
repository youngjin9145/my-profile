import 'package:flutter/material.dart';
import '../data/profile_data.dart';
import '../state/app_scope.dart';
import '../theme/terminal_colors.dart';
import '../widgets/terminal_window.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final lang = AppScope.of(context).lang;
    final term = context.term;

    return TerminalWindow(
      title: 'about.md',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '\$ cat about.md',
            style: textTheme.bodyMedium?.copyWith(color: term.textDim),
          ),
          const SizedBox(height: 12),
          Text(
            ProfileData.about.of(lang),
            style: textTheme.bodyLarge?.copyWith(
              color: term.text,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
