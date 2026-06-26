import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../auth/welcome_screen.dart';
import '../settings/settings_screen.dart';
import 'subscription_plans_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout?'),
          content:
              const Text('Are you sure you want to sign out of StudyCards?'),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final auth = Provider.of<AuthProvider>(context, listen: false);
                await auth.logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WelcomeScreen()),
                    (route) => false,
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    final themeProv = Provider.of<ThemeProvider>(context);

    final String nameInitials = auth.name!.isNotEmpty
        ? auth.name!.split(' ').map((s) => s[0]).take(2).join().toUpperCase()
        : 'S';

    final subType = auth.subscriptionType;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Avatar Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: theme.colorScheme.primary,
                      child: Text(
                        nameInitials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${auth.name}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${auth.email}',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          // Premium level badge
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SubscriptionPlansScreen(),
                                ),
                              );
                            },
                            child: Container(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: subType == 'Pro'
                                      ? Colors.amber.withValues(alpha: 0.12)
                                      : (subType == 'Plus'
                                          ? Colors.blue.withValues(alpha: 0.12)
                                          : Colors.grey
                                              .withValues(alpha: 0.12)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      subType == 'Pro'
                                          ? Icons.workspace_premium_rounded
                                          : (subType == 'Plus'
                                              ? Icons.stars_rounded
                                              : Icons.star_border_rounded),
                                      size: 14,
                                      color: subType == 'Pro'
                                          ? Colors.amber[800]
                                          : (subType == 'Plus'
                                              ? Colors.blue
                                              : Colors.grey[700]),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$subType Member',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: subType == 'Pro'
                                            ? Colors.amber[800]
                                            : (subType == 'Plus'
                                                ? Colors.blue[700]
                                                : Colors.grey[700]),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Profile Settings list
            const Text(
              'Appearance settings',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
            const SizedBox(height: 8),

            // Dark Mode Switch
            Card(
              child: SwitchListTile(
                title: const Text('Dark Mode Theme'),
                subtitle:
                    const Text('Reduce eye strain in low-light environments'),
                value: themeProv.isDarkMode,
                onChanged: themeProv.toggleTheme,
                secondary: const Icon(Icons.dark_mode_outlined),
              ),
            ),
            const SizedBox(height: 12),

            // Theme Preset Selector Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.palette_outlined,
                            size: 22, color: Colors.grey),
                        SizedBox(width: 12),
                        Text(
                          'Accent Color Theme',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildColorPreset(context, themeProv, 'purple',
                            'Default', Colors.deepPurple, 'Basic'),
                        _buildColorPreset(context, themeProv, 'sunset',
                            'Sunset', Colors.deepOrange, 'Plus'),
                        _buildColorPreset(context, themeProv, 'ocean', 'Ocean',
                            Colors.teal, 'Pro'),
                        _buildColorPreset(context, themeProv, 'forest',
                            'Forest', const Color(0xFF10B981), 'Pro'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Account Options',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
            const SizedBox(height: 8),

            // Subscriptions Page Route
            Card(
              child: ListTile(
                leading: const Icon(Icons.workspace_premium_outlined,
                    color: Colors.amber),
                title: const Text('Manage Subscriptions'),
                subtitle:
                    const Text('Upgrade for unlimited cards & premium themes'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SubscriptionPlansScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // Settings Page Route
            Card(
              child: ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('General Settings'),
                subtitle: const Text('Notification preferences and language'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Logout Button
            OutlinedButton(
              onPressed: () => _handleLogout(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, size: 18),
                  SizedBox(width: 8),
                  Text('Logout Account',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPreset(
    BuildContext context,
    ThemeProvider themeProv,
    String id,
    String name,
    Color color,
    String requiredTier,
  ) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userTier = auth.subscriptionType;

    // Check tier eligibility
    bool isLocked = false;
    if (requiredTier == 'Plus' && userTier == 'Basic') {
      isLocked = true;
    } else if (requiredTier == 'Pro' &&
        (userTier == 'Basic' || userTier == 'Plus')) {
      isLocked = true;
    }

    final isSelected = themeProv.colorTheme == id;

    return GestureDetector(
      onTap: () {
        if (isLocked) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Upgrade to $requiredTier to unlock the $name theme!'),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Upgrade',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SubscriptionPlansScreen()),
                  );
                },
              ),
            ),
          );
        } else {
          themeProv.setColorTheme(id);
        }
      },
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(
                          color: themeProv.isDarkMode
                              ? Colors.white
                              : Colors.black,
                          width: 3)
                      : null,
                ),
              ),
              if (isLocked)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
