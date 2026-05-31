import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/profile_data.dart';
import '../theme/app_theme.dart';
import '../widgets/magnetic.dart';
import '../widgets/terminal_window.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return TerminalWindow(
      title: 'contact',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '\$ ./contact.sh',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textDim),
          ),
          const SizedBox(height: 16),
          Text(
            "Let's build something from the shadows.",
            style: textTheme.titleMedium?.copyWith(color: AppColors.text),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _SocialButton(
                icon: FontAwesomeIcons.github,
                label: 'GitHub',
                url: ProfileData.github,
              ),
              _SocialButton(
                icon: FontAwesomeIcons.linkedin,
                label: 'LinkedIn',
                url: ProfileData.linkedin,
              ),
              _SocialButton(
                icon: FontAwesomeIcons.envelope,
                label: 'Email',
                url: 'mailto:${ProfileData.email}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatefulWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.url,
  });

  final FaIconData icon;
  final String label;
  final String url;

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool _hover = false;

  Future<void> _open() async {
    await launchUrl(
      Uri.parse(widget.url),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = _hover ? AppColors.green : AppColors.text;

    return Magnetic(
      child: GestureDetector(
        onTap: _open,
        child: MouseRegion(
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _hover ? AppColors.green : AppColors.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(widget.icon, size: 16, color: color),
                const SizedBox(width: 10),
                Text(
                  widget.label,
                  style: textTheme.bodyMedium?.copyWith(color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
