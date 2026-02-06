import 'package:flutter/material.dart';
import 'main_menu.dart'; // Import file yang baru kita buat

void main() => runApp(const PuzzleGame());

class PuzzleGame extends StatelessWidget {
  const PuzzleGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey[900],
        body: const SafeArea(
          child: MainMenu(), // Memanggil widget dari game_board.dart
        ),
      ),
    );
  }
}