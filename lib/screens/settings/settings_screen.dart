import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showPrivacyPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                controller: scrollController,
                children: [
                  const Text(
                    'Privacy Policy',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Last Updated: June 2026',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const Divider(height: 24),
                  const Text(
                    '1. Data We Collect\n'
                    'StudyCards is designed as a secure, local-first application. All of your personal study data, flashcards, statistics, progress logs, and category setups are stored directly on your device\'s local storage using SharedPreferences.\n\n'
                    '2. How We Use Data\n'
                    'Your data remains private to your device. We do not transmit or sync your personalized decks, scores, or preferences to external databases or servers. If mock cloud backup features are activated under Pro tiers, the backup simulations occur locally.\n\n'
                    '3. Security\n'
                    'We value your trust in providing us your information. We strive to utilize commercial-grade methods of securing your local workspace, though no storage technique is 100% secure.',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('About StudyCards'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.style_rounded,
                    color: theme.colorScheme.primary, size: 48),
              ),
              const SizedBox(height: 16),
              const Text(
                'StudyCards Mobile App',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 4),
              const Text('Version 1.0.0 (Production Build)',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 12),
              const Text(
                'StudyCards is a modern, premium study flashcard utility created to help students review and memorize facts using Material Design 3 guidelines.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProv = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'General Preferences',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),

          // Notifications toggle
          Card(
            child: SwitchListTile(
              title: const Text('Study Reminders'),
              subtitle: const Text(
                  'Receive push alerts to maintain your study streak'),
              value: themeProv.notificationsEnabled,
              onChanged: themeProv.setNotificationsEnabled,
              secondary: const Icon(Icons.notifications_active_outlined),
            ),
          ),
          const SizedBox(height: 8),

          // Language selection
          Card(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.language_rounded, color: Colors.grey),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('App Language',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Select your preferred local display language',
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  DropdownButton<String>(
                    value: themeProv.selectedLanguage,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'es', child: Text('Español')),
                      DropdownMenuItem(value: 'fr', child: Text('Français')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        themeProv.setLanguage(val);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Legal & Info',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),

          // Privacy Policy
          Card(
            child: ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Privacy Policy'),
              subtitle: const Text('Read terms about local storage and safety'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _showPrivacyPolicy(context),
            ),
          ),
          const SizedBox(height: 8),

          // About Page
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('About App'),
              subtitle:
                  const Text('View developer build details and licensing'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _showAboutDialog(context, theme),
            ),
          ),
        ],
      ),
    );
  }
}
