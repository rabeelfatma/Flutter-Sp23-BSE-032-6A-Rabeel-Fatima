import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyDiceApp());
}

class MyDiceApp extends StatelessWidget {
  const MyDiceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Dice App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.deepPurple.shade50,
      ),
      home: const DiceGameScreen(),
    );
  }
}

class DiceGameScreen extends StatefulWidget {
  const DiceGameScreen({Key? key}) : super(key: key);

  @override
  State<DiceGameScreen> createState() => _DiceGameScreenState();
}

class _DiceGameScreenState extends State<DiceGameScreen> {
  final TextEditingController _roundsController = TextEditingController(text: "3");
  final TextEditingController _playersController = TextEditingController(text: "2");
  final Random _random = Random();

  int _rounds = 3;
  int _players = 2;
  int _currentRound = 1;
  int _currentPlayer = 1;
  int _diceValue = 1;
  bool _gameOver = false;
  List<int> _scores = [0, 0];

  void _updateGameSettings() {
    final rounds = int.tryParse(_roundsController.text) ?? 3;
    final players = int.tryParse(_playersController.text) ?? 2;
    setState(() {
      _rounds = rounds;
      _players = players;
      _scores = List<int>.filled(players, 0);
      _currentRound = 1;
      _currentPlayer = 1;
      _diceValue = 1;
      _gameOver = false;
    });
  }

  void _rollDice() {
    setState(() {
      _diceValue = _random.nextInt(6) + 1;
      _scores[_currentPlayer - 1] += _diceValue;

      if (_currentPlayer < _players) {
        _currentPlayer++;
      } else {
        _currentPlayer = 1;
        _currentRound++;
      }

      if (_currentRound > _rounds) {
        _gameOver = true;
      }
    });
  }

  void _restartGame() {
    setState(() {
      _currentRound = 1;
      _currentPlayer = 1;
      _diceValue = 1;
      _scores = List<int>.filled(_players, 0);
      _gameOver = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    int highestScore =
    _scores.isNotEmpty ? _scores.reduce((a, b) => a > b ? a : b) : 0;
    List<int> winners = [];
    for (int i = 0; i < _scores.length; i++) {
      if (_scores[i] == highestScore) winners.add(i + 1);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("🎲 Dice Game"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Welcome to My Dice Game!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 15),

              // Input fields
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: TextField(
                      controller: _roundsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Rounds",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => _updateGameSettings(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: TextField(
                      controller: _playersController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Players",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => _updateGameSettings(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              if (_gameOver) ...[
                const Text(
                  "🏆 Game Over!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  winners.length == 1
                      ? "Winner: Player ${winners.first}"
                      : "It’s a tie between: ${winners.join(", ")}",
                  style: const TextStyle(fontSize: 18, color: Colors.deepPurple),
                ),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: _restartGame,
                  icon: const Icon(Icons.restart_alt),
                  label: const Text("Play Again"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                ),
              ] else ...[
                Text(
                  "Round $_currentRound / $_rounds",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  "Player $_currentPlayer’s Turn",
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple),
                ),
                const SizedBox(height: 10),
                Image.asset(
                  'assets/dice$_diceValue.png',
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 10),
                Text(
                  "You rolled: $_diceValue",
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: _rollDice,
                  icon: const Icon(Icons.casino),
                  label: const Text("Roll Dice"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Scores:",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                ..._scores.asMap().entries.map((entry) => Text(
                  "Player ${entry.key + 1}: ${entry.value}",
                  style: const TextStyle(fontSize: 15),
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
