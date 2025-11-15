enum Player { x, o, triangle }

class GameLogic {
  List<List<Player?>>? board;
  int boardSize;
  int winCondition;
  Player? currentPlayer;
  List<Player> players;

  GameLogic({
    this.boardSize = 3,
    this.winCondition = 3,
    this.players = const [Player.x, Player.o],
  }) {
    _initializeBoard();
  }

  void _initializeBoard() {
    board = List.generate(boardSize, (_) => List.filled(boardSize, null));
    currentPlayer = players[0];
  }

  bool makeMove(int row, int col) {
    if (board![row][col] == null) {
      board![row][col] = currentPlayer;
      if (checkForWin(row, col)) {
        // Handle win
      } else if (isBoardFull()) {
        // Handle draw
      } else {
        _switchPlayer();
      }
      return true;
    }
    return false;
  }

  void _switchPlayer() {
    int currentIndex = players.indexOf(currentPlayer!);
    currentPlayer = players[(currentIndex + 1) % players.length];
  }

  bool isBoardFull() {
    return board!.every((row) => row.every((cell) => cell != null));
  }

  bool checkForWin(int row, int col) {
    Player? player = board![row][col];
    if (player == null) return false;

    // Check horizontal, vertical, and both diagonals
    return _checkLine(player, row, col, 1, 0) || // Horizontal
           _checkLine(player, row, col, 0, 1) || // Vertical
           _checkLine(player, row, col, 1, 1) || // Diagonal
           _checkLine(player, row, col, 1, -1);   // Anti-diagonal
  }

  bool _checkLine(Player player, int row, int col, int dr, int dc) {
    int count = 1;
    // Check in the positive direction
    for (int i = 1; i < winCondition; i++) {
      int r = row + i * dr;
      int c = col + i * dc;
      if (r >= 0 && r < boardSize && c >= 0 && c < boardSize && board![r][c] == player) {
        count++;
      } else {
        break;
      }
    }
    // Check in the negative direction
    for (int i = 1; i < winCondition; i++) {
      int r = row - i * dr;
      int c = col - i * dc;
      if (r >= 0 && r < boardSize && c >= 0 && c < boardSize && board![r][c] == player) {
        count++;
      } else {
        break;
      }
    }
    return count >= winCondition;
  }
}
