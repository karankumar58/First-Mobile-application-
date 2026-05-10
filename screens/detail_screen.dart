// screens/detail_screen.dart
import 'package:flutter/material.dart';
import '../enums/app_enums.dart';
import '../utils/app_theme.dart';

class DetailScreen extends StatelessWidget {
  final Subject subject;
  const DetailScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Banner / Header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppTheme.surfaceColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                subject.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 6, color: Colors.black45)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient banner (placeholder for banner image)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _bannerColors(subject),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // Icon overlay
                  Center(
                    child: Text(
                      subject.iconEmoji,
                      style: const TextStyle(fontSize: 72),
                    ),
                  ),
                  // Bottom fade
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subject title chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.4)),
                    ),
                    child: Text(
                      subject.title,
                      style: const TextStyle(
                        color: AppTheme.accentColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description Section
                  _sectionTitle('About this Course'),
                  const SizedBox(height: 10),
                  Text(
                    subject.description,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14.5,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Schedule Section
                  _sectionTitle('Schedule'),
                  const SizedBox(height: 10),
                  _scheduleCard(subject.schedule),
                  const SizedBox(height: 32),

                  // Objectives list
                  _sectionTitle('Learning Objectives'),
                  const SizedBox(height: 10),
                  ..._objectives(subject).map(_objectiveItem),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _scheduleCard(String schedule) {
    final parts = schedule.split('|');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: parts.map((part) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.circle, size: 8, color: AppTheme.accentColor),
                const SizedBox(width: 10),
                Text(
                  part.trim(),
                  style: const TextStyle(
                      color: AppTheme.textPrimary, fontSize: 14),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _objectiveItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 3),
            child: Icon(Icons.check_circle_rounded,
                size: 18, color: AppTheme.successColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 14, height: 1.5)),
          ),
        ],
      ),
    );
  }

  List<Color> _bannerColors(Subject subject) {
    switch (subject) {
      case Subject.mobileAppDevelopment:
        return [const Color(0xFF1565C0), const Color(0xFF0288D1)];
      case Subject.softwareReengineering:
        return [const Color(0xFF1B5E20), const Color(0xFF388E3C)];
      case Subject.mis:
        return [const Color(0xFF4A148C), const Color(0xFF7B1FA2)];
    }
  }

  List<String> _objectives(Subject subject) {
    switch (subject) {
      case Subject.mobileAppDevelopment:
        return [
          'Build cross-platform apps for Android and iOS',
          'Master Flutter widgets, layouts, and animations',
          'Implement state management using Provider or Riverpod',
          'Integrate REST APIs and handle async data',
          'Deploy apps to app stores',
        ];
      case Subject.softwareReengineering:
        return [
          'Understand legacy system analysis techniques',
          'Apply code refactoring and design patterns',
          'Perform reverse engineering on existing systems',
          'Migrate monolithic apps to microservices',
          'Ensure quality through automated testing',
        ];
      case Subject.mis:
        return [
          'Understand the role of IT in organizational management',
          'Analyze business processes and data flows',
          'Work with ERP and decision support systems',
          'Evaluate information systems for business value',
          'Apply IT governance and security frameworks',
        ];
    }
  }
}
