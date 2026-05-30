import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../data/profile_data.dart';
import '../theme/app_theme.dart';
import '../widgets/terminal_window.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return TerminalWindow(
      title: ProfileData.terminalTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '\$ whoami',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textDim)
          ),
          const SizedBox(height: 4),
          Text(
            ProfileData.handle,
            style: textTheme.headlineMedium?.copyWith(color: AppColors.green, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 18),

          Text(
            '\$ cat roles.txt',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textDim
            ),
          ),
          const SizedBox(height: 4,),

          Row(children: [
            Text(
              '> ',
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.cyan
              ),
            ),
            AnimatedTextKit(
              repeatForever: true,
              pause: const Duration(milliseconds: 1200),
              animatedTexts: [
                for (final role in ProfileData.roles)
                  TypewriterAnimatedText(
                    role,
                    textStyle: textTheme.titleMedium?.copyWith(color: AppColors.cyan),
                    speed: const Duration(milliseconds: 70),
                  )
              ],
            )
          ],)
        ],
      ),
    );
  }
}
