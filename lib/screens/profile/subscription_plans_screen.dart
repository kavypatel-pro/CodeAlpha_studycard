import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class SubscriptionPlansScreen extends StatelessWidget {
  const SubscriptionPlansScreen({super.key});

  void _upgradeTier(BuildContext context, String tierName) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    auth.changeSubscription(tierName);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Subscribed to $tierName successfully! Enjoy your new perks.'),
        backgroundColor: Colors.teal,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    final currentTier = auth.subscriptionType;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Plans'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Unlock StudyCards Premium',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose a plan that fits your study needs. Upgrade or downgrade anytime.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, height: 1.4),
              ),
              const SizedBox(height: 30),

              // Pricing Tiers List
              _buildPricingCard(
                context: context,
                theme: theme,
                name: 'Basic',
                price: 'Free',
                features: [
                  'Limit of 20 active flashcards',
                  'Standard Purple theme',
                  'Basic study tools only',
                ],
                isActive: currentTier == 'Basic',
                onActivate: () => _upgradeTier(context, 'Basic'),
              ),
              const SizedBox(height: 16),

              _buildPricingCard(
                context: context,
                theme: theme,
                name: 'Plus',
                price: '\$2.99 / mo',
                features: [
                  'Unlimited flashcards',
                  'Access to Sunset color theme',
                  'Basic analytics dashboard',
                  'Ad-free learning',
                ],
                isActive: currentTier == 'Plus',
                onActivate: () => _upgradeTier(context, 'Plus'),
              ),
              const SizedBox(height: 16),

              // Pro Plan - Highlighted
              _buildPricingCard(
                context: context,
                theme: theme,
                name: 'Pro',
                price: '\$4.99 / mo',
                features: [
                  'Everything in Plus',
                  'Unlock Ocean & Forest themes',
                  'Advanced learning metrics & charts',
                  'Priority support & cloud backup (UI)',
                ],
                isActive: currentTier == 'Pro',
                isRecommended: true,
                onActivate: () => _upgradeTier(context, 'Pro'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPricingCard({
    required BuildContext context,
    required ThemeData theme,
    required String name,
    required String price,
    required List<String> features,
    required bool isActive,
    bool isRecommended = false,
    required VoidCallback onActivate,
  }) {
    final primaryColor =
        isRecommended ? Colors.amber[700]! : theme.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isRecommended
              ? Colors.amber
              : (isActive
                  ? theme.colorScheme.primary
                  : theme.dividerColor.withValues(alpha: 0.3)),
          width: isRecommended || isActive ? 2.5 : 1,
        ),
      ),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: isRecommended ? 4 : 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Badge header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: primaryColor,
                    ),
                  ),
                  if (isRecommended)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'RECOMMENDED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Price Label
              Text(
                price,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),

              // Features Checkbox lists
              Column(
                children: features.map((feat) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 16,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feat,
                            style: const TextStyle(fontSize: 13, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Action button
              ElevatedButton(
                onPressed: isActive ? null : onActivate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: theme.brightness == Brightness.dark
                      ? const Color(0xFF2E2C3D)
                      : const Color(0xFFECECEC),
                  disabledForegroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  isActive ? 'Current Plan' : 'Upgrade to $name',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
