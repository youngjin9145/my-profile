import 'package:flutter/material.dart';
import '../data/profile_data.dart';
import '../models/project.dart';
import '../state/app_scope.dart';
import '../theme/app_theme.dart';
import '../widgets/terminal_window.dart';

class ProjectsSection extends StatelessWidget {
  const ProjectsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return TerminalWindow(
      title: 'projects',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '\$ ls projects/',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textDim),
          ),
          const SizedBox(height: 16),
          for (final project in ProfileData.projects) ...[
            ProjectCard(project: project),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class ProjectCard extends StatefulWidget {
  const ProjectCard({super.key, required this.project});

  final Project project;

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final lang = AppScope.of(context).lang;
    final project = widget.project;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hover ? -6 : 0, 0),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          boxShadow: _hover
              ? [
                  BoxShadow(
                    color: AppColors.green.withValues(alpha: 0.25),
                    blurRadius: 20,
                  ),
                ]
              : null,
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _hover ? AppColors.green : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                project.image,
                height: 200,
                width: 90,
                fit: BoxFit.fill,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.background,
                  alignment: Alignment.center,
                  child: Text(
                    'no image',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textDim,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 30),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    project.name,
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // note가 있을 때만 // 주석 스타일로 표시
                  if (project.note != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      '// ${project.note!.of(lang)}',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textDim,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      for (final t in project.tech) _TechTag(label: t),
                      if (project.link == null)
                        Text(
                          '🔒 Private',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.textDim,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TechTag extends StatelessWidget {
  const _TechTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: textTheme.bodySmall?.copyWith(color: AppColors.cyan),
      ),
    );
  }
}
