import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/study_provider.dart';
import 'add_edit_flashcard_screen.dart';

class FlashcardListScreen extends StatelessWidget {
  const FlashcardListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final study = Provider.of<StudyProvider>(context);
    final cards = study.filteredFlashcards;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Flashcards',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          // Favorite Filter Toggle Button
          IconButton(
            icon: Icon(
              study.showFavoritesOnly
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
              color: study.showFavoritesOnly
                  ? Colors.amber
                  : theme.colorScheme.onSurfaceVariant,
            ),
            onPressed: study.toggleFavoritesFilter,
            tooltip: 'Show Favorites',
          ),
          if (study.searchQuery.isNotEmpty ||
              study.selectedCategory != null ||
              study.showFavoritesOnly)
            IconButton(
              icon: const Icon(Icons.filter_alt_off_rounded),
              onPressed: study.clearFilters,
              tooltip: 'Clear Filters',
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Box
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: study.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search in cards...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: study.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () => study.setSearchQuery(''),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Horizontal Categories Filter Scroll Bar
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: study.categories.length + 1,
              itemBuilder: (context, index) {
                final isAllTab = index == 0;
                final catName =
                    isAllTab ? 'All' : study.categories[index - 1].name;
                final isSelected = isAllTab
                    ? study.selectedCategory == null
                    : study.selectedCategory == catName;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FilterChip(
                    label: Text(catName),
                    selected: isSelected,
                    onSelected: (selected) {
                      study.selectCategory(isAllTab ? null : catName);
                    },
                    selectedColor:
                        theme.colorScheme.primary.withValues(alpha: 0.15),
                    checkmarkColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              },
            ),
          ),

          // Cards list
          Expanded(
            child: cards.isEmpty
                ? _buildEmptyState(context, study)
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      final card = cards[index];
                      final formattedDate =
                          DateFormat('yMMMd').format(card.createdAt);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Category & Favorite Row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        card.category,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            card.isFavorite
                                                ? Icons.star_rounded
                                                : Icons.star_border_rounded,
                                            color: card.isFavorite
                                                ? Colors.amber
                                                : Colors.grey,
                                          ),
                                          onPressed: () =>
                                              study.toggleFavorite(card.id),
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                        ),
                                        const SizedBox(width: 12),
                                        // Edit & Delete popover menu
                                        PopupMenuButton<String>(
                                          onSelected: (value) {
                                            if (value == 'edit') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      AddEditFlashcardScreen(
                                                    flashcard: card,
                                                  ),
                                                ),
                                              );
                                            } else if (value == 'delete') {
                                              _confirmDelete(
                                                  context, study, card.id);
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.edit_outlined,
                                                      size: 18),
                                                  SizedBox(width: 8),
                                                  Text('Edit'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                      Icons
                                                          .delete_outline_rounded,
                                                      color: Colors.redAccent,
                                                      size: 18),
                                                  SizedBox(width: 8),
                                                  Text('Delete',
                                                      style: TextStyle(
                                                          color: Colors
                                                              .redAccent)),
                                                ],
                                              ),
                                            ),
                                          ],
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Question Text
                                Text(
                                  card.question,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),

                                // Answer Preview
                                Text(
                                  card.answer,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: theme.brightness == Brightness.dark
                                        ? Colors.white60
                                        : Colors.black54,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Creation Date Footer
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Created $formattedDate',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AddEditFlashcardScreen()),
          );
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, StudyProvider study) {
    final hasFilter = study.searchQuery.isNotEmpty ||
        study.selectedCategory != null ||
        study.showFavoritesOnly;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilter
                  ? Icons.filter_list_off_rounded
                  : Icons.library_books_outlined,
              size: 72,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              hasFilter ? 'No Matching Flashcards' : 'Your Deck is Empty',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilter
                  ? 'Try relaxing your search terms or filters.'
                  : 'Start by creating your first study flashcard using the add button.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            if (hasFilter) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: study.clearFilters,
                child: const Text('Clear All Filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, StudyProvider study, String cardId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Flashcard?'),
        content: const Text(
            'Are you sure you want to permanently delete this card?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await study.deleteFlashcard(cardId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Flashcard deleted')),
        );
      }
    }
  }
}
