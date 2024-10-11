import 'dart:async';
import 'dart:io';
import 'dart:math';

class Point {
  int x;
  int y;
  Point(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Point && runtimeType == other.runtimeType && x == other.x && y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

class KadalGame {
  late int gridWidth;
  late int gridHeight;
  List<Point> kadal = [];
  Point makanan;
  bool isVertical = false;

  KadalGame() : makanan = Point(0, 0) {
    updateGridSize();
    int startX = gridWidth ~/ 2;
    int startY = gridHeight ~/ 2;
    kadal = [
      Point(startX, startY),
      Point(startX - 1, startY),
      Point(startX - 2, startY)
    ];
    generateMakanan();
  }

  void updateGridSize() {
    gridWidth = stdout.terminalColumns;
    gridHeight = stdout.terminalLines;
    if (gridWidth < 20) gridWidth = 20;
    if (gridHeight < 10) gridHeight = 10;
  }

  void generateMakanan() {
    Random random = Random();
    int x, y;
    do {
      x = random.nextInt(gridWidth - 1);
      y = random.nextInt(gridHeight - 1);
    } while (kadal.contains(Point(x, y)));
    makanan = Point(x, y);
  }

  void start() {
    Timer.periodic(Duration(milliseconds: 200), (timer) {
      moveKadal();
      render();
    });
  }

  void moveKadal() {
    Point kepala = kadal.first;
    Point newHead;

    if (kepala.x < makanan.x) {
      newHead = Point(kepala.x + 1, kepala.y);
      isVertical = false;
    } else if (kepala.x > makanan.x) {
      newHead = Point(kepala.x - 1, kepala.y);
      isVertical = false;
    } else if (kepala.y < makanan.y) {
      newHead = Point(kepala.x, kepala.y + 1);
      isVertical = true;
    } else if (kepala.y > makanan.y) {
      newHead = Point(kepala.x, kepala.y - 1);
      isVertical = true;
    } else {
      // Jika kepala sudah di posisi makanan, bergerak ke arah random
      newHead = _getRandomMove(kepala);
    }

    // Pastikan newHead tidak keluar dari grid
    newHead = Point(
      newHead.x.clamp(0, gridWidth - 1),
      newHead.y.clamp(0, gridHeight - 1)
    );

    if (newHead == makanan) {
      kadal.insert(0, newHead);
      generateMakanan();
    } else {
      kadal.insert(0, newHead);
      kadal.removeLast();
    }
  }

  Point _getRandomMove(Point kepala) {
    List<Point> possibleMoves = [
      Point(kepala.x + 1, kepala.y),
      Point(kepala.x - 1, kepala.y),
      Point(kepala.x, kepala.y + 1),
      Point(kepala.x, kepala.y - 1),
    ];
    possibleMoves.shuffle();
    return possibleMoves.first;
  }

  void render() {
    updateGridSize();
    stdout.write('\x1B[2J\x1B[0;0H');

    List<List<String>> grid = List.generate(
      gridHeight,
      (_) => List.filled(gridWidth, ' ')
    );

    for (int i = 0; i < kadal.length; i++) {
      Point p = kadal[i];
      if (i == 0) {
        grid[p.y][p.x] = '@';
      } else if (i == kadal.length - 1) {
        grid[p.y][p.x] = '~';
      } else {
        grid[p.y][p.x] = '=';
      }

      // Rendering kaki
      if (i == kadal.length ~/ 2 || i == kadal.length ~/ 2 + 1) {
        if (isVertical) {
          if (p.x > 0) grid[p.y][p.x - 1] = '<';
          if (p.x < gridWidth - 1) grid[p.y][p.x + 1] = '>';
        } else {
          if (p.y > 0) grid[p.y - 1][p.x] = '^';
          if (p.y < gridHeight - 1) grid[p.y + 1][p.x] = 'v';
        }
      }
    }

    grid[makanan.y][makanan.x] = 'O';

    for (var row in grid) {
      print(row.join());
    }
  }
}


void main() {
  KadalGame game = KadalGame();
  game.start();
}

