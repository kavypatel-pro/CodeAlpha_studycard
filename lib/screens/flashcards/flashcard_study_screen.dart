import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/study_provider.dart';
import '../../models/flashcard.dart';
import '../../widgets/flip_card_widget.dart';

class FlashcardStudyScreen extends StatefulWidget {
  final bool shuffle;
  final String? categoryFilter;
  final bool useApiCards;

  const FlashcardStudyScreen({
    super.key,
    this.shuffle = false,
    this.categoryFilter,
    this.useApiCards = true,
  });

  @override
  State<FlashcardStudyScreen> createState() => _FlashcardStudyScreenState();
}

class _FlashcardStudyScreenState extends State<FlashcardStudyScreen> {
  List<Flashcard> _sessionCards = [];
  int _currentIndex = 0;
  bool _isFlipped = false;
  bool _isShuffleActive = false;
  bool _isSessionFinished = false;
  int _reviewsCount = 0;

  @override
  void initState() {
    super.initState();
    _isShuffleActive = widget.shuffle;
    _setupSession();
  }

  void _setupSession() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final study = Provider.of<StudyProvider>(context, listen: false);

      // Filter list of cards
      List<Flashcard> cards = widget.useApiCards
          ? List.from(study.apiFlashcards)
          : List.from(study.flashcards);
      if (widget.categoryFilter != null) {
        cards =
            cards.where((c) => c.category == widget.categoryFilter).toList();
      }

      if (cards.isEmpty) {
        setState(() {
          _isSessionFinished = true;
        });
        return;
      }

      // Handle shuffle order
      if (_isShuffleActive) {
        cards.shuffle();
      }

      setState(() {
        _sessionCards = cards;
        _currentIndex = 0;
        _isFlipped = false;
        _isSessionFinished = false;
        _reviewsCount = 0;
      });
    });
  }

  void _nextCard() {
    if (_currentIndex < _sessionCards.length - 1) {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
        _reviewsCount++;
      });
    } else {
      // Last card review complete, trigger success dialog/screen
      setState(() {
        _reviewsCount++;
        _isSessionFinished = true;
      });
      _submitStats();
    }
  }

  void _prevCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _isFlipped = false;
      });
    }
  }

  void _toggleShuffle() {
    setState(() {
      _isShuffleActive = !_isShuffleActive;
    });
    _setupSession();
  }

  Future<void> _submitStats() async {
    final study = Provider.of<StudyProvider>(context, listen: false);
    await study.completeStudySession(_reviewsCount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final study = Provider.of<StudyProvider>(context);

    if (_isSessionFinished) {
      return _buildSuccessState(theme);
    }

    if (_sessionCards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Study Cards')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final card = _sessionCards[_currentIndex];
    final totalCards = _sessionCards.length;
    final progress = (totalCards > 0) ? (_currentIndex + 1) / totalCards : 0.0;

    // We check original cards list to sync favorited status
    final originalCard = widget.useApiCards
        ? study.apiFlashcards
            .firstWhere((c) => c.id == card.id, orElse: () => card)
        : study.flashcards
            .firstWhere((c) => c.id == card.id, orElse: () => card);
    final isFavorite = originalCard.isFavorite;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryFilter ?? 'Study Session'),
        centerTitle: true,
        actions: [
          // Shuffle Toggle Button
          IconButton(
            icon: Icon(
              Icons.shuffle_rounded,
              color: _isShuffleActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            onPressed: _toggleShuffle,
            tooltip: 'Shuffle Cards',
          ),
          // Favorite Toggle Button
          IconButton(
            icon: Icon(
              isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
              color: isFavorite
                  ? Colors.amber
                  : theme.colorScheme.onSurfaceVariant,
            ),
            onPressed: () => study.toggleFavorite(card.id),
            tooltip: 'Favorite Card',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress Tracker Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Card ${_currentIndex + 1} of $totalCards',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}% Complete',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Animated Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: theme.brightness == Brightness.dark
                      ? const Color(0xFF2E2C3D)
                      : const Color(0xFFEEEEEE),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                ),
              ),
              const SizedBox(height: 28),

              // Interactive Flip Card Widget
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isFlipped = !_isFlipped;
                    });
                  },
                  child: FlipCardWidget(
                    isFlipped: _isFlipped,
                    front: _buildCardFace(
                      theme: theme,
                      header: 'QUESTION',
                      content: card.question,
                      headerColor: theme.colorScheme.primary,
                      category: card.category,
                    ),
                    back: _buildCardFace(
                      theme: theme,
                      header: 'ANSWER',
                      content: card.answer,
                      headerColor: Colors.teal,
                      category: card.category,
                      isAnswer: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Reveal Button
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _isFlipped = !_isFlipped;
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color:
                          _isFlipped ? Colors.teal : theme.colorScheme.primary,
                      width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  _isFlipped ? 'Show Question' : 'Show Answer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _isFlipped ? Colors.teal : theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Prev & Next Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _currentIndex > 0 ? _prevCard : null,
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('Previous'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.brightness == Brightness.dark
                            ? const Color(0xFF2E2C3D)
                            : const Color(0xFFF5F4F8),
                        foregroundColor: theme.colorScheme.onSurface,
                        disabledBackgroundColor:
                            theme.brightness == Brightness.dark
                                ? const Color(0xFF1E1C2A).withValues(alpha: 0.5)
                                : Colors.grey[200],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _nextCard,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: Text(
                          _currentIndex == totalCards - 1 ? 'Finish' : 'Next'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardFace({
    required ThemeData theme,
    required String header,
    required String content,
    required Color headerColor,
    required String category,
    bool isAnswer = false,
  }) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Stack(
          children: [
            // Top Tag
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            // Middle Content
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: headerColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        header,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: headerColor,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      content,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            // Flip Hint Bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.touch_app_outlined,
                      size: 14, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    'Tap card to flip',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState(ThemeData theme) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: theme.brightness == Brightness.dark
                ? [
                    theme.colorScheme.surface,
                    theme.colorScheme.primary.withValues(alpha: 0.05)
                  ]
                : [
                    theme.colorScheme.primary.withValues(alpha: 0.05),
                    Colors.white
                  ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.celebration_rounded,
                      size: 80,
                      color: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Great Job!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'You reviewed $_reviewsCount flashcards this session.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white60
                        : Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your study stats and daily streak have been updated!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Return to Dashboard',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
