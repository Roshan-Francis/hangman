import 'dart:ui';
import 'package:flutter/material.dart';
import 'game_logic.dart';

const _kAnimationDuration = Duration(milliseconds: 150);
const _kAlphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
const _kGridCrossAxisCount = 7;
const _kGridSpacing = 10.0;

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with SingleTickerProviderStateMixin {
  late final GameLogic gameLogic;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  bool _isDialogVisible = false;
  bool _isWin = false;

  static final _titleStyle = TextStyle(
    fontFamily: 'hangmanTitle',
    fontSize: 75,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    shadows: [
      Shadow(
        offset: const Offset(2, 2),
        blurRadius: 5.0,
        color: Colors.black.withOpacity(0.5),
      ),
    ],
  );

  static final _wordStyle = TextStyle(
    fontFamily: 'hangmanTitle',
    fontSize: 40,
    color: Colors.white,
  );

  static final _buttonTextStyle = TextStyle(
    fontFamily: 'buttonFont',
    fontSize: 25,
    color: Colors.white,
    shadows: [
      Shadow(
        offset: const Offset(2, 2),
        blurRadius: 4.0,
        color: Colors.black.withOpacity(0.5),
      ),
    ],
  );

  // Caching gradients to prevent recreation
  static final _buttonGradient = LinearGradient(
    colors: const [
      Color.fromARGB(255, 0, 0, 0),
      Color.fromARGB(255, 50, 50, 50),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final _usedButtonGradient = LinearGradient(
    colors: const [
      Color.fromARGB(255, 79, 2, 67),
      Color.fromARGB(255, 230, 7, 238),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Initialize game logic and animation controller
  @override
  void initState() {
    super.initState();
    gameLogic = GameLogic();
    _animationController = AnimationController(
      vsync: this,
      duration: _kAnimationDuration,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }
  //precaching images
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Using Future.wait for parallel image loading
    Future.wait([
      for (var i = 0; i < 7; i++)
        precacheImage(AssetImage('assets/images/hangman$i.png'), context)
    ]);
    gameLogic.initializeGame();
  }
  
  //dispose animations
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildLetterButton(String letter, bool isUsed) {
    return Align(
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: isUsed ? null : () => _onLetterPressed(letter),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.black.withOpacity(0.5),
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.white, width: 2),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: isUsed ? _usedButtonGradient : _buttonGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(letter, style: _buttonTextStyle),
          ),
        ),
      ),
    );
  }

  Widget _buildHintButton() {
    return ElevatedButton(
      onPressed: gameLogic.getHintCount() > 0 ? _onHintPressed : null,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.black.withOpacity(0.5),
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.white, width: 2),
        ),
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: _buttonGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Text(
            'Hint (${gameLogic.getHintCount()})',
            style: _buttonTextStyle,
          ),
        ),
      ),
    );
  }

  void _onLetterPressed(String letter) {
    setState(() {
      gameLogic.onLetterPressed(letter);
      if (gameLogic.getIsGameOver()) {
        _showEndGameDialog(isWin: !gameLogic.getDisplayedWord().contains('_'));
      }
    });
  }

  void _onHintPressed() {
    setState(() {
      gameLogic.useHint();
      if (gameLogic.getIsGameOver()) {
        _showEndGameDialog(isWin: !gameLogic.getDisplayedWord().contains('_'));
      }
    });
  }

  void _onRetry({bool isNextRound = false}) {
    _hideEndGameDialog();
    Future.delayed(_kAnimationDuration, () {
      setState(() {
        gameLogic.initializeGame(isNextRound: isNextRound);
      });
    });
  }

  void _showEndGameDialog({required bool isWin}) {
    setState(() {
      _isWin = isWin;
      _isDialogVisible = true;
    });
    if (!isWin) {
      gameLogic.saveStreak();
    }
    _animationController.forward();
  }

  void _hideEndGameDialog() {
    _animationController.reverse().then((_) {
      setState(() {
        _isDialogVisible = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: Image(
              image: AssetImage("assets/images/start.png"),
              fit: BoxFit.cover,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(height: 25),
              Text("HANGMAN GAME", style: _titleStyle),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image(
                  image: AssetImage(gameLogic.getHangmanImage()),
                  height: screenHeight * 0.3,
                ),
              ),
              Text(
                gameLogic.getDisplayedWord(),
                style: _wordStyle,
                textAlign: TextAlign.center,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: screenWidth * 0.06,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Lives: ${gameLogic.getLives()} ||',
                      style: _wordStyle,
                    ),
                  ),
                  Text('Streak: ${gameLogic.getStreak()}', style: _wordStyle),
                ],
              ),
              Expanded(
                child: Center(
                  child: Column(
                    children: [
                      Expanded(
                        child: GridView.builder(
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _kGridCrossAxisCount,
                            crossAxisSpacing: _kGridSpacing,
                            mainAxisSpacing: _kGridSpacing,
                          ),
                          itemCount: 26,
                          itemBuilder: (context, index) {
                            final letter = _kAlphabet[index];
                            final isUsed =
                                gameLogic.guessedLetters.contains(letter);
                            return _buildLetterButton(letter, isUsed);
                          },
                        ),
                      ),
                      _buildHintButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_isDialogVisible) _buildEndGameDialog(),
        ],
      ),
    );
  }

  Widget _buildEndGameDialog() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: _buttonGradient,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isWin ? "You Win!" : "Game Over",
                  style: _buttonTextStyle.copyWith(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _isWin
                      ? "Congratulations! You've guessed the word."
                      : "The word was: ${gameLogic.wordToGuess}",
                  style: _buttonTextStyle.copyWith(fontSize: 30),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _onRetry(isNextRound: _isWin),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.black.withOpacity(0.5),
                    elevation: 10.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Colors.white, width: 2),
                    ),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: _buttonGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 10,
                      ),
                      child: Text(
                        _isWin ? "Next Round" : "Retry",
                        style: _buttonTextStyle.copyWith(fontSize: 30),
                      ),
                    ),
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
