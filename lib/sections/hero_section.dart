import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../data/profile_data.dart';
import '../state/app_scope.dart';
import '../theme/app_theme.dart';
import '../widgets/terminal_window.dart';
import '../widgets/glitch_text.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final lang = AppScope.of(context).lang;

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
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: GlitchText(ProfileData.handle),
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
                    role.of(lang),
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
