import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScoreboardPage extends StatelessWidget {
  Future<List<String>> _getTopScores() async {
    final prefs = await SharedPreferences.getInstance();
    final scores = prefs.getStringList('scores') ?? [];
    scores.sort((a, b) => int.parse(b.split('-')[0]).compareTo(int.parse(a.split('-')[0])));
    return scores.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/start.png", 
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: FutureBuilder<List<String>>(
              future: _getTopScores(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text(
                    'No scores yet!',
                    style: TextStyle(
                      fontFamily: 'hangmanTitle',
                      fontSize: 80,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 4.0,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  );
                }

                final scores = snapshot.data!;
                final medals = ["🥇", "🥈", "🥉"];
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Top Scores",
                      style: TextStyle(
                        fontFamily: 'hangmanTitle',
                        fontSize: 80,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(2, 2),
                            blurRadius: 4.0,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 100),
                    for (int i = 0; i < scores.length; i++)
                      Text(
                        "${medals[i]} ${scores[i].split('-').sublist(1).join('-')}\t --- Score: ${scores[i].split('-')[0]}",
                        style: TextStyle(
                          fontFamily: 'buttonFont',
                          fontSize: 40,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(2, 2),
                              blurRadius: 4.0,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
