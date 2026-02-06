import 'package:flutter/material.dart';
import 'game_board.dart'; // Import file game kamu

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "PUZZLE Balok",
              style: TextStyle(
                color: Color(0xFFB5EAD7),
                fontSize: 40,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 50),
            // TOMBOL MULAI
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GameBoard()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB7B2),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text(
                "MULAI BARU",
                style: TextStyle(fontSize: 20, color: Colors.black87, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}