import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ShadowPortfolioApp());
}

class ShadowPortfolioApp extends StatelessWidget {
  const ShadowPortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cid Kagenou',
      debugShowCheckedModeBanner: false, // hide the top-right "DEBUG" ribbon
      theme: AppTheme.dark,
      home: const BootScreen(),
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
        child: Text(
          'shadow_portfolio :: booting...',
          style: textTheme.titleMedium?.copyWith(color: AppColors.green),
        ),
      ),
    );
  }
}
