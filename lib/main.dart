import 'package:flutter/material.dart';
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
      home: const CustomCursor(child: BootScreen())
    );
  }
}

class BootScreen extends StatelessWidget {
  const BootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
           child: Padding(
            padding: const EdgeInsets.all(24),
            child: TerminalWindow(
              title: 'cid@shadow: ~',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '\$ whoami',
                    style: textTheme.bodyMedium?.copyWith(color: AppColors.textDim),
                  ),
                  Text(
                    'Cid Kagenou',
                    style: textTheme.titleLarge?.copyWith(color: AppColors.green),
                  ),
                  const SizedBox(height: 14,),
                  Text(
                    '\$ cat role.txt',
                    style: textTheme.bodyMedium?.copyWith(color: AppColors.textDim),
                  ),
                  Text(
                    'Flutter App Developer · Security Enthusiast'
                  ),
                  SizedBox(height: 24,),
                  Magnetic(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.green),
                        borderRadius: BorderRadius.circular(6)
                      ),
                      child: Text(
                        '> enter',
                        style: textTheme.bodyMedium?.copyWith(color: AppColors.green),
                      ),
                    ),
                  )
                ],
              ),
            ),
           ),
        ),
      ),
    );
  }
}
