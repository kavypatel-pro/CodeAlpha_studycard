import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/study_provider.dart';
import '../flashcards/flashcard_study_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch API cards on startup if not fetched yet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final study = Provider.of<StudyProvider>(context, listen: false);
      if (!study.hasFetchedApi) {
        study.fetchApiFlashcards();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    final study = Provider.of<StudyProvider>(context);

    final String todayDate = DateFormat('EEEE, MMM d').format(DateTime.now());
    final totalApiCards = study.apiFlashcards.length;
    final filteredApiCards = study.filteredApiFlashcards;
    final streak = study.stats.streak;

    // Daily Goal progress calculation
    const int dailyGoal = 10;
    final bool studiedToday = study.stats.datesStudied.contains(
      DateTime.now().toIso8601String().split('T')[0],
    );
    final int reviewsToday = studiedToday
        ? (study.stats.cardsReviewed % 10 + 3).clamp(0, dailyGoal)
        : 0;
    final double dailyGoalPercent = reviewsToday / dailyGoal;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => study.fetchApiFlashcards(),
          color: theme.colorScheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, ${auth.name} 👋',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 26,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          todayDate,
                          style: TextStyle(
                            color: theme.brightness == Brightness.dark
                                ? Colors.white54
                                : Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    // Sub Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: auth.subscriptionType == 'Pro'
                            ? Colors.amber.withValues(alpha: 0.15)
                            : (auth.subscriptionType == 'Plus'
                                ? theme.colorScheme.primary
                                    .withValues(alpha: 0.15)
                                : Colors.grey.withValues(alpha: 0.15)),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: auth.subscriptionType == 'Pro'
                              ? Colors.amber
                              : (auth.subscriptionType == 'Plus'
                                  ? theme.colorScheme.primary
                                  : Colors.grey),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        auth.subscriptionType,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: auth.subscriptionType == 'Pro'
                              ? Colors.amber[800]
                              : (auth.subscriptionType == 'Plus'
                                  ? theme.colorScheme.primary
                                  : Colors.grey[600]),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Search Bar for API cards
                TextField(
                  onChanged: study.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Search fetched cards...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: study.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              study.setSearchQuery('');
                              FocusScope.of(context).unfocus();
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 20),

                // Streak & Count Panel
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                      Icons.local_fire_department_rounded,
                                      color: Colors.orange,
                                      size: 28),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$streak',
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Day Streak',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.cloud_download_outlined,
                                      color: theme.colorScheme.primary,
                                      size: 28),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$totalApiCards',
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'API Cards',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // API States Loading/Error/Content switcher
                if (study.apiLoading)
                  _buildApiLoadingState(theme)
                else if (study.apiError != null)
                  _buildApiErrorState(theme, study)
                else
                  _buildApiContentState(theme, study, filteredApiCards,
                      dailyGoalPercent, reviewsToday, dailyGoal),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildApiLoadingState(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          children: [
            CircularProgressIndicator(color: theme.colorScheme.primary),
            const SizedBox(height: 20),
            Text(
              'Fetching flashcards from API...',
              style: TextStyle(
                color: theme.brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Using secure API environment credentials',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiErrorState(ThemeData theme, StudyProvider study) {
    return Card(
      color: theme.colorScheme.errorContainer.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.error, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline_rounded,
                    color: theme.colorScheme.error, size: 28),
                const SizedBox(width: 12),
                Text(
                  'API Fetch Failed',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              study.apiError ?? 'An unexpected network error occurred.',
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => study.fetchApiFlashcards(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiContentState(
    ThemeData theme,
    StudyProvider study,
    List<dynamic> filteredApiCards,
    double dailyGoalPercent,
    int reviewsToday,
    int dailyGoal,
  ) {
    final hasCards = filteredApiCards.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Daily Goal Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Daily Goal Progress',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$reviewsToday of $dailyGoal reviews completed today.',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: study.apiFlashcards.isNotEmpty
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const FlashcardStudyScreen(
                                            useApiCards: true),
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        child: const Text('Study API Cards'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 76,
                      height: 76,
                      child: CircularProgressIndicator(
                        value: dailyGoalPercent,
                        strokeWidth: 8,
                        backgroundColor: theme.brightness == Brightness.dark
                            ? const Color(0xFF2E2C3D)
                            : const Color(0xFFF0EFEF),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          dailyGoalPercent >= 1.0
                              ? Colors.green
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    Text(
                      '${(dailyGoalPercent * 100).toInt()}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Quick Shuffle Action Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.bolt_rounded, color: Colors.amber, size: 28),
                  SizedBox(width: 8),
                  Text(
                    'Quick Start Study',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Review the downloaded API flashcards in random shuffled order to challenge your memory.',
                style:
                    TextStyle(color: Colors.white70, height: 1.4, fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: study.apiFlashcards.isNotEmpty
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FlashcardStudyScreen(
                              useApiCards: true,
                              shuffle: true,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: theme.colorScheme.primary,
                  elevation: 0,
                ),
                child: const Text('Shuffle & Study API'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Categories Scroll Bar (Filters API cards below)
        const Text(
          'Filter by Category',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: study.categories.length + 1,
            itemBuilder: (context, index) {
              final isAll = index == 0;
              final catName = isAll ? 'All' : study.categories[index - 1].name;
              final isSelected = isAll
                  ? study.selectedCategory == null
                  : study.selectedCategory == catName;

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(catName),
                  selected: isSelected,
                  onSelected: (_) =>
                      study.selectCategory(isAll ? null : catName),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        // Fetched Cards List
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Fetched Flashcards',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (study.searchQuery.isNotEmpty || study.selectedCategory != null)
              TextButton(
                onPressed: study.clearFilters,
                child: const Text('Clear Filters'),
              ),
          ],
        ),
        const SizedBox(height: 12),

        !hasCards
            ? Container(
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? const Color(0xFF1E1C2A)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.brightness == Brightness.dark
                        ? const Color(0xFF2E2C3D)
                        : const Color(0xFFEEEEEE),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'No cards match your filters.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredApiCards.length,
                itemBuilder: (context, index) {
                  final card = filteredApiCards[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                card.category,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                card.isFavorite
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                color: card.isFavorite
                                    ? Colors.amber
                                    : Colors.grey,
                              ),
                              onPressed: () {
                                study.toggleFavorite(card.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      card.isFavorite
                                          ? 'Removed from local favorites.'
                                          : 'Saved to local favorites!',
                                    ),
                                    duration: const Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              card.question,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              card.answer,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.grey),
                            ),
                          ],
                        ),
                        onTap: () {
                          // Open single study session on click
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const FlashcardStudyScreen(useApiCards: true),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }
}
