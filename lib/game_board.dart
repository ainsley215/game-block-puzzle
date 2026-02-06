import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  List<List<int>> grid = List.generate(8, (_) => List.filled(8, 0));
  int score = 0;
  int highScore = 0;

  final List<Color> pastelColors = [
    Colors.grey[800]!, // Index 0 (Kosong)
    const Color(0xFFFFB7B2), // Pink Pastel
    const Color(0xFFFFDAC1), // Peach
    const Color(0xFFE2F0CB), // Green Pastel
    const Color(0xFFB5EAD7), // Mint
    const Color(0xFFC7CEEA), // Purple Pastel
  ];

  final List<List<Offset>> allShapes = [
    [const Offset(0, 0), const Offset(0, 1), const Offset(0, 2)], // Baris 3
    [const Offset(0, 0), const Offset(1, 0), const Offset(2, 0)], // Kolom 3
    [const Offset(0, 0), const Offset(1, 0), const Offset(1, 1)], // L Kecil
    [const Offset(0, 0), const Offset(0, 1), const Offset(1, 0), const Offset(1, 1)], // Kotak 2x2
    
    [
      const Offset(0, 0), const Offset(0, 1), const Offset(0, 2),
      const Offset(1, 0), const Offset(1, 1), const Offset(1, 2),
      const Offset(2, 0), const Offset(2, 1), const Offset(2, 2),
    ],
    
    [const Offset(0, 0)], // Titik Tunggal
  ];

  // simpan bentuk balok BESERTA warnanya
  List<Map<String, dynamic>> currentAvailableBlocks = [];

  @override
  void initState() {
    super.initState();
    loadHighScore();
    generateNewBlocks();
  }

  void generateNewBlocks() {
    setState(() {
      currentAvailableBlocks = List.generate(3, (_) {
        return {
          'shape': allShapes[Random().nextInt(allShapes.length)],
          'colorIndex': Random().nextInt(pastelColors.length - 1) + 1, // Ambil warna acak (bukan index 0)
        };
      });
    });
  }

  bool canPlace(int r, int c, List<Offset> shape) {
    for (var offset in shape) {
      int tr = r + offset.dx.toInt();
      int tc = c + offset.dy.toInt();
      if (tr < 0 || tr >= 8 || tc < 0 || tc >= 8 || grid[tr][tc] != 0) return false;
    }
    return true;
  }

  bool isGameOver() {
    if (currentAvailableBlocks.isEmpty) return false;

    // Cek setiap balok yang tersedia di bawah
    for (var block in currentAvailableBlocks) {
      List<Offset> shape = block['shape'] as List<Offset>;
      
      // Cek setiap koordinat di grid (r, c)
      for (int r = 0; r < 8; r++) {
        for (int c = 0; c < 8; c++) {
          if (canPlace(r, c, shape)) {
            return false; // Masih ada tempat untuk setidaknya satu balok
          }
        }
      }
    }
    return true; // Tidak ada satu pun balok yang bisa masuk
  }

  // Fungsi untuk mengambil skor tertinggi yang tersimpan
  void loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt('highScore') ?? 0;
    });
  }

  // Fungsi untuk menyimpan skor jika tembus rekor baru
  void updateHighScore() async {
    if (score > highScore) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        highScore = score;
      });
      await prefs.setInt('highScore', highScore);
    }
  }

  // Fungsi untuk reset game
  void resetGame() {
    setState(() {
      grid = List.generate(8, (_) => List.filled(8, 0));
      score = 0;
      generateNewBlocks();
    });
  }

  Future<void> checkLines() async {
    List<int> fullRows = [];
    for (int r = 0; r < 8; r++) {
      if (!grid[r].contains(0)) fullRows.add(r);
    }

    // Cek kolom
    List<int> fullCols = [];
    for (int c = 0; c < 8; c++) {
      bool full = true;
      for (int r = 0; r < 8; r++) {
        if (grid[r][c] == 0) full = false;
      }
      if (full) fullCols.add(c);
    }

    // JIKA ADA YANG PENUH
    if (fullRows.isNotEmpty || fullCols.isNotEmpty) {
      // Beri jeda sebentar 
      await Future.delayed(const Duration(milliseconds: 300));

      setState(() {
        // Hapus Baris
        for (var r in fullRows) {
          grid[r] = List.filled(8, 0);
          score += 100;
        }
        // Hapus Kolom
        for (var c in fullCols) {
          for (int r = 0; r < 8; r++) {
            grid[r][c] = 0;
          }
          score += 100;
        }
      });
      updateHighScore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context), 
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Score: $score", 
            style: TextStyle(color: Colors.white, fontSize: 35)),
          Text("Best: $highScore", 
            style: TextStyle(color: Colors.amber, fontSize: 23)),
          
          const SizedBox(height: 20),
          Container(
            width: 320, height: 320,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
              itemCount: 64,
              itemBuilder: (context, index) {
                int r = index ~/ 8; int c = index % 8;
                return DragTarget<Map<String, dynamic>>(
                  // Gunakan 'details.data' untuk mendapatkan Map
                  onWillAcceptWithDetails: (details) => canPlace(r, c, details.data['shape'] as List<Offset>),
                  onAcceptWithDetails: (details) async {
                    setState(() {
                      // ambil shape dan colorIndex dari Map details.data
                      List<Offset> shape = details.data['shape'] as List<Offset>;
                      int colorIdx = details.data['colorIndex'] as int;

                      for (var offset in shape) {
                        grid[r + offset.dx.toInt()][c + offset.dy.toInt()] = colorIdx;
                      }
                      
                      currentAvailableBlocks.remove(details.data);
                      if (currentAvailableBlocks.isEmpty) generateNewBlocks();
                    });
                    await checkLines();
                  if (isGameOver()) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => AlertDialog(
                        title: const Text("Game Over!"),
                        content: Text("Skor Akhir Kamu: $score"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              resetGame();
                            },
                            child: const Text("Main Lagi"),
                          )
                        ],
                      ),
                    );
                  }
                }, 
                  builder: (context, candidateData, rejectedData) => Container(
                    margin: const EdgeInsets.all(1.5),
                    decoration: BoxDecoration(
                      color: pastelColors[grid[r][c]],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: currentAvailableBlocks.map((blockData) => Draggable<Map<String, dynamic>>(
              data: blockData,
              feedback: BlockPreview(
                shape: blockData['shape'], 
                size: 25, 
                color: pastelColors[blockData['colorIndex']].withOpacity(0.7)
              ),
              childWhenDragging: const Opacity(opacity: 0.3, child: SizedBox(width: 60, height: 60)),
              child: BlockPreview(
                shape: blockData['shape'], 
                size: 20, 
                color: pastelColors[blockData['colorIndex']]
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class BlockPreview extends StatelessWidget {
  final List<Offset> shape;
  final double size;
  final Color color;
  const BlockPreview({super.key, required this.shape, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: size * 3, height: size * 3,
        child: Stack(
          children: shape.map((p) => Positioned(
            left: p.dy * size, top: p.dx * size,
            child: Container(
              width: size - 2, 
              height: size - 2, 
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }
}