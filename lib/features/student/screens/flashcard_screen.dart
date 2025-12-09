import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/flashcard_model.dart';
import '../../../data/repositories/flashcard_repository.dart';

class FlashcardScreen extends StatefulWidget {
  final String subject;

  const FlashcardScreen({super.key, required this.subject});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  final _flashcardRepository = FlashcardRepository();
  List<Flashcard> _flashcards = [];
  int _currentIndex = 0;
  bool _isFlipped = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
  }

  Future<void> _loadFlashcards() async {
    try {
      final flashcards = await _flashcardRepository.getFlashcardsBySubjectAndGrade(
        widget.subject,
        4, // Default grade level
      );
      
      setState(() {
        _flashcards = flashcards;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _flipCard() {
    setState(() => _isFlipped = !_isFlipped);
  }

  void _nextCard() {
    if (_currentIndex < _flashcards.length - 1) {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
      });
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _isFlipped = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_flashcards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('${widget.subject} Flashcards')),
        body: const Center(
          child: Text('No flashcards available for this subject'),
        ),
      );
    }

    final currentCard = _flashcards[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subject} Flashcards'),
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${_currentIndex + 1} / ${_flashcards.length}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          // Flashcard
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: _flipCard,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    key: ValueKey(_isFlipped),
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).orientation == Orientation.portrait
                        ? MediaQuery.of(context).size.height * 0.5
                        : MediaQuery.of(context).size.height * 0.6,
                    decoration: BoxDecoration(
                      color: _isFlipped ? AppColors.secondary : AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          _isFlipped ? currentCard.back : currentCard.front,
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width < 360 ? 18 : 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: _previousCard,
                  icon: const Icon(Icons.arrow_back),
                  iconSize: 32,
                ),
                ElevatedButton(
                  onPressed: _flipCard,
                  child: Text(_isFlipped ? 'Show Front' : 'Show Back'),
                ),
                IconButton(
                  onPressed: _nextCard,
                  icon: const Icon(Icons.arrow_forward),
                  iconSize: 32,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

