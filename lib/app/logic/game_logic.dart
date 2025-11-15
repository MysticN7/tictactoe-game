enum Player { x, o, triangle }

class Move {
  final int row;
  final int col;
  final Player player;

  Move(this.row, this.col, this.player);
}

class WinningLine {
  final List<int> positions; // Flat indices
  final Player player;

  WinningLine(this.positions, this.player);
}

class GameLogic {
  List<List<Player?>>? board;
  int boardSize;
  int winCondition;
  Player? currentPlayer;
  List<Player> players;
  List<Move> moveHistory;
  WinningLine? winningLine;
  Player? winner;
  bool isGameOver;

  GameLogic({
    this.boardSize = 3,
    this.winCondition = 3,
    this.players = const [Player.x, Player.o],
  })  : moveHistory = [],
        isGameOver = false {
    _initializeBoard();
  }

  void _initializeBoard() {
    board = List.generate(boardSize, (_) => List.filled(boardSize, null));
    currentPlayer = players[0];
    winningLine = null;
    winner = null;
    isGameOver = false;
    moveHistory.clear();
  }

  bool makeMove(int row, int col) {
    if (isGameOver || board![row][col] != null) {
      return false;
    }

    board![row][col] = currentPlayer;
    moveHistory.add(Move(row, col, currentPlayer!));

    final winLine = checkForWin(row, col);
    if (winLine != null) {
      winningLine = winLine;
      winner = currentPlayer;
      isGameOver = true;
    } else if (isBoardFull()) {
      isGameOver = true;
    } else {
      _switchPlayer();
    }

    return true;
  }

  bool undoLastMove() {
    if (moveHistory.isEmpty || isGameOver) {
      return false;
    }

    final lastMove = moveHistory.removeLast();
    board![lastMove.row][lastMove.col] = null;
    winningLine = null;
    winner = null;
    isGameOver = false;

    // Restore previous player
    if (moveHistory.isNotEmpty) {
      currentPlayer = moveHistory.last.player;
    } else {
      currentPlayer = players[0];
    }

    return true;
  }

  void _switchPlayer() {
    int currentIndex = players.indexOf(currentPlayer!);
    currentPlayer = players[(currentIndex + 1) % players.length];
  }

  bool isBoardFull() {
    return board!.every((row) => row.every((cell) => cell != null));
  }

  WinningLine? checkForWin(int row, int col) {
    Player? player = board![row][col];
    if (player == null) return null;

    // Check all directions
    final horizontal = _checkLine(player, row, col, 1, 0);
    if (horizontal != null) return horizontal;

    final vertical = _checkLine(player, row, col, 0, 1);
    if (vertical != null) return vertical;

    final diagonal = _checkLine(player, row, col, 1, 1);
    if (diagonal != null) return diagonal;

    final antiDiagonal = _checkLine(player, row, col, 1, -1);
    if (antiDiagonal != null) return antiDiagonal;

    return null;
  }

  WinningLine? _checkLine(Player player, int row, int col, int dr, int dc) {
    List<int> positions = [];
    int count = 1;
    positions.add(row * boardSize + col);

    // Check in the positive direction
    for (int i = 1; i < winCondition; i++) {
      int r = row + i * dr;
      int c = col + i * dc;
      if (r >= 0 && r < boardSize && c >= 0 && c < boardSize && board![r][c] == player) {
        count++;
        positions.add(r * boardSize + c);
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
        positions.add(r * boardSize + c);
      } else {
        break;
      }
    }

    if (count >= winCondition) {
      positions.sort();
      return WinningLine(positions, player);
    }
    return null;
  }

  void updateBoardSize(int newSize) {
    boardSize = newSize;
    _initializeBoard();
  }

  void updateWinCondition(int newCondition) {
    winCondition = newCondition;
    _initializeBoard();
  }

  void updatePlayers(List<Player> newPlayers) {
    players = newPlayers;
    _initializeBoard();
  }
}
