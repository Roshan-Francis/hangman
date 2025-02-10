import 'dart:math';
import 'word_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameLogic {
  late String wordToGuess;
  late List<String> displayedWord;
  Set<String> guessedLetters = {};
  int lives = 6;
  bool isGameOver = false;

  Future<void> saveStreak() async {
    if (streak > 0) {
      final prefs = await SharedPreferences.getInstance();
      final scores = prefs.getStringList('scores') ?? [];
      final now = DateTime.now();
      final timestamp = "${now.day}-${now.month}-${now.year}-${now.hour}:${now.minute}";
      scores.add("$streak-$timestamp");
      prefs.setStringList('scores', scores);
    }
  }
  
  
  // score
  int streak = 0;
  Set<String> usedWords = {};
  
  // Hint 
  
  int hintCount = 3;

  void initializeGame({bool isNextRound = false}) {
    var random = Random();

    List<String> availableWords = wordList
        .where((word) => !usedWords.contains(word.toUpperCase()))
        .toList();

    // Reset used words if them all
    if (availableWords.isEmpty) {
      usedWords.clear();
      availableWords = List.from(wordList);
    }

    // new word to guess
    wordToGuess = availableWords[random.nextInt(availableWords.length)].toUpperCase();
    usedWords.add(wordToGuess);

    // Reset game 
    displayedWord = List.generate(wordToGuess.length, (_) => '_');
    guessedLetters.clear();
    lives = 6;
    isGameOver = false;

    // Only reset hints and streak when starting a fresh game, not on next round
    if (!isNextRound) {
      streak = 0;
      hintCount = 3;  
    }

    // Reveal letters based on word length
    int lettersToReveal = wordToGuess.length < 7 ? 1 : 2;

    
    for (int i = 0; i < lettersToReveal; i++) {
      int randomIndex;
      do {
        randomIndex = random.nextInt(wordToGuess.length); 
      } while (displayedWord[randomIndex] != '_'); 

      displayedWord[randomIndex] = wordToGuess[randomIndex];
    }

  }




  String getHangmanImage() {
    return 'assets/images/hangman$lives.png';
  }

  // Handle letter guesses
  void onLetterPressed(String letter) {
    if (isGameOver) return;

    guessedLetters.add(letter);

    // Check if letter is in word
    bool isLetterCorrect = false;
    for (int i = 0; i < wordToGuess.length; i++) {
      if (wordToGuess[i] == letter.toUpperCase()) {
        displayedWord[i] = letter.toUpperCase();
        isLetterCorrect = true;
      }
    }

    // Update game state based on guess
    if (!isLetterCorrect) {
      lives--;
    }

    // Check for game over conditions
    if (lives <= 0) {
      isGameOver = true;
    }

    // Check for win condition
    if (!displayedWord.contains('_')) {
      isGameOver = true;
      streak++;
    }
  }

  // Hint system 
  void useHint() {
    if (hintCount <= 0 || isGameOver) return;

    hintCount--;

    //  positionn where letters haven't guessed
    List<int> unguessedIndices = [];
    for (int i = 0; i < wordToGuess.length; i++) {
      if (displayedWord[i] == '_') {
        unguessedIndices.add(i);
      }
    }

    //show random unguessed letter
    if (unguessedIndices.isNotEmpty) {
      int randomIndex = unguessedIndices[Random().nextInt(unguessedIndices.length)];
      String letter = wordToGuess[randomIndex];

      for (int i = 0; i < wordToGuess.length; i++) {
        if (wordToGuess[i] == letter) {
          displayedWord[i] = letter;
        }
      }

      guessedLetters.add(letter);
    }

    // Check if hint revealed the last letter(s)
    if (!displayedWord.contains('_')) {
      isGameOver = true;
      streak++;
    }
  }

  String getDisplayedWord() => displayedWord.join(' ');
  Set<String> getGuessedLetters() => guessedLetters;
  int getLives() => lives;
  bool getIsGameOver() => isGameOver;
  int getStreak() => streak;
  int getHintCount() => hintCount;
}