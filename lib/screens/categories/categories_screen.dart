import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/study_provider.dart';
import '../../models/category.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  // Preset list of colors and icons for category creator
  final List<int> _presetColors = [
    0xFF2196F3, // Blue
    0xFF4CAF50, // Green
    0xFFFF9800, // Orange
    0xFF795548, // Brown
    0xFFFFC107, // Amber
    0xFF9C27B0, // Purple
    0xFFE91E63, // Pink
    0xFFF44336, // Red
    0xFF009688, // Teal
  ];

  final List<IconData> _presetIcons = [
    Icons.folder_rounded,
    Icons.code_rounded,
    Icons.science_rounded,
    Icons.calculate_rounded,
    Icons.history_edu_rounded,
    Icons.lightbulb_rounded,
    Icons.language_rounded,
    Icons.menu_book_rounded,
    Icons.palette_rounded,
    Icons.music_note_rounded,
    Icons.sports_basketball_rounded,
  ];

  void _showCategoryDialog({Category? category}) {
    final study = Provider.of<StudyProvider>(context, listen: false);
    final isEditing = category != null;

    final nameController = TextEditingController(text: category?.name ?? '');
    int selectedColor = category?.colorValue ?? _presetColors[0];
    int selectedIconCode = category?.iconCode ?? _presetIcons[0].codePoint;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Category' : 'New Category'),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name textfield
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Category Name',
                        hintText: 'e.g. Science, Spanish...',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Color Picker title
                    const Text(
                      'Select Color',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    // Grid of colors
                    SizedBox(
                      height: 50,
                      width: double.maxFinite,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _presetColors.length,
                        itemBuilder: (context, index) {
                          final colorVal = _presetColors[index];
                          final isSelected = selectedColor == colorVal;

                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                selectedColor = colorVal;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Color(colorVal),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.transparent,
                                  width: 2.5,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Icon Picker title
                    const Text(
                      'Select Icon',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    // Grid of icons
                    SizedBox(
                      height: 50,
                      width: double.maxFinite,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _presetIcons.length,
                        itemBuilder: (context, index) {
                          final icon = _presetIcons[index];
                          final isSelected = selectedIconCode == icon.codePoint;

                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                selectedIconCode = icon.codePoint;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Color(selectedColor)
                                        .withValues(alpha: 0.2)
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? Color(selectedColor)
                                      : Colors.grey.withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                icon,
                                size: 22,
                                color: isSelected
                                    ? Color(selectedColor)
                                    : Colors.grey[600],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;

                    if (isEditing) {
                      final updated = category.copyWith(
                        name: name,
                        iconCode: selectedIconCode,
                        colorValue: selectedColor,
                      );
                      study.updateCategory(updated, category.name);
                    } else {
                      study.addCategory(name, selectedIconCode, selectedColor);
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(selectedColor),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(isEditing ? 'Save' : 'Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(
      BuildContext context, StudyProvider study, Category category) {
    if (category.name == 'General Knowledge') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete the default category.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete "${category.name}"?'),
          content: const Text(
            'Are you sure you want to delete this category? All cards in this category will be reassigned to "General Knowledge".',
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                study.deleteCategory(category.id, category.name);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Category "${category.name}" deleted.')),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final study = Provider.of<StudyProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Categories',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: study.isLoading
          ? Center(
              child:
                  CircularProgressIndicator(color: theme.colorScheme.primary))
          : study.categories.isEmpty
              ? _buildEmptyState(theme)
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: study.categories.length,
                  itemBuilder: (context, index) {
                    final cat = study.categories[index];
                    final color = Color(cat.colorValue);
                    final icon = _presetIcons.firstWhere(
                      (i) => i.codePoint == cat.iconCode,
                      orElse: () => Icons.folder_rounded,
                    );

                    // Calculate card count matching this category
                    final cardCount = study.flashcards
                        .where((c) => c.category == cat.name)
                        .length;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              icon,
                              color: color,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            cat.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Text(
                            '$cardCount ${cardCount == 1 ? 'card' : 'cards'}',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 13),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Edit Button
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                onPressed: () =>
                                    _showCategoryDialog(category: cat),
                                tooltip: 'Edit Category',
                              ),
                              // Delete Button
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded,
                                    color: Colors.redAccent, size: 20),
                                onPressed: () =>
                                    _confirmDelete(context, study, cat),
                                tooltip: 'Delete Category',
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryDialog(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Category'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_outlined, size: 72, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No Categories Found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start by creating custom topics to structure your flashcards.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
