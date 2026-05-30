import 'package:flutter/material.dart';

void main() {
  runApp(const ShadowPortfolioApp());
}

/// Root of the app. For now it's intentionally minimal — just a dark canvas.
/// In Phase 1 we'll pull colors/fonts out into a proper theme system.
class ShadowPortfolioApp extends StatelessWidget {
  const ShadowPortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cid Kagenou',
      debugShowCheckedModeBanner: false, // hide the top-right "DEBUG" ribbon
      home: const Scaffold(
        // Temporary inline colors — these become theme tokens in Phase 1.
        backgroundColor: Color(0xFF0D1117), // deep terminal black
        body: Center(
          child: Text(
            'shadow_portfolio :: booting...',
            style: TextStyle(color: Color(0xFF3FB950), fontSize: 18), // terminal green
          ),
        ),
      ),
    );
  }
}
