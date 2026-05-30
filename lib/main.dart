import 'package:flutter/material.dart';
import 'package:shadow_portfolio/widgets/reveal_on_scroll.dart';
import 'theme/app_theme.dart';
import 'widgets/terminal_window.dart';
import 'widgets/magnetic.dart';
import 'widgets/custom_cursor.dart';

void main() {
  runApp(const ShadowPortfolioApp());
}

class ShadowPortfolioApp extends StatelessWidget {
  const ShadowPortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cid Kagenou',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const CustomCursor(child: BootScreen()),
    );
  }
}

class BootScreen extends StatelessWidget {
  const BootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  TerminalWindow(
                    title: 'cid@shadow: ~',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '\$ whoami',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.textDim,
                          ),
                        ),
                        Text(
                          'Cid Kagenou',
                          style: textTheme.titleLarge?.copyWith(
                            color: AppColors.green,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          '\$ cat role.txt',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.textDim,
                          ),
                        ),
                        Text('Flutter App Developer · Security Enthusiast'),
                        SizedBox(height: 24),
                        Magnetic(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.green),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '> enter',
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.green,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 700),

                  // 리빌 테스트 1
                  RevealOnScroll(
                    child: TerminalWindow(
                      title: 'reveal.md',
                      child: Text('스크롤하니깐 등장했지?'),
                    ),
                  ),

                  SizedBox(height: 700),

                  RevealOnScroll(
                    child: TerminalWindow(
                      title: 'reveal2.md',
                      child: Text('이건 살짝 늦게 등장'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
