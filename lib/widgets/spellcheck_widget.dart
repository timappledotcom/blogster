import 'package:flutter/material.dart';
import '../services/spellcheck_service.dart';

class SpellcheckWidget extends StatefulWidget {
  final String text;
  final Function(String) onTextChanged;
  final VoidCallback? onClose;

  const SpellcheckWidget({
    super.key,
    required this.text,
    required this.onTextChanged,
    this.onClose,
  });

  @override
  State<SpellcheckWidget> createState() => _SpellcheckWidgetState();
}

class _SpellcheckWidgetState extends State<SpellcheckWidget> {
  final SpellcheckService _spellcheckService = SpellcheckService();
  final TextEditingController _manualCorrectionController =
      TextEditingController();
  SpellcheckResult? _result;
  bool _isChecking = false;
  int _currentWordIndex = 0;
  String _currentText = '';

  @override
  void initState() {
    super.initState();
    _currentText = widget.text;
    _performSpellcheck();
  }

  @override
  void dispose() {
    _manualCorrectionController.dispose();
    super.dispose();
  }

  Future<void> _performSpellcheck() async {
    setState(() {
      _isChecking = true;
    });

    try {
      final result = await _spellcheckService.checkText(_currentText);
      setState(() {
        _result = result;
        _currentWordIndex = 0;
        _isChecking = false;
      });
    } catch (e) {
      setState(() {
        _result = SpellcheckResult(
          misspelledWords: [],
          isComplete: false,
          error: e.toString(),
        );
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.spellcheck),
                const SizedBox(width: 8),
                const Text(
                  'Spell Check',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _isChecking ? null : _performSpellcheck,
                  tooltip: 'Recheck',
                ),
                if (widget.onClose != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onClose,
                    tooltip: 'Close',
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Loading indicator
            if (_isChecking) ...[
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Checking spelling...'),
                  ],
                ),
              ),
            ]
            // Error message
            else if (_result?.error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Error: ${_result!.error}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]
            // No errors found
            else if (_result?.misspelledWords.isEmpty == true) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No spelling errors found!',
                        style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]
            // Show misspelled words
            else if (_result?.misspelledWords.isNotEmpty == true) ...[
              // Progress indicator
              Row(
                children: [
                  Text(
                    'Error ${_currentWordIndex + 1} of ${_result!.misspelledWords.length}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Text(
                    '${_result!.misspelledWords.length} errors found',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value:
                    (_currentWordIndex + 1) / _result!.misspelledWords.length,
              ),
              const SizedBox(height: 16),

              // Current word
              _buildCurrentWordSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWordSection() {
    if (_result == null || _result!.misspelledWords.isEmpty) {
      return const SizedBox.shrink();
    }

    final currentWord = _result!.misspelledWords[_currentWordIndex];

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Misspelled word
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Misspelled word:',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        currentWord.word,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Manual correction input
          const Text(
            'Type correction:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          _buildManualCorrectionInput(currentWord),
          const SizedBox(height: 16),

          // Suggestions
          if (currentWord.suggestions.isNotEmpty) ...[
            const Text(
              'Or choose a suggestion:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: currentWord.suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = currentWord.suggestions[index];
                  return ListTile(
                    title: Text(suggestion),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () => _replaceWord(currentWord, suggestion),
                    dense: true,
                  );
                },
              ),
            ),
          ] else ...[
            const Text(
              'No suggestions available',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
            const Spacer(),
          ],

          // Action buttons
          const SizedBox(height: 16),
          Row(
            children: [
              // Ignore button
              Expanded(
                child: OutlinedButton(
                  onPressed: _ignoreWord,
                  child: const Text('Ignore'),
                ),
              ),
              const SizedBox(width: 8),
              // Add to dictionary button
              Expanded(
                child: OutlinedButton(
                  onPressed: _addToDictionary,
                  child: const Text('Add to Dictionary'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Previous button
              Expanded(
                child: ElevatedButton(
                  onPressed: _currentWordIndex > 0 ? _previousWord : null,
                  child: const Text('Previous'),
                ),
              ),
              const SizedBox(width: 8),
              // Next/Finish button
              Expanded(
                child: ElevatedButton(
                  onPressed: _nextWord,
                  child: Text(
                    _currentWordIndex < _result!.misspelledWords.length - 1
                        ? 'Next'
                        : 'Finish',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildManualCorrectionInput(SpellcheckWord currentWord) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _manualCorrectionController,
            decoration: InputDecoration(
              hintText: 'Enter correct spelling...',
              border: const OutlineInputBorder(),
              isDense: true,
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => _manualCorrectionController.clear(),
                tooltip: 'Clear',
              ),
            ),
            onSubmitted: (value) => _applyManualCorrection(currentWord, value),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => _applyManualCorrection(
            currentWord,
            _manualCorrectionController.text,
          ),
          child: const Text('Apply'),
        ),
      ],
    );
  }

  void _applyManualCorrection(SpellcheckWord word, String correction) {
    final trimmedCorrection = correction.trim();
    if (trimmedCorrection.isNotEmpty) {
      _replaceWord(word, trimmedCorrection);
      _manualCorrectionController.clear();
    }
  }

  void _replaceWord(SpellcheckWord word, String replacement) {
    final newText = _currentText.replaceRange(
      word.startIndex,
      word.endIndex,
      replacement,
    );

    setState(() {
      _currentText = newText;
    });

    widget.onTextChanged(newText);
    _nextWord();
  }

  void _ignoreWord() {
    _nextWord();
  }

  void _addToDictionary() {
    final currentWord = _result!.misspelledWords[_currentWordIndex];
    _spellcheckService.addToDictionary(currentWord.word);
    _nextWord();
  }

  void _nextWord() {
    if (_currentWordIndex < _result!.misspelledWords.length - 1) {
      setState(() {
        _currentWordIndex++;
      });
    } else {
      // Finished checking all words
      if (widget.onClose != null) {
        widget.onClose!();
      }
    }
  }

  void _previousWord() {
    if (_currentWordIndex > 0) {
      setState(() {
        _currentWordIndex--;
      });
    }
  }
}
