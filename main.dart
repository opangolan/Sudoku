import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

void main() {
  runApp(SudokuApp());
}

class SudokuApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sudoku")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DifficultySelectionScreen()),
                );
              },
              child: Text("New Puzzle"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PreviousPuzzlesScreen()),
                );
              },
              child: Text("Previous Puzzles"),
            ),
          ],
        ),
      ),
    );
  }
}

class DifficultySelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Difficulty")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SudokuScreen(difficulty: 30)),
                );
              },
              child: Text("Easy"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SudokuScreen(difficulty: 40)),
                );
              },
              child: Text("Medium"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SudokuScreen(difficulty: 50)),
                );
              },
              child: Text("Hard"),
            ),
          ],
        ),
      ),
    );
  }
}

class PreviousPuzzlesScreen extends StatelessWidget {
  static List<String> previousPuzzles = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Previous Puzzles")),
      body: Center(
        child: ListView(
          children: previousPuzzles.map((time) => ListTile(title: Text(time))).toList(),
        ),
      ),
    );
  }
}

class SudokuScreen extends StatefulWidget {
  final int difficulty;
  SudokuScreen({required this.difficulty});
  @override
  _SudokuScreenState createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> {
  List<List<int>> board = List.generate(9, (_) => List.filled(9, 0));
  List<List<int>> solution = List.generate(9, (_) => List.filled(9, 0));
  List<List<int?>> tempBoard = List.generate(9, (_) => List.filled(9, null));
  int? selectedRow;
  int? selectedCol;
  bool puzzleCompleted = false;
  Random random = Random();
  Timer? timer;
  int secondsElapsed = 0;

  @override
  void initState() {
    super.initState();
    generatePuzzle();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        secondsElapsed++;
      });
    });
  }

  void stopTimer() {
    timer?.cancel();
  }

  void generatePuzzle() {
    board = List.generate(9, (_) => List.filled(9, 0));
    fillBoard(0, 0);
    removeNumbers(widget.difficulty);
    puzzleCompleted = false;
    setState(() {});
  }

  bool isSafe(int row, int col, int num) {
    for (int i = 0; i < 9; i++) {
      if (board[row][i] == num || board[i][col] == num) {
        return false;
      }
    }
    int startRow = row - row % 3, startCol = col - col % 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[startRow + i][startCol + j] == num) {
          return false;
        }
      }
    }
    return true;
  }

  bool fillBoard(int row, int col) {
    if (row == 9) return true;
    if (col == 9) return fillBoard(row + 1, 0);
    if (board[row][col] != 0) return fillBoard(row, col + 1);
    List<int> numbers = List.generate(9, (i) => i + 1)..shuffle(random);
    for (int num in numbers) {
      if (isSafe(row, col, num)) {
        board[row][col] = num;
        if (fillBoard(row, col + 1)) return true;
        board[row][col] = 0;
      }
    }
    return false;
  }

  void removeNumbers(int count) {
    solution = List.generate(9, (r) => List.from(board[r]));
    for (int i = 0; i < count; i++) {
      int row, col;
      do {
        row = random.nextInt(9);
        col = random.nextInt(9);
      } while (board[row][col] == 0);
      board[row][col] = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sudoku")),
      body: Center(
        child: Column(
          children: [
            Text("Time: ${secondsElapsed}s"),
            ElevatedButton(
              onPressed: () {
                stopTimer();
                PreviousPuzzlesScreen.previousPuzzles.add("Completed in ${secondsElapsed}s");
                Navigator.pop(context);
              },
              child: Text("Finish Puzzle"),
            ),
          ],
        ),
      ),
    );
  }
}
